
import asyncio
import logging
import signal
import sys
import bluetooth_server

from bluetooth_server import QBlessServer
from utils import Paircode

#  Generate display  pairing code
paircode = Paircode.reset()
print(f"\n>>> PocketPad Bluetooth pairing code: {paircode.code}\n")

#  server uses exactly that same code
Paircode.reset = lambda: paircode

async def start_bt():
    # Match GUI debug level
    logging.basicConfig(level=logging.DEBUG)
    # Print out every connect/disconnect
    bluetooth_server.set_connection_callback(
        lambda action, player_id, ctrl_type, layout:
        print(f"Bluetooth {action}: {player_id}")
    )
    server = QBlessServer()
    print("Starting Bluetooth server… (Ctrl-C to stop)")
    await server.start()

    # Hold until Ctrl-C
    loop = asyncio.get_event_loop()
    stop = asyncio.Event()
    loop.add_signal_handler(signal.SIGINT, stop.set)
    await stop.wait()

    print("\nStopping Bluetooth server…")
    await server.stop()

if __name__ == "__main__":
    try:
        asyncio.run(start_bt())
    except KeyboardInterrupt:
        sys.exit(0)
