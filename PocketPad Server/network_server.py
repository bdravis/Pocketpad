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

import ifaddr
from inputs import parse_input, map_inputID_to_inputs
from dsu_server import DSU_Server

from utils import Paircode

from zeroconf.asyncio import AsyncServiceInfo, AsyncZeroconf

from PySide6.QtCore import QObject

logger = logging.getLogger(__name__)

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
        await self.zeroconf.async_register_service(self.service_info)
    
    async def start(self):
        self.next_id = 0
        await self.register_service()
        
        self.code = Paircode.reset()
        
        self.server = await asyncio.start_server(self.handle_client, self.host, self.port)
        addr = self.server.sockets[0].getsockname()
        logger.info(f"Server running on {addr}")
        
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
            
            logger.info("Server stopped.")