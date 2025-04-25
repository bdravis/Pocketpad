import os
import re
import asyncio
from dataclasses import dataclass
from functools import cached_property
from ipaddress import ip_address
import logging
import socket
import struct
import json
import base64
import enums
import sys
import psutil
import game_database as gdb

import ifaddr
from inputs import parse_input, map_inputID_to_inputs
from dsu_server import DSU_Server

from utils import Paircode

from zeroconf.asyncio import AsyncServiceInfo, AsyncZeroconf

from PySide6.QtCore import QObject

logger = logging.getLogger(__name__)

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
    core, *_ = full_path.rsplit*(" ", 1)
    file_name = os.path.basename(core)
    name, _ = os.path.splitext*(file_name)
    cleaned = re.sub(r'\s*[\(\[].*?[\)\]])]\s*$', '', name).strip()
    return cleaned

# async def prefixed_send(writer: asyncio.StreamWriter, payload: bytes) -> None:
#     """
#     Send a 4-byte big-endian length prefix followed by the payload.
#     """
#     prefix = struct.pack('>I', len(payload))  # big-endian unsigned int :contentReference[oaicite:4]{index=4}
#     writer.write(prefix + payload)             # queue in StreamWriter buffer :contentReference[oaicite:5]{index=5}
#     await writer.drain()                       # ensure it’s sent :contentReference[oaicite:6]{index=6}

# async def read_message(reader: asyncio.StreamReader) -> bytes:
#     """
#     Read one length-prefixed message: first 4 bytes → size, then size bytes → payload.
#     """
#     prefix = await reader.readexactly(4)           # read 4-byte length :contentReference[oaicite:7]{index=7}
#     size = struct.unpack('>I', prefix)[0]          # unpack big-endian uint :contentReference[oaicite:8]{index=8}
#     data = await reader.readexactly(size)          # read the JSON frame :contentReference[oaicite:9]{index=9}
#     return data

@dataclass
class Player:
    id: int
    name: str
    addr: str
    layout_json: dict = None

class QNetworkServer(QObject):
    _instance = None
    
    @staticmethod
    def instance():
        if QNetworkServer._instance is None:
            QNetworkServer._instance = QNetworkServer()
        return QNetworkServer._instance
    
    def __init__(self):
        super().__init__()
        self.server = None
        self.host = "0.0.0.0"
        self.port = 12683
        self.clients = {}
        self.next_id = 0
        self.players: dict[Player] = {}
        
        self.layout_jsons = []

        self.current_game = None
        
        self.connection_function = None
        self.input_function = None
        self.game_function = None
        self.controller_function = None
        
    async def register_service(self):
        self.zeroconf = AsyncZeroconf()
        
        # Get all IP addresses from all interfaces
        ipv4_addresses = []
        ipv6_addresses = []
        
        for adapter in ifaddr.get_adapters():
            for ip in adapter.ips:
                try:
                    addr = ip_address(ip.ip[0] if isinstance(ip.ip, tuple) else ip.ip)
                    if addr.version == 4:
                        ipv4_addresses.append(socket.inet_pton(socket.AF_INET, str(addr)))
                    elif addr.version == 6:
                        # Skip link-local addresses if you don't need them
                        if not addr.is_link_local:
                            ipv6_addresses.append(socket.inet_pton(socket.AF_INET6, str(addr)))
                except (ValueError, AttributeError):
                    continue
        
        # Combine all addresses
        all_addresses = ipv4_addresses + ipv6_addresses
        
        # If no addresses found, fall back to IPv4 and IPv6 any addresses
        all_addresses += [
            socket.inet_pton(socket.AF_INET, "0.0.0.0"),
            socket.inet_pton(socket.AF_INET6, "::")
        ]
            
        self.service_info = AsyncServiceInfo(
            "_http._tcp.local.",
            f"PocketPadServer._http._tcp.local.",
            addresses=all_addresses,
            port=self.port
        )
        logger.info(f"Registering service with info: {self.service_info}")
        logger.info(f"Service info addresses: {self.service_info.addresses}")
        await self.zeroconf.async_register_service(
            self.service_info,
            allow_name_change=True,
            cooperating_responders=False,
            strict=True
        )
    
    async def start(self):
        self.next_id = 0
        await self.register_service()
        
        self.code = Paircode.reset()
        
        self.server = await asyncio.start_server(self.handle_client, self.host, self.port)
        addr = self.server.sockets[0].getsockname()
        logger.info(f"Server running on {addr}")

        self._monitor_task = asyncio.create_task(self.dolphin_monitor())
        
        try:
            async with self.server:
                await self.server.serve_forever()
        except asyncio.CancelledError:
            logger.info("Server stopped.")
            
    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        addr = writer.get_extra_info('peername')
        logger.debug(f"Accepted connection from {addr}")
        
        self.clients[addr] = writer
        
        waiting_for_pairing = True
        
        try:
            while True:
                data = await reader.read(2 ** 16)
                if not data:
                    break

                data = data.decode()
                queue = data[1:-1].split("}{")
                for i in range(len(queue)):
                    queue[i] = "{" + queue[i] + "}"
                print(queue)
                for msg in queue:
                    message = json.loads(msg)
                    
                    logger.debug(f"Received {message} from {addr}")
                    
                    if waiting_for_pairing:
                        if "paircode" not in message:
                            logger.warning(f"Received invalid pairing message from {addr}: {message}")
                            writer.write(json.dumps({ "status": "disconnect", "error": "Invalid code" }).encode())
                            break
                        code = message["paircode"]
                        if Paircode(int(code)) != self.code:
                            logger.warning(f"Pairing failed for {addr}: invalid code {code}")
                            writer.write(json.dumps({ "status": "disconnect", "error": "Invalid code" }).encode())
                            break
                        logger.info(f"Pairing successful for {addr}")
                        
                        waiting_for_pairing = False
                        
                        writer.write(json.dumps({ "status": "pair_success" }).encode())
                        
                        continue
                    
                    if "request_id" in message:
                        requested = message["request_id"]
                        if requested in self.players:
                            logger.warning(f"Received duplicate request from {addr}")
                            writer.write(json.dumps({ "status": "disconnect", "error": "Player ID taken" }).encode())
                            break
                        
                        if requested == "Player":
                            requested = f"Player {self.next_id}"
                        self.players[self.next_id] = Player(self.next_id, requested, addr)
                        self.next_id += 1
                        
                        logger.info(f"Player \"{requested}\" connected from {addr} - ID: {self.next_id}")
                        
                        writer.write(json.dumps({ "status": "connect", "pid": self.next_id - 1 }).encode())
                        DSU_Server.instance().update_controller_state(self.next_id - 1, enums.ControllerUpdateTypes.CONNECTION.value, [1])
                    elif "layout" in message:
                        pid = message["pid"]
                        controller_type = enums.ControllerType(message["controller_type"])
                        player = self.players[pid]
                        player.layout_json = base64.b64decode(message["layout"]).decode()
                        
                        map_inputID_to_inputs(json.loads(player.layout_json))
                        
                        self.connection_function("connect", player.name, controller_type, player.layout_json)
                    elif "new_layout" in message:
                        pid = message["pid"]
                        player = self.players[pid]
                        controller_type = enums.ControllerType(message["controller_type"])
                        player.layout_json = base64.b64decode(message["new_layout"]).decode()
                        
                        map_inputID_to_inputs(json.loads(player.layout_json))
                        
                        self.controller_function(player.name, controller_type, player.layout_json)
                    elif "input" in message:
                        pid = message["pid"]
                        player = self.players[pid]
                        res = parse_input(base64.b64decode(message["input"]))
                        if res == None:
                            pass
                        if res[0] == -1:
                            logger.error("INVALID INPUT")
                        else:
                            self.input_function(self.players[pid].name, res[1], res[2])
                    # elif "request_layout" in message:
                    #     layout_str = gdb.get_controller_layout(self.current_game)

                        # 2) If none, send an empty header and return
                        # if layout_str is None:
                            # writer.write(json.dumps({ "status": "layout" }).encode())
                            # await prefixed_send(writer, header)
                            # return

                        # 3) Base64-encode the JSON to keep it ASCII-safe
                        # layout_b64 = base64.b64encode(layout_str.encode('utf-8'))
                        # total_len = len(layout_b64)
                        # chunk_size = 2048

                        # # 4) Send header frame
                        # header = json.dumps({
                        #     "status": "layout",
                        #     "file_size": total_len,
                        #     "chunk_size": chunk_size
                        # }).encode('utf-8')
                        # await prefixed_send(writer, header)  # :contentReference[oaicite:10]{index=10}

                        # # 5) Send each chunk with its offset
                        # for offset in range(0, total_len, chunk_size):
                        #     chunk = layout_b64[offset:offset + chunk_size]
                        #     chunk_msg = json.dumps({
                        #         "status": "layout_chunk",
                        #         "offset": offset,
                        #         "data": chunk.decode('ascii')
                        #     }).encode('utf-8')
                        #     await prefixed_send(writer, chunk_msg)  # :contentReference[oaicite:11]{index=11}

                        # # 6) Send completion frame
                        # complete = json.dumps({"status": "layout_complete"}).encode('utf-8')
                        # await prefixed_send(writer, complete)

        except asyncio.CancelledError:
            pass
        finally:
            DSU_Server.instance().update_controller_state(self.next_id - 1, enums.ControllerUpdateTypes.CONNECTION.value, [2])
            pops = []
            writer.write(json.dumps( {"status": "disconnect", "error": "Malformed Data Sent"}).encode())
            for k, v in self.players.items():
                if v.addr == addr:
                    self.connection_function("disconnect", v.name, None, None)
                    pops.append(k)
            
            for k in pops:
                del self.players[k]
            
            logger.debug(f"Closing connection from {addr}")
            writer.close()
            try:
                await writer.wait_closed()
            except ConnectionResetError:
                pass
            del self.clients[addr]
            logger.info(f"Connection closed from {addr}")
            
    async def dolphin_monitor(self):
        last_game = None
        while True:
            while not dolphin_is_running():
                await asyncio.sleep(5)
            while dolphin_is_running():
                game = get_current_dolphin_game()
                if game != last_game:
                    last_game = game
                    await self.request_game_data(game)
                await asyncio.sleep(30)
            last_game = None
            self.request_game_data(None)
    
    async def stop(self):
        if self.server:
            for client in list(self.clients.values())[:]:
                try:
                    client.write(json.dumps({"status": "disconnect", "error": "Server shutdown"}).encode())
                    client.close()
                    await client.wait_closed()
                except Exception as e:
                    logger.error(f"Error closing client connection: {e}")
                    
            self.clients.clear()

            self.server.close()
            await self.server.wait_closed()
            
            if self.zeroconf and self.service_info:
                await self.zeroconf.async_unregister_service(self.service_info)
                await self.zeroconf.async_close()

            if hasattr(self, "_monitor_task"):
                self._monitor_task.cancel()
                try:
                    await self._monitor_task
                except asyncio.CancelledError:
                    pass
            
            logger.info("Server stopped.")

    async def request_game_data(self, game: str):
        self.current_game = game
        await self.game_function(game)