from functools import cached_property
import sys
import logging
import asyncio
import json
import threading
import time
import enums
from enums import AllButtons, ControllerUpdateTypes
from struct import unpack, pack
from typing import Any, Dict, Union
from server_constants import (POCKETPAD_SERVICE, LATENCY_CHARACTERISTIC, 
                       CONNECTION_CHARACTERISTIC, PLAYER_ID_CHARACTERISTIC, 
                       CONTROLLER_TYPE_CHARACTERISTIC, INPUT_CHARACTERISTIC,
                       ConnectionMessage)
from inputs import parse_input, input_error_tuple
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

logger = None
trigger: Union[asyncio.Event, threading.Event] = None
thread = None
loop = None

#num_players = 0
#next_id = 0
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


def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    logger.debug(f"Reading {characteristic.uuid} - {characteristic.value}")
    return characteristic.value
    
def write_request(characteristic: BlessGATTCharacteristic, value: Any):
    print(f"Writing {characteristic.uuid} - {value}")
    
    characteristic.value = value

    global num_players
    global next_id

    global layout_jsons
    global layout_jsons_temp
    global layout_jsons_status

    if (characteristic.uuid.upper() == LATENCY_CHARACTERISTIC):

        print("receive latency")

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
            latency_function(player_id_str_arr[player_id], latency)
        
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

                input_server.update_controller_state(player_id, ControllerUpdateTypes.MOTION.value, [pitch, yaw, roll])

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

            input_function(player_id_str_arr[player_id], input_id, event)

    if (characteristic.uuid.upper() == CONNECTION_CHARACTERISTIC):

        # encoded as a tuple so we can expand this packet with more information

        print("CONNECTION_CHARACTERISTIC written to")

        data_length_in_bytes = len(characteristic.value)
        format_str = "B" * data_length_in_bytes
        connection_information = unpack(format_str, characteristic.value)

        player_id = connection_information[0]
        signal = connection_information[1]
        controller_type = connection_information[2]

        print(connection_information)

        with num_players_lock:

            if signal == ConnectionMessage.requesting_id.value:

                print("received request")

                #connection_information = unpack("BBB", characteristic.value[:3])
                #id_fstring = f'{connection_information[2]}B'
                #requested_id = str(unpack(id_fstring, characteristic.value[3:3+connection_information[2]]))

                string_bytes = characteristic.value[3:3+connection_information[2]]
                requested_id = ''.join([chr(byte) for byte in string_bytes])

                if requested_id in player_id_str_arr:
                    # DUPLICATE ID

                    print("duplicate id detected, try again with a different id")

                    response_data = pack("<BB", 255, ConnectionMessage.requesting_id.value)

                    characteristic.value = bytearray(response_data)
                    return

                """
                player_id_str_arr.append("")
                layout_jsons.append("")
                layout_jsons_temp.append("")
                layout_jsons_status.append(0)

                if requested_id == "Player":
                    player_id_str_arr[next_id] = f'Player {next_id}'
                else:
                    player_id_str_arr[next_id] = requested_id
                """

                next_id = len(player_id_str_arr)
    
                if requested_id == "Player":
                    player_id_str_arr.append(f'Player {next_id}')
                else:
                    player_id_str_arr.append(requested_id)

                print("approved request: ", next_id)
                response_data = pack("<BB", next_id, ConnectionMessage.requesting_id.value)
                characteristic.value = bytearray(response_data)

                #next_id += 1
                #num_players += 1

            if signal == ConnectionMessage.connecting.value:

                print(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.connecting.value])
                input_server.update_controller_state(player_id, ControllerUpdateTypes.CONNECTION.value, [ConnectionMessage.connecting.value])

                print("I am in here\n")
                # Perhaps send playerid back here or at least generate it
                #print(f"player {next_id} connected")

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

                print("connection callback")
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
                #num_players -= 1


            if signal == ConnectionMessage.transmitting_layout.value:

                size = connection_information[2]

                # Start transmission, remove old layout from buffer
                if size == 255:
                    #layout_jsons_temp[player_id] = ""
                    #layout_jsons_status[player_id] = 1
                    layout_jsons_temp.append("")
                    print("append temp: ", len(layout_jsons_temp))
                    layout_jsons_status.append(1)

                    # Pretty sure I need to send something back to the server
                    response_data = [0, ConnectionMessage.transmitting_layout.value]
                    response = bytearray(response_data)
                    characteristic.value = response

                    return

                # json is done sending
                if size == 0:

                    layout_jsons.append(layout_jsons_temp[player_id])
                    #layout_jsons[player_id] = layout_jsons_temp[player_id]
                    layout_jsons_temp[player_id] = ""
                    layout_jsons_status[player_id] = 0

                    print(layout_jsons[player_id])
                    print("that was th json")
                    json_for_input_id_workaround = json.loads(layout_jsons[player_id])

                    map_inputID_to_inputs(json_for_input_id_workaround)

                    # Pretty sure I need to send something back to the server
                    response_data = [0, ConnectionMessage.transmitting_layout.value]
                    response = bytearray(response_data)
                    characteristic.value = response

                    return

                data_length_in_bytes = len(characteristic.value)
                format_str = "3B" + f"{size}s"
                connection_information = unpack(format_str, characteristic.value)

                print(player_id, len(layout_jsons_temp))
                json_string = str(connection_information[3])
                layout_jsons_temp[player_id] += json_string[2:-1:]

                response_data = [0, ConnectionMessage.transmitting_layout.value]
                response = bytearray(response_data)
                characteristic.value = response

logger = logging.getLogger(name=__name__)

@dataclass
class QBlessServer(QObject):
    @cached_property
    def server(self):
        server = BlessServer(name="PocketPad")
        
        server.read_request_func = read_request
        server.write_request_func = write_request
        
        return server
    
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

# Main function to start the bluetooth server for testing purposes
if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
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
