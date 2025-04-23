import asyncio
import logging
import signal
import sys

from bluetooth_server import QBlessServer

async def start_bt():
    logging.basicConfig(level=logging.DEBUG)
    server = QBlessServer()
    print("Starting Bluetooth server… (Ctrl‑C to stop)")
    await server.start()
    # Keep running until interrupted
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
