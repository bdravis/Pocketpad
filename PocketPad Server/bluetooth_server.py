import re
import os
import sys
import json
import time
import enums
import queue
import psutil
import logging
import asyncio
import threading
import game_database as gdb
from typing import Dict, Union
from inputs import parse_input, map_inputID_to_inputs
from struct import unpack, pack
from functools import cached_property
from enums import ControllerUpdateTypes
from server_constants import *
from utils import Paircode
from dsu_server import DSU_Server

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

from PySide6.QtCore import QObject
from dataclasses import dataclass

logger = logging.getLogger(name=__name__)
logger.setLevel(logging.INFO)
logging.getLogger("bless.backends.winrt.server").setLevel(logging.WARNING)
logging.getLogger("asyncio").setLevel(logging.WARNING)

trigger: Union[asyncio.Event, threading.Event] = None
thread = None
loop = None

NUM_WORKERS = 32
request_queue: "queue.Queue[tuple[BlessGATTCharacteristic, bytes]]" = queue.Queue(maxsize=2500)

def _thread_worker():
    """Continuously pull write-requests off the queue and handle them."""
    while True:
        characteristic, value = request_queue.get()
        try:
            process_write_request(characteristic, value)
        except Exception:
            logger.exception("Error processing write request")
        finally:
            request_queue.task_done()

# Start worker threads at module load
for _ in range(NUM_WORKERS):
    t = threading.Thread(target=_thread_worker, daemon=True)
    t.start()
#

num_players_lock = threading.Lock()
next_id_lock = threading.Lock()

MAX_PLAYERS = 4

# This is an array of strings that will contain jsons that are being sent
layout_jsons_temp = ["" for _ in range(MAX_PLAYERS)]
# 0 for not sending, 1 for currently sending, don't use the layout if it is 1
layout_jsons_status = [0 for _ in range(MAX_PLAYERS)]

# Holds json strings that have finished sending
layout_jsons = ["" for _ in range(MAX_PLAYERS)]

player_id_str_arr = ["" for _ in range(MAX_PLAYERS)]

current_game = None

latency_function = None
send_latency = None
connection_function = None
controller_function = None
input_function = None
game_function = None

gatt: Dict = {
    POCKETPAD_SERVICE: {

        # Client writes time of pckage sent to LATENCY_CHARACTERISTIC
        # This is used to calculate latency by comparing to time received

        LATENCY_CHARACTERISTIC: {
            "Properties": (
                GATTCharacteristicProperties.read
                | GATTCharacteristicProperties.write_without_response
                | GATTCharacteristicProperties.indicate
            ),
            "Permissions": (
                GATTAttributePermissions.readable
                | GATTAttributePermissions.writeable
            ),
            "Value": None,
        },

        # Store when client connects or disconnects

        CONNECTION_CHARACTERISTIC: {
            "Properties": (
                GATTCharacteristicProperties.read
                | GATTCharacteristicProperties.write
                | GATTCharacteristicProperties.indicate
            ),
            "Permissions": (
                GATTAttributePermissions.readable
                | GATTAttributePermissions.writeable
            ),
            "Value": None,
        },

        # Store what type of controller the packet was sent from

        CONTROLLER_TYPE_CHARACTERISTIC: {
            "Properties": (
                GATTCharacteristicProperties.read
                | GATTCharacteristicProperties.write
                | GATTCharacteristicProperties.indicate
            ),
            "Permissions": (
                GATTAttributePermissions.readable
                | GATTAttributePermissions.writeable
            ),
            "Value": None,
        },

        # Store inputs sent from client (Implementation undecided)

        INPUT_CHARACTERISTIC: { # UNUSED RIGHT NOW
            "Properties": (
                GATTCharacteristicProperties.read
                | GATTCharacteristicProperties.write_without_response
                | GATTCharacteristicProperties.indicate
            ),
            "Permissions": (
                GATTAttributePermissions.readable
                | GATTAttributePermissions.writeable
            ),
            "Value": None,
        }, 

        LAYOUT_REQUEST_CHARACTERISTIC: {
            "Properties": (
                GATTCharacteristicProperties.read
                | GATTCharacteristicProperties.write
            ),
            "Permissions": (
                GATTAttributePermissions.readable
                | GATTAttributePermissions.writeable
            ),
            "Value": None,
        },
        
        PAIRCODE_CHARACTERISTIC: {
            "Properties": (
                GATTCharacteristicProperties.read
            ),
            "Permissions": (
                GATTAttributePermissions.readable
            ),
            "Value": None,
        },
    },
}

# 1) Cross‑platform game‑name extraction from window title (reuse from earlier)
if sys.platform == 'win32':
    import pywinctl
    def get_current_dolphin_game() -> str | None:
        wins = [
            w for w in pywinctl.getAllWindows()
            if "dolphin" in w.title.lower()
        ]

        if not wins:
            print("No Dolphin window found")
            return None

        for w in wins:
            if "|" in w.title:
                parts = w.title.split("|")
                return parts[-1].strip()
elif sys.platform == 'darwin':
    from AppKit import NSWorkspace
    from Quartz import CGWindowListCopyWindowInfo, kCGWindowListOptionOnScreenOnly, kCGNullWindowID
    def get_current_dolphin_game():
        wins = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID)
        for w in wins:
            game = None
            if w.get('kCGWindowOwnerName') != 'Dolphin':
                continue
            pid = w.get('kCGWindowOwnerPID')
            proc = psutil.Process(pid)
            for f in proc.open_files():
                if is_allowed_path(f.path):
                    game = extract_game_name_from_path(f.path)
            if game:
                return game
        return None
else:
    def get_current_dolphin_game() -> str | None:
        return None

def dolphin_is_running() -> bool:
    name = 'dolphin.exe' if sys.platform=='win32' else 'dolphin'
    return any(p.name().lower() == name for p in psutil.process_iter(['name']))

BLACKLIST = {'.log', '.list', '.data', '.uidchache'}

def is_allowed_path(path: str) -> bool:
    extension = os.path.splitext(path)[1].lower()
    return extension not in BLACKLIST

def extract_game_name_from_path(full_path: str) -> str:
    core, *_ = full_path.rsplit(" ", 1)
    file_name = os.path.basename(core)
    name, _ = os.path.splitext*(file_name)
    cleaned = re.sub(r'\s*[\(\[].*?[\)\]]\s*$', '', name).strip()
    return cleaned

def set_latency_callback(send_latency_callback, latency_function_callback):
    global latency_function, send_latency
    send_latency = send_latency_callback
    latency_function = latency_function_callback

def set_connection_callback(connection_function_callback):
    global connection_function
    connection_function = connection_function_callback

def set_controller_callback(controller_function_callback):
    global controller_function
    controller_function = controller_function_callback

def set_input_callback(input_function_callback):
    global input_function
    input_function = input_function_callback

def set_game_callback(game_function_callback):
    global game_function
    game_function = game_function_callback

def save_layout(game_name, player_id):
    layout_to_save = layout_jsons[player_id_str_arr.index(player_id)]
    gdb.add_to_database(game_name, layout_to_save)

def request_game_data(game: str):
    global current_game
    current_game = game
    game_function(game)

def reconstruct_timestamp(sent_ms):
    """Reconstruct possible timestamps based on the last 5 digits."""
    cur_ms = int(time.time() * 1000)
    cur = cur_ms // 100000 * 100000 
    
    possible_times = [cur + sent_ms, cur - 100000 + sent_ms]

    closest_time = min(possible_times, key=lambda ts: abs(ts - cur_ms))
    
    latency = cur_ms - closest_time
    
    return abs(latency)

def process_latency_characteristic(characteristic):
    # data comes as little endian {Byte, quadword}
    connection_information = unpack("<Bi", characteristic.value)

    player_id = connection_information[0]
    recieved_time = connection_information[1]

    latency = reconstruct_timestamp(int(recieved_time))

    logger.debug(f"Estimated Latency for player {player_id}: {latency} ms")
        
    characteristic.value = str(latency).encode()
    latency_function(player_id_str_arr[player_id], latency)

def process_input_characteristic(characteristic):
    input_result = parse_input(characteristic.value)
    if input_result == None:
        return
    elif input_result[0] == -1:
        logger.error("ERROR: Invalid Input")
    else:
        player_id, input_id, event = input_result
        input_function(player_id_str_arr[player_id], input_id, event)

def process_connection_characteristic(characteristic):
    data_length_in_bytes = len(characteristic.value)
    format_str = "B" * data_length_in_bytes
    connection_information = unpack(format_str, characteristic.value)

    player_id = connection_information[0]
    signal = connection_information[1]
    controller_type = connection_information[2]

    with num_players_lock:
        if signal == ConnectionMessage.requesting_id_change.value:

            string_bytes = characteristic.value[3:3+connection_information[2]]
            requested_id = ''.join([chr(byte) for byte in string_bytes])

            if requested_id in player_id_str_arr:

                logger.error("ERROR: Duplicate ID detected, try again with a different ID")
                response_data = pack("<BB", 255, ConnectionMessage.requesting_id.value)

                characteristic.value = bytearray(response_data)
                return

            player_id_str_arr[player_id] = requested_id

            logger.debug(f"Connection request approved for: {player_id}")
            response_data = pack("<BB", player_id, ConnectionMessage.requesting_id.value)
            characteristic.value = bytearray(response_data)

        if signal == ConnectionMessage.requesting_id.value:

            string_bytes = characteristic.value[3:3+connection_information[2]]
            requested_id = ''.join([chr(byte) for byte in string_bytes])

            if requested_id in player_id_str_arr:

                logger.debug("ERROR: Duplicate ID detected, try again with a different ID")

                response_data = pack("<BB", 255, ConnectionMessage.requesting_id.value)

                characteristic.value = bytearray(response_data)
                return

            #TODO If this is the thing make it right

            #next_id = len(player_id_str_arr)


            next_id = -1
            for i in range(4):
                if player_id_str_arr[i] == "":
                    next_id = i
                    break

            if next_id == -1:
                logger.error("ERROR: Too many players")
        
            if requested_id == "Player":
                #player_id_str_arr.append(f'Player {next_id}')
                player_id_str_arr[next_id] = f"Player {next_id}"
            else:
                #player_id_str_arr.append(requested_id)
                player_id_str_arr[next_id] = requested_id

            response_data = pack("<BB", next_id, ConnectionMessage.requesting_id.value)
            characteristic.value = bytearray(response_data)

        if signal == ConnectionMessage.connecting.value:
            # print(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.connecting.value])
            DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.connecting.value])

            logger.debug("I am in here\n")

            #TODO If this is the thing make it right
            next_id = len(player_id_str_arr)

            response_data = [player_id, ConnectionMessage.connecting.value]
            response = bytearray(response_data)
            characteristic.value = response

            if controller_type == 0:
                controller_type = enums.ControllerType.Xbox
            if controller_type == 1:
                controller_type = enums.ControllerType.Playstation
            if controller_type == 2:
                controller_type = enums.ControllerType.Wii
            if controller_type == 3:
                controller_type = enums.ControllerType.Switch

            print(f"Connection request approved for: {player_id_str_arr[player_id]}")

            connection_function("connect", player_id_str_arr[player_id], controller_type, layout_jsons[player_id])

        if signal == ConnectionMessage.disconnecting.value:
            # TODO change server to indicate who is leaving
            DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.disconnecting.value])

            response_data = [0, ConnectionMessage.received.value]
            response = bytearray(response_data)
            characteristic.value = response
                
            if controller_type == 0:
                controller_type = enums.ControllerType.Xbox
            if controller_type == 1:
                controller_type = enums.ControllerType.Playstation
            if controller_type == 2:
                controller_type = enums.ControllerType.Wii
            if controller_type == 3:
                controller_type = enums.ControllerType.Switch

            characteristic.value = response
            connection_function("disconnect", player_id_str_arr[player_id], None, None)

            #player_id_str_arr.pop(player_id)
            #layout_jsons_temp.pop(player_id)
            #layout_jsons.pop(player_id)
            #layout_jsons_status.pop(player_id)
            #DSU_Server.instance().inputId_to_inputs.pop(player_id)

            player_id_str_arr[player_id] = ""
            layout_jsons_temp[player_id] = ""
            layout_jsons[player_id] = ""
            layout_jsons_status[player_id] = 0
            DSU_Server.instance().inputId_to_inputs[player_id] = {}

        if signal == ConnectionMessage.transmitting_layout.value:

            size = connection_information[2]

            # Start transmission, remove old layout from buffer
            if size == 255:
                #layout_jsons_temp.append("")
                #layout_jsons_status.append(1)
                #DSU_Server.instance().inputId_to_inputs.append({})

                layout_jsons_temp[player_id] = ""
                layout_jsons_status[player_id] = 1
                DSU_Server.instance().inputId_to_inputs[player_id] = {}
                
                response_data = [0, ConnectionMessage.transmitting_layout.value]
                response = bytearray(response_data)
                characteristic.value = response
                return

            # json is done sending
            if size == 0:

                #layout_jsons.append(layout_jsons_temp[player_id])
                #layout_jsons_temp[player_id] = ""
                #layout_jsons_status[player_id] = 0

                layout_jsons[player_id] = layout_jsons_temp[player_id]
                layout_jsons_temp[player_id] = ""
                layout_jsons_status[player_id] = 0

                json_for_input_id_workaround = json.loads(layout_jsons[player_id])

                map_inputID_to_inputs(player_id, json_for_input_id_workaround)

                response_data = [0, ConnectionMessage.transmitting_layout.value]
                response = bytearray(response_data)
                characteristic.value = response
                return

            format_str = "3B" + f"{size}s"
            connection_information = unpack(format_str, characteristic.value)

            json_chunk = connection_information[3].decode('utf-8')
            layout_jsons_temp[player_id] += json_chunk

            response_data = [0, ConnectionMessage.transmitting_layout.value]
            response = bytearray(response_data)
            characteristic.value = response

def process_controller_characteristic(characteristic):
    data_length_in_bytes = len(characteristic.value)
    format_str = "B" * data_length_in_bytes
    connection_information = unpack(format_str, characteristic.value)

    player_id = connection_information[0]
    controller_type = connection_information[1]
    size_sent = connection_information[2]

    if size_sent == 255:
        layout_jsons_status[player_id] = 1

        response_data = [0, ConnectionMessage.transmitting_layout.value]
        response = bytearray(response_data)
        characteristic.value = response
        return
    elif size_sent == 0:
        layout_jsons[player_id] = layout_jsons_temp[player_id]
        layout_jsons_temp[player_id] = ""
        layout_jsons_status[player_id] = 0

        json_for_input_id_workaround = json.loads(layout_jsons[player_id])

        map_inputID_to_inputs(player_id, json_for_input_id_workaround)

        if controller_type == 0:
            controller_type = enums.ControllerType.Xbox
        if controller_type == 1:
            controller_type = enums.ControllerType.Playstation
        if controller_type == 2:
            controller_type = enums.ControllerType.Wii
        if controller_type == 3:
            controller_type = enums.ControllerType.Switch

        controller_function(player_id_str_arr[player_id], controller_type, layout_jsons[player_id])

        response_data = [0, ConnectionMessage.transmitting_layout.value]
        response = bytearray(response_data)
        characteristic.value = response
        return
    
    format_str = "3B" + f"{size_sent}s"
    connection_information = unpack(format_str, characteristic.value)

    json_chunk = connection_information[3].decode('utf-8')
    layout_jsons_temp[player_id] += json_chunk

    response_data = [0, ConnectionMessage.transmitting_layout.value]
    response = bytearray(response_data)
    characteristic.value = response

def process_write_request(characteristic: BlessGATTCharacteristic, value):
    upper_uuid = characteristic.uuid.upper()
    if (upper_uuid == LATENCY_CHARACTERISTIC):
        if send_latency:
            process_latency_characteristic(characteristic)
    elif (upper_uuid == INPUT_CHARACTERISTIC):
        process_input_characteristic(characteristic)
    elif (upper_uuid == CONNECTION_CHARACTERISTIC):
        process_connection_characteristic(characteristic)
    elif (upper_uuid == CONTROLLER_TYPE_CHARACTERISTIC):
        process_controller_characteristic(characteristic)
    elif upper_uuid == LAYOUT_REQUEST_CHARACTERISTIC:
        data = characteristic.value
        start_index, stop_index = unpack('<II', data[:8])

        if (start_index == 0 and stop_index == 0):
            if current_game == None:
                response = pack('<I', 0)
                characteristic.value = response
                return
            layout = gdb.get_controller_layout(current_game)
            if layout == None:
                response = pack('<I', 0)
                characteristic.value = response
                return
            layout_bytes = layout.encode('utf-8')
            response = pack('<I', len(layout_bytes))
            characteristic.value = response
            return
        else:
            layout = gdb.get_controller_layout(current_game)
            layout_segment = layout[start_index:stop_index]
            layout_segment_bytes = layout_segment.encode('utf-8')
            response = bytearray([len(layout_segment_bytes)]) + layout_segment_bytes
            characteristic.value = response
            return
    else:
        logger.error("ERROR: Unrecognized Write Request")

class Threaded_Bless_Server(BlessServer):
    async def add_new_descriptor(self, service_uuid, char_uuid, desc_uuid, properties, value, permissions):
        logger.debug(f"Adding descriptor {desc_uuid} to {char_uuid} in {service_uuid}")
        return await super().add_new_descriptor(service_uuid, char_uuid, desc_uuid, properties, value, permissions)

@dataclass
class QBlessServer(QObject):
    @cached_property
    def server(self):
        server = Threaded_Bless_Server(name="PocketPad")

        self.loop = None 
        server.read_request_func = read_request
        server.write_request_func = self.write_request
    
        return server
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._bg_loop = asyncio.new_event_loop()
        self._bg_thread = threading.Thread(target=self._start_bg_loop, daemon=True)
        self._bg_thread.start()

        asyncio.run_coroutine_threadsafe(self.dolphin_monitor(), self._bg_loop)

    def _start_bg_loop(self):
        asyncio.set_event_loop(self._bg_loop)
        self._bg_loop.run_forever()

    def write_request(self, characteristic: BlessGATTCharacteristic, value):
        """Schedule async processing on the persistent background loop."""
        characteristic.value = value
        try:
            request_queue.put_nowait((characteristic, value))
        except queue.Full:
            logger.warning("Request queue full – dropping write")

    async def start(self):
        logger = logging.getLogger(name=__name__)
        logger.info("Starting server")
        
        await self.server.add_gatt(gatt)
        self.server.get_characteristic(PAIRCODE_CHARACTERISTIC).value = str(Paircode.reset().code).encode()
        await self.server.start(prioritize_local_name=True)
        logger.info("Advertising")
    
    async def stop(self):
        logger.info("Stopping server")
        try:
            char = self.server.get_characteristic(CONNECTION_CHARACTERISTIC)
            char.value = bytearray([0, 0])
            self.server.update_value(POCKETPAD_SERVICE, CONNECTION_CHARACTERISTIC)
            
            await asyncio.sleep(0.5) # small buffer
            await self.server.stop()
        except Exception as e:
            pass # Server was never started in the first place

    async def dolphin_monitor(self):
        last_game = None
        while True:
            while not dolphin_is_running():
                await asyncio.sleep(5)
            while dolphin_is_running():
                game = get_current_dolphin_game()
                if game != last_game:
                    last_game = game
                    request_game_data(game)
                await asyncio.sleep(30)
            last_game = None
            request_game_data(None)

def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    logger.debug(f"Reading {characteristic.uuid} - {characteristic.value}")
    return characteristic.value

# Main function to start the bluetooth server for testing purposes
if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
    logger.debug("[OHNO] Run the server from GUI now please")
