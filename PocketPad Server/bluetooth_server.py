import sys
import logging
import asyncio
import json
import threading
import time
import enums
from struct import unpack
from typing import Any, Dict, Union
from server_constants import (POCKETPAD_SERVICE, LATENCY_CHARACTERISTIC, 
                       CONNECTION_CHARACTERISTIC, PLAYER_ID_CHARACTERISTIC, 
                       CONTROLLER_TYPE_CHARACTERISTIC, INPUT_CHARACTERISTIC,
                       ConnectionMessage)
from inputs import parse_input

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

logger = None
trigger: Union[asyncio.Event, threading.Event] = None
thread = None
loop = None

num_players = 0
next_id = 0
num_players_lock = threading.Lock()
next_id_lock = threading.Lock()

latency_function = None
send_latency = None
connection_function = None
controller_function = None
input_function = None

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
    
    characteristic.value = value

    global num_players
    global next_id

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
        # Implement a way to extract a value corresponding to player characteristic
        #
        parse_input(characteristic.value)
        input = None # Fix this to have it be the input 
        #
        # Implement a way to extract a value corresponding to player characteristic

        # player_id = connection_information[0]

        # input_function(player_id, input)



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

                # I do not know if this is going to work
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

                connection_function("connect", str(next_id), controller_type)
                num_players += 1
                next_id += 1

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
                connection_function("disconnect", str(player_id), controller_type)



async def run(loop):
    global logger, trigger
    
    trigger.clear()

    # Instantiate the server
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
    my_service_name = "PocketPad"
    server = BlessServer(name=my_service_name, loop=loop)

    server.read_request_func = read_request
    server.write_request_func = write_request
    
    await server.add_gatt(gatt)
    await server.start(prioritize_local_name=True)
    logger.debug("Advertising")
    #if trigger.__module__ == "threading":
    #    trigger.wait()
    #else:
    await trigger.wait()
    await asyncio.sleep(5)
    await server.stop()

logger = logging.getLogger(name=__name__)

#   This function is starts advertising the BLESS server to 
#   the users creating a thread for an instance of the server
#   loop
#
#   @param: NONE
#
#   @return: NONE
#
def start_server():
    global logger, trigger, thread, loop
    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger(__name__)

    #if sys.platform in ["darwin", "win32"]:
    #    trigger = threading.Event()
    #else:
    trigger = asyncio.Event()

    loop = asyncio.new_event_loop()

    def run_loop():
        asyncio.set_event_loop(loop)
        loop.run_until_complete(run(loop))
        loop.close()

    thread = threading.Thread(target=run_loop, daemon=True)
    thread.start()

# NEEDS WORK
def stop_server():
    global trigger, thread, loop
    logger.info("Shutting Down Server")
    if trigger and loop:
        loop.call_soon_threadsafe(trigger.set)
        #trigger.set()  # Signal the server loop to stop

    if thread and thread.is_alive():
        thread.join()  # Ensure the server thread is properly stopped

    if loop and loop.is_running():
        loop.call_soon_threadsafe(loop.stop)
# NEEDS WORK

# Main function to start the bluetooth server for testing purposes
if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    if sys.platform in ["darwin", "win32"]:
        trigger = threading.Event()
    else:
        trigger = asyncio.Event()

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)

    try:
        loop.run_until_complete(run(loop))  # Ensure `run(loop)` correctly starts the server
    except KeyboardInterrupt:
        print("Server shutting down...")
    finally:
        loop.close()
