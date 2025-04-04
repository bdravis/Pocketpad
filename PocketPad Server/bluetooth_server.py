from functools import cached_property
import sys
import logging
import asyncio
import json
import threading
import time
import enums
from struct import unpack
from typing import Any, Dict, Union
from server_constants import *
from inputs import parse_input, input_error_tuple

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

from PySide6.QtCore import QObject
from dataclasses import dataclass

from random import randint

logger = None
trigger: Union[asyncio.Event, threading.Event] = None
thread = None
loop = None

paircode = "xxx xxx"

num_players = 0
next_id = 0
num_players_lock = threading.Lock()
next_id_lock = threading.Lock()

# This is an array of strings that will contain jsons that are being sent
layout_jsons_temp = [""]

# 0 for not sending, 1 for currently sending, don't use the layout if it is 1
layout_jsons_status = [0]

# Holds json strings that have finished sending
layout_jsons = [""]

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
                | GATTCharacteristicProperties.write
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
        
        PAIRCODE_CHARACTERISTIC: {
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

        # Store an id to differentiate between connected players

        PLAYER_ID_CHARACTERISTIC: {
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

class BlessServer(BlessServer):
    async def add_new_descriptor(self, service_uuid, char_uuid, desc_uuid, properties, value, permissions):
        print(f"Adding descriptor {desc_uuid} to {char_uuid} in {service_uuid}")
        return super().add_new_descriptor(service_uuid, char_uuid, desc_uuid, properties, value, permissions)

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

def remove_duplicate_id(player_id):
    print("Removing Duplicate User")

def reconstruct_timestamp(sent_ms):
    """Reconstruct possible timestamps based on the last 5 digits."""
    cur_ms = int(time.time() * 1000)
    cur = cur_ms // 100000 * 100000 
    
    possible_times = [cur + sent_ms, cur - 100000 + sent_ms]

    closest_time = min(possible_times, key=lambda ts: abs(ts - cur_ms))
    
    latency = cur_ms - closest_time
    
    return closest_time, abs(latency)


def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    logger.debug(f"Reading {characteristic.uuid} - {characteristic.value}")
    return characteristic.value
    
def write_request(characteristic: BlessGATTCharacteristic, value: Any):
    print(f"Writing {characteristic.uuid} - {value}")
    
    __server = QBlessServer.instance()
    
    characteristic.value = value

    global num_players
    global next_id

    global layout_jsons
    global layout_jsons_temp
    global layout_jsons_status

    if (characteristic.uuid.upper() == LATENCY_CHARACTERISTIC):

        # data comes as little endian {Byte, quadword}
        format_str = "<Bi"
        connection_information = unpack(format_str, characteristic.value)

        player_id = connection_information[0]
        now = connection_information[1]

        sent_time, latency = reconstruct_timestamp(int(now))

        print(f"Client Sent Time (Reconstructed): {sent_time} ms")
        print(f"Estimated Latency for player {player_id}: {latency} ms")
        
        characteristic.value = str(latency).encode()
        
        if send_latency:
            latency_function(str(player_id), latency)
        
        # server.update_value(POCKETPAD_SERVICE, LATENCY_CHARACTERISTIC)

        return

    characteristic.value = value
    
    if (characteristic.uuid.upper() == PLAYER_ID_CHARACTERISTIC):
        print(f"Player: {int(characteristic.value)}")
    
    if (characteristic.uuid.upper() == INPUT_CHARACTERISTIC):
        # Check if this is a motion data packet
        # Our motion packet is expected to be 14 bytes:
        # [playerId (1 byte), motionEvent (1 byte, equals 99), pitch (4 bytes), roll (4 bytes), yaw (4 bytes)]
        if len(characteristic.value) == 14:
            player_id = characteristic.value[0]
            event_code = characteristic.value[1]
            if event_code == 99:
                import struct
                pitch = struct.unpack('<f', characteristic.value[2:6])[0]
                roll  = struct.unpack('<f', characteristic.value[6:10])[0]
                yaw   = struct.unpack('<f', characteristic.value[10:14])[0]
                print(f"Motion Data Received from player {player_id}: pitch = {pitch:.2f}, roll = {roll:.2f}, yaw = {yaw:.2f}")
                return  
      
      # Implement a way to extract a value corresponding to player characteristic
        #
        input_result = parse_input(characteristic.value)

        if input_result == input_error_tuple:
            logger.error("INVALID INPUT")
        else:
            player_id, input_id, event = input_result

            logger.debug("PLAYER ID")
            logger.debug(player_id)
            logger.debug("INPUT ID")
            logger.debug(input_id)
            logger.debug("EVENT")
            logger.debug(event)

            input_function(str(player_id), input_id, event)

    if (characteristic.uuid.upper() == CONNECTION_CHARACTERISTIC):

        # encoded as a tuple so we can expand this packet with more information

        data_length_in_bytes = len(characteristic.value)
        format_str = "B" * data_length_in_bytes
        connection_information = unpack(format_str, characteristic.value)

        player_id = connection_information[0]
        signal = connection_information[1]
        controller_type = connection_information[2]

        with num_players_lock:
            if signal == ConnectionMessage.connecting.value:

                print("I am in here\n")
                # Perhaps send playerid back here or at least generate it
                #print(f"player {next_id} connected")

                response_data = [next_id, ConnectionMessage.connecting.value]
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

                connection_function("connect", str(next_id), controller_type, layout_jsons[player_id])
                num_players += 1
                next_id += 1
                layout_jsons.append("")
                layout_jsons_temp.append("")
                layout_jsons_status.append(0)

            if signal == ConnectionMessage.disconnecting.value:
                # TODO change server to indicate who is leaving
                #print(f"player {player_id} disconnected")
                num_players -= 1

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
                connection_function("disconnect", str(player_id), None, None)

            if signal == ConnectionMessage.transmitting_layout.value:

                size = connection_information[2]

                # Start transmission, remove old layout from buffer
                if size == 255:
                    layout_jsons_temp[player_id] = ""
                    layout_jsons_status[player_id] = 1

                    # Pretty sure I need to send something back to the server
                    response_data = [0, ConnectionMessage.transmitting_layout.value]
                    response = bytearray(response_data)
                    characteristic.value = response

                    return

                # json is done sending
                if size == 0:

                    layout_jsons[player_id] = layout_jsons_temp[player_id]
                    layout_jsons_temp[player_id] = ""
                    layout_jsons_status[player_id] = 0

                    # Pretty sure I need to send something back to the server
                    response_data = [0, ConnectionMessage.transmitting_layout.value]
                    response = bytearray(response_data)
                    characteristic.value = response

                    return

                data_length_in_bytes = len(characteristic.value)
                format_str = "3B" + f"{size}s"
                connection_information = unpack(format_str, characteristic.value)

                json_string = str(connection_information[3])
                layout_jsons_temp[player_id] += json_string[2:-1:]

                response_data = [0, ConnectionMessage.transmitting_layout.value]
                response = bytearray(response_data)
                characteristic.value = response
                

    if characteristic.uuid.upper() == PAIRCODE_CHARACTERISTIC:
        data_length_in_bytes = len(characteristic.value)
        format_str = "B" * data_length_in_bytes
        information = unpack(format_str, characteristic.value)

        logger.debug("Received PAIRCODE", information)
        
        player_id = information[0]
        code = list(map(chr, information[1:]))
        code_str = ''.join(code[:3]).zfill(3) + " " + ''.join(code[3:6]).zfill(3)
        print( f"Received Paircode: {code_str} from player {player_id}")
        print(paircode)
        if code_str != paircode:
            char = __server.server.get_characteristic(CONNECTION_CHARACTERISTIC)
            char.value = bytearray([player_id, 0]) + bytearray("Paircode Incorrect".encode('utf-8'))
            __server.server.update_value(POCKETPAD_SERVICE, CONNECTION_CHARACTERISTIC)
        
            connection_function("disconnect", str(player_id), None, None)
        
        return

logger = logging.getLogger(name=__name__)

@dataclass
class QBlessServer(QObject):
    _instance = None
    
    @staticmethod
    def instance():
        """Singleton instance of QBlessServer."""
        if QBlessServer._instance is None:
            QBlessServer._instance = QBlessServer()
            logger.debug("Created new QBlessServer instance")
        return QBlessServer._instance
    
    @cached_property
    def server(self) -> BlessServer:
        server = BlessServer(name="PocketPad")
        
        server.read_request_func = read_request
        server.write_request_func = write_request
        
        return server
    
    async def initialize(self):
        await self.server.add_gatt(gatt)
        logger.debug("BLE Server initialized")
    
    async def start(self):
        logger = logging.getLogger(name=__name__)
        logger.debug("Starting server")
        
        global paircode
        paircode = str(randint(000, 999)).zfill(3) + " " + str(randint(000, 999)).zfill(3)
        
        await self.server.add_gatt(gatt)
        await self.server.start(prioritize_local_name=True)
        logger.debug("Advertising")
    
    async def stop(self):
        global next_id
        
        logger.debug("Stopping server")
        char = self.server.get_characteristic(CONNECTION_CHARACTERISTIC)
        char.value = bytearray([255, 0]) + bytearray("Server Shutdown".encode('utf-8'))
        self.server.update_value(POCKETPAD_SERVICE, CONNECTION_CHARACTERISTIC)
        
        await asyncio.sleep(0.5) # small buffer
        
        next_id = 0

        await self.server.stop()

# Main function to start the bluetooth server for testing purposes
if __name__ == "__main__":
    print("[OHNO] Run the server from GUI now please")
    # logging.basicConfig(level=logging.DEBUG)

    # if sys.platform in ["darwin", "win32"]:
    #     trigger = threading.Event()
    # else:
    #     trigger = asyncio.Event()

    # loop = asyncio.new_event_loop()
    # asyncio.set_event_loop(loop)

    # try:
    #     loop.run_until_complete(run(loop))  # Ensure `run(loop)` correctly starts the server
    # except KeyboardInterrupt:
    #     print("Server shutting down...")
    # finally:
    #     loop.close()
