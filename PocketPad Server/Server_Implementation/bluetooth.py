import sys
import logging
import asyncio
import json
import threading
import time
from typing import Any, Dict, Union
from constants import (POCKETPAD_SERVICE, LATENCY_CHARACTERISTIC, 
                       CONNECTION_CHARACTERISTIC, PLAYER_ID_CHARACTERISTIC, 
                       CONTROLLER_TYPE_CHARACTERISTIC, INPUT_CHARACTERISTIC)
from inputs import parse_input

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

class BlessServer(BlessServer):
    async def add_new_descriptor(self, service_uuid, char_uuid, desc_uuid, properties, value, permissions):
        print(f"Adding descriptor {desc_uuid} to {char_uuid} in {service_uuid}")
        return super().add_new_descriptor(service_uuid, char_uuid, desc_uuid, properties, value, permissions)

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(name=__name__)

trigger: Union[asyncio.Event, threading.Event]
if sys.platform in ["darwin", "win32"]:
    trigger = threading.Event()
else:
    trigger = asyncio.Event()

def reconstruct_timestamp(sent_ms):
    """Reconstruct possible timestamps based on the last 5 digits."""
    cur_ms = int(time.time() * 1000)
    cur = cur_ms // 100000 * 100000 
    
    possible_times = [cur + sent_ms, cur - 100000 + sent_ms]

    closest_time = min(possible_times, key=lambda ts: abs(ts - cur_ms))
    
    latency = cur_ms - closest_time
    
    return closest_time, latency


def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    logger.debug(f"Reading {characteristic.uuid} - {characteristic.value}")
    return characteristic.value


def write_request(characteristic: BlessGATTCharacteristic, value: Any, **kwargs):
    characteristic.value = value

    if (characteristic.uuid.upper() == LATENCY_CHARACTERISTIC):
        sent_time, latency = reconstruct_timestamp(int(characteristic.value))

        print(f"Client Sent Time (Reconstructed): {sent_time} ms")
        print(f"Estimated Latency: {latency} ms")

    if (characteristic.uuid.upper() == PLAYER_ID_CHARACTERISTIC):
        print(f"Player: {int(characteristic.value)}")
    
    if (characteristic.uuid.upper() == INPUT_CHARACTERISTIC):
        parse_input(characteristic.value)


async def run(loop):
    trigger.clear()

    # Instantiate the server
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
                    | GATTCharacteristicProperties.write_without_response
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
    if trigger.__module__ == "threading":
        trigger.wait()
    else:
        await trigger.wait()
    await asyncio.sleep(5)
    await server.stop()


loop = asyncio.get_event_loop()
loop.run_until_complete(run(loop))