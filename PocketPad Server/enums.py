# This file contains basic enums for config structs
# Enums for config styles can be found in config_styles.py
# ButtonType, DPadDirection, ButtonEvent
# 
# Created by Jack

from enum import Enum

class ControllerType(Enum):
    Xbox = 0
    Playstation = 1
    Wii = 2
    Switch = 3
    DPadless = 4


class ButtonType(Enum):
    REGULAR = 0
    JOYSTICK = 1
    DPAD = 2
    BUMPER = 3
    TRIGGER = 4

class DPadDirection(Enum):
    UP = 0
    DOWN = 1
    LEFT = 2
    RIGHT = 3

class ButtonEvent(Enum):
    PRESSED = 0
    RELEASED = 1
    HELD = 2
