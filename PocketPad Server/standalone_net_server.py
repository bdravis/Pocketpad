
import asyncio
import logging
import signal
import sys

from dsu_server import DSU_Server
from network_server import QNetworkServer
from utils import Paircode


paircode = Paircode.reset()
print(f"\n>>> PocketPad Network pairing code: {paircode.code}\n")
# Make sure the server uses exactly that code
Paircode.reset = lambda: paircode

async def start_net():

    logging.basicConfig(level=logging.DEBUG)


    DSU_Server.instance().start()
    print(f"DSU UDP server listening on port {DSU_Server.instance().port}")

    #Start the JSON/TCP PocketPad server
    net = QNetworkServer.instance()

    #Register all callbacks to avoid NoneType errors
    net.connection_function = lambda action, player, ctrl, layout: \
        print(f"[Network] {action.upper():9} → {player}")
    net.input_function      = lambda player, btn, evt: \
        print(f"[Input]   {player}: button={btn}, event={evt}")
    net.controller_function = lambda player, ctrl, layout: \
        print(f"[Ctrlchg] {player}: new type={ctrl}")
    net.game_function       = lambda game: \
        print(f"[Game]    Now playing: {game}")

    print("Starting PocketPad Network server… (Ctrl-C to stop)")
    await net.start()

    #Wait for Ctrl-C
    stop = asyncio.Event()
    loop = asyncio.get_event_loop()
    loop.add_signal_handler(signal.SIGINT, stop.set)
    await stop.wait()

    # Clean shutdown
    print("\nStopping PocketPad Network server…")
    await net.stop()

if __name__ == "__main__":
    try:
        asyncio.run(start_net())
    except KeyboardInterrupt:
        sys.exit(0)
