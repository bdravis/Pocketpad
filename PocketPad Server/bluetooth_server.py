from functools import cached_property
import sys
import logging
import asyncio
import concurrent.futures
import json
import threading
import time
import enums
from enums import AllButtons, ControllerUpdateTypes
from struct import unpack, pack
from typing import Any, Dict, Union
from server_constants import (POCKETPAD_SERVICE, LATENCY_CHARACTERISTIC, 
                        CONNECTION_CHARACTERISTIC, CONTROLLER_TYPE_CHARACTERISTIC,
                        INPUT_CHARACTERISTIC, ConnectionMessage)
from inputs import parse_input
from shared_definitions import input_server, inputId_to_inputs
from ctypes import c_uint8

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

from PySide6.QtCore import QObject
from dataclasses import dataclass

logger = logging.getLogger(name=__name__)
logger.setLevel(logging.DEBUG)

trigger: Union[asyncio.Event, threading.Event] = None
thread = None
loop = None


executor = concurrent.futures.ThreadPoolExecutor(max_workers=8)

num_players_lock = threading.Lock()
next_id_lock = threading.Lock()

# This is an array of strings that will contain jsons that are being sent
layout_jsons_temp = []

# 0 for not sending, 1 for currently sending, don't use the layout if it is 1
layout_jsons_status = []

# Holds json strings that have finished sending
layout_jsons = []

player_id_str_arr = []

latency_function = None
send_latency = None
connection_function = None
controller_function = None
input_function = None

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
                | GATTCharacteristicProperties.write_without_response
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
        }
    },
}

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

def reconstruct_timestamp(sent_ms):
    """Reconstruct possible timestamps based on the last 5 digits."""
    cur_ms = int(time.time() * 1000)
    cur = cur_ms // 100000 * 100000 
    
    possible_times = [cur + sent_ms, cur - 100000 + sent_ms]

    closest_time = min(possible_times, key=lambda ts: abs(ts - cur_ms))
    
    latency = cur_ms - closest_time
    
    return abs(latency)

def map_inputID_to_inputs(json):
    for item in json['wrappedButtons']:
        if not isinstance(item, dict) or 'base' not in item or 'payload' not in item:
            continue
            
        payload = item['payload']
        input_id = payload.get('inputId')
        input_val = payload.get('input')
        
        if input_id is None:
            continue
            
        # Handle D-Pad (special case - maps to all 4 directions)
        if item['base'] == 'dPadConfig':
            inputId_to_inputs[input_id] = {
                AllButtons.up_dpad,
                AllButtons.down_dpad,
                AllButtons.left_dpad,
                AllButtons.right_dpad
            }
            continue
            
        # Handle diamond buttons
        if input_val == 'X':
            inputId_to_inputs[input_id] = AllButtons.top_diamond
        elif input_val == 'B':
            inputId_to_inputs[input_id] = AllButtons.bottom_diamond
        elif input_val == 'Y':
            inputId_to_inputs[input_id] = AllButtons.left_diamond
        elif input_val == 'A':
            inputId_to_inputs[input_id] = AllButtons.right_diamond
            
        # Handle other buttons
        elif input_val == 'LB':
            inputId_to_inputs[input_id] = AllButtons.left_bumper
        elif input_val == 'RB':
            inputId_to_inputs[input_id] = AllButtons.right_bumper
        elif input_val == 'LT':
            inputId_to_inputs[input_id] = AllButtons.left_trigger
        elif input_val == 'RT':
            inputId_to_inputs[input_id] = AllButtons.right_trigger
        elif input_val in ('Start', 'Select', 'Share'):
            inputId_to_inputs[input_id] = AllButtons.options
        elif input_val == 'RT':
            inputId_to_inputs[input_id] = AllButtons.right_trigger
        elif input_val == 'LeftJoystick':
            inputId_to_inputs[input_id] = AllButtons.left_stick
        elif input_val == 'RightJoystick':
            inputId_to_inputs[input_id] = AllButtons.right_stick

def process_latency_characteristic(characteristic):
    # data comes as little endian {Byte, quadword}
    connection_information = unpack("<Bi", characteristic.value)

    player_id = connection_information[0]
    recieved_time = connection_information[1]

    latency = reconstruct_timestamp(int(recieved_time))

    logger.debug(f"Estimated Latency for player {player_id}: {latency} ms")
        
    characteristic.value = str(latency).encode()
        
    if send_latency:
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

            next_id = len(player_id_str_arr)
        
            if requested_id == "Player":
                player_id_str_arr.append(f'Player {next_id}')
            else:
                player_id_str_arr.append(requested_id)

            response_data = pack("<BB", next_id, ConnectionMessage.requesting_id.value)
            characteristic.value = bytearray(response_data)

        if signal == ConnectionMessage.connecting.value:

            print(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.connecting.value])
            input_server.update_controller_state(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.connecting.value])

            print("I am in here\n")

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

            connection_function("connect", player_id_str_arr[player_id], controller_type, layout_jsons[player_id])

        if signal == ConnectionMessage.disconnecting.value:
            # TODO change server to indicate who is leaving
            #print(f"player {player_id} disconnected")
            input_server.update_controller_state(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.disconnecting.value])

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

            player_id_str_arr.pop(player_id)
            layout_jsons_temp.pop(player_id)
            layout_jsons.pop(player_id)
            layout_jsons_status.pop(player_id)

        if signal == ConnectionMessage.transmitting_layout.value:

            size = connection_information[2]

            # Start transmission, remove old layout from buffer
            if size == 255:
                layout_jsons_temp.append("")
                layout_jsons_status.append(1)
                
                response_data = [0, ConnectionMessage.transmitting_layout.value]
                response = bytearray(response_data)
                characteristic.value = response
                return

            # json is done sending
            if size == 0:

                layout_jsons.append(layout_jsons_temp[player_id])
                layout_jsons_temp[player_id] = ""
                layout_jsons_status[player_id] = 0

                json_for_input_id_workaround = json.loads(layout_jsons[player_id])

                map_inputID_to_inputs(json_for_input_id_workaround)

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
    elif size_sent == 0:
        layout_jsons[player_id] = layout_jsons_temp[player_id]
        layout_jsons_temp[player_id] = ""
        layout_jsons_status[player_id] = 0

        json_for_input_id_workaround = json.loads(layout_jsons[player_id])

        map_inputID_to_inputs(json_for_input_id_workaround)

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
        process_latency_characteristic(characteristic)
    elif (upper_uuid == INPUT_CHARACTERISTIC):
        process_input_characteristic(characteristic)
    elif (upper_uuid == CONNECTION_CHARACTERISTIC):
        process_connection_characteristic(characteristic)
    elif (upper_uuid == CONTROLLER_TYPE_CHARACTERISTIC):
        process_controller_characteristic(characteristic)
    else:
        logger.error("ERROR: Unrecognized Write Request")

async def async_write_request(characteristic: BlessGATTCharacteristic, value):
    """Asynchronous wrapper that offloads the processing to a thread."""
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(executor, process_write_request, characteristic, value)
    return

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

    def _start_bg_loop(self):
        asyncio.set_event_loop(self._bg_loop)
        self._bg_loop.run_forever()

    def write_request(self, characteristic: BlessGATTCharacteristic, value):
        """Schedule async processing on the persistent background loop."""
        characteristic.value = value
        asyncio.run_coroutine_threadsafe(
            async_write_request(characteristic, value),
            self._bg_loop
        )
    
    async def start(self):
        logger = logging.getLogger(name=__name__)
        logger.debug("Starting server")
        
        await self.server.add_gatt(gatt)
        await self.server.start(prioritize_local_name=True)
        logger.debug("Advertising")
    
    async def stop(self):
        logger.debug("Stopping server")
        char = self.server.get_characteristic(CONNECTION_CHARACTERISTIC)
        char.value = bytearray([0, 0])
        self.server.update_value(POCKETPAD_SERVICE, CONNECTION_CHARACTERISTIC)
        
        await asyncio.sleep(0.5) # small buffer
        await self.server.stop()

def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    logger.debug(f"Reading {characteristic.uuid} - {characteristic.value}")
    return characteristic.value

# Main function to start the bluetooth server for testing purposes
if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
    logger.debug("[OHNO] Run the server from GUI now please")
