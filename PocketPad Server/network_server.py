import asyncio
from functools import cached_property
import logging
import socket
import struct
import json
import base64
from inputs import parse_input, input_error_tuple

from utils import Paircode

from zeroconf.asyncio import AsyncServiceInfo, AsyncZeroconf

from bluetooth_server import paircode
from PySide6.QtCore import QObject

logger = logging.getLogger(__name__)

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
        self.port = 3000
        self.clients = {}
        self.next_id = 0
        self.players = {}
        self.code = Paircode.generate()
        self.update_paircode = None
        
        self.connection_function = None
        self.input_function = None
        
    async def register_service(self):
        self.zeroconf = AsyncZeroconf()
        self.service_info = AsyncServiceInfo(
            "_http._tcp.local.",
            f"PocketPadServer._http._tcp.local.",
            addresses=[socket.inet_aton(self.host)],
            port=self.port
        )
        await self.zeroconf.async_register_service(self.service_info)
    
    async def start(self):
        await self.register_service()
        
        self.server = await asyncio.start_server(self.handle_client, self.host, self.port)
        addr = self.server.sockets[0].getsockname()
        logger.info(f"Server running on {addr}")
        self.update_paircode(self.code)

        
        async with self.server:
            await self.server.serve_forever()
            
    async def handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        addr = writer.get_extra_info('peername')
        logger.debug(f"Accepted connection from {addr}")
        
        self.clients[addr] = writer
        
        waiting_for_pairing = True
        
        try:
            while True:
                data = await reader.read(1024)
                if not data:
                    break
                
                message = json.loads(data.decode())
                
                if waiting_for_pairing:
                    if "paircode" not in message:
                        logger.warning(f"Received invalid pairing message from {addr}: {message}")
                        writer.write(json.dumps({ "status": "disconnect", "err": "Invalid code" }).encode())
                        break
                    code = message["paircode"]
                    if Paircode(int(code)) != self.code:
                        logger.warning(f"Pairing failed for {addr}: invalid code {code}")
                        print(paircode)
                        writer.write(json.dumps({ "status": "disconnect", "err": "Invalid code" }).encode())
                        break
                    logger.info(f"Pairing successful for {addr} with code {code}")
                    writer.write(json.dumps({ "status": "connect", "pid": self.next_id }).encode())
                    
                    with open(".hidden.json", "r") as f:
                        self.connection_function("connect", self.next_id, 1, f.read().strip())
                    
                    self.players[self.next_id] = addr, writer
                    self.next_id += 1
                    waiting_for_pairing = False
                    continue
                
                logger.debug(f"Received {message} from {addr}")
                
                inputs = parse_input(base64.b64decode(message["message"]))

                if inputs == input_error_tuple:
                    logger.error("INVALID INPUT")
                else:
                    player_id, input_id, event = inputs

                    logger.debug("PLAYER ID")
                    logger.debug(player_id)
                    logger.debug("INPUT ID")
                    logger.debug(input_id)
                    logger.debug("EVENT")
                    logger.debug(event)

                    self.input_function(str(player_id), input_id, event)
                
                
        except asyncio.CancelledError:
            pass
        finally:
            logger.debug(f"Closing connection from {addr}")
            writer.close()
            await writer.wait_closed()
            del self.clients[addr]
            logger.info(f"Connection closed from {addr}")
            
        
    
    async def stop(self):
        if self.server:
            for client in self.clients.values():
                try:
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