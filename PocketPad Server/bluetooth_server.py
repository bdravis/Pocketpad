import sys
import logging
import asyncio
import json
import threading
import time
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

latency_function = None
connection_function = None
controller_function = None


class BlessServer(BlessServer):
    async def add_new_descriptor(self, service_uuid, char_uuid, desc_uuid, properties, value, permissions):
        print(f"Adding descriptor {desc_uuid} to {char_uuid} in {service_uuid}")
        return super().add_new_descriptor(service_uuid, char_uuid, desc_uuid, properties, value, permissions)

def set_latency_callback(latency_function_callback):
    global latency_function
    latency_function = latency_function_callback

def set_connection_callback(connection_function_callback):
    global connection_function
    connection_function = connection_function_callback

def set_controller_callback(controller_function_callback):
    global controller_function
    controller_function = controller_function_callback

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

    if (characteristic.uuid.upper() == LATENCY_CHARACTERISTIC):
        sent_time, latency = reconstruct_timestamp(int(value))

        print(f"Client Sent Time (Reconstructed): {sent_time} ms")
        print(f"Estimated Latency: {latency} ms")
        
        characteristic.value = str(latency).encode()
        
        # server.update_value(POCKETPAD_SERVICE, LATENCY_CHARACTERISTIC)

        return

    characteristic.value = value
    
    if (characteristic.uuid.upper() == PLAYER_ID_CHARACTERISTIC):
        print(f"Player: {int(characteristic.value)}")
    
    if (characteristic.uuid.upper() == INPUT_CHARACTERISTIC):
        parse_input(characteristic.value)

    if (characteristic.uuid.upper() == CONNECTION_CHARACTERISTIC):

        # encoded as a tuple so we can expand this packet with more information

        data_length_in_bytes = len(characteristic.value)
        format_str = "B" * data_length_in_bytes
        connection_information = unpack(format_str, characteristic.value)

        characteristic.value = bytearray(ConnectionMessage.received.value)

        if connection_information[0] == ConnectionMessage.connecting.value:
            # Perhaps send playerid back here or at least generate it
            print("player connected")
        if connection_information[0] == ConnectionMessage.disconnecting.value:
            print("player disconnected")

def write_request(characteristic: BlessGATTCharacteristic, value: Any, **kwargs):
    global latency_function, connection_function, controller_function
    characteristic.value = value

    # if (characteristic.uuid.upper() == LATENCY_CHARACTERISTIC):
    #     sent_time, latency = reconstruct_timestamp(int(characteristic.value))

    #     print(f"Client Sent Time (Reconstructed): {sent_time} ms")
    #     print(f"Estimated Latency: {latency} ms")
    #     latency_function(f"{player_id}", latency)

    if (characteristic.uuid.upper() == PLAYER_ID_CHARACTERISTIC):
        print(f"Player: {int(characteristic.value)}")
    
    if (characteristic.uuid.upper() == INPUT_CHARACTERISTIC):
        parse_input(characteristic.value)

    # if (characteristic.uuid.upper() == CONNECTION_CHARACTERISTIC):

    #     # encoded as a tuple so we can expand this packet with more information

    #     data_length_in_bytes = len(characteristic.value)
    #     format_str = "B" * data_length_in_bytes
    #     connection_information = unpack(format_str, characteristic.value)

    #     characteristic.value = bytearray(ConnectionMessage.received.value)

    #     if connection_information[0] == ConnectionMessage.connecting.value:
    #         # Perhaps send playerid back here or at least generate it
    #         print("player connected")
    #         connection_function("connect", f"{player_id}", f"{controller_type}")

    #     if connection_information[0] == ConnectionMessage.disconnecting.value:
    #         print("player disconnected")
    #         connection_function("disconnect", f"{player_id}", f"{controller_type}")

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

    #if loop and loop.is_running():
    #    loop.call_soon_threadsafe(loop.stop)
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
