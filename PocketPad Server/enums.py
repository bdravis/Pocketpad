from enum import Enum

class ButtonType(Enum):
    REGULAR = 0
    JOYSTICK = 1
    DPAD = 2

class DPadDirection(Enum):
    UP = 0
    DOWN = 1
    LEFT = 2
    RIGHT = 3