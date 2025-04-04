from enum import Enum

# This is the UUID that designates the device with PocketPad.
# The client can filter out all devices that don't have this UUID.
POCKETPAD_SERVICE = "4AF8BC29-479B-4492-980A-45BFAAA2FAB6"

# Characteristic UUIDs
LATENCY_CHARACTERISTIC = "BFC0C92F-317D-4BA9-976B-CC11CE77B4CA"
CONNECTION_CHARACTERISTIC = "EA946B3E-D83D-4804-9DC4-A33A768868C8"
PLAYER_ID_CHARACTERISTIC = "D95A2FA4-22AC-4858-9F3F-008D6D87271E"
CONTROLLER_TYPE_CHARACTERISTIC = "366B5778-9B7E-4D98-B952-A8852B11FA77"
INPUT_CHARACTERISTIC = "E576715C-1C73-4237-8CA6-6625C28FB3DC"

class ConnectionMessage(Enum):
    received = 0
    connecting = 1
    disconnecting = 2
    transmitting_layout = 3
    requesting_id = 4
