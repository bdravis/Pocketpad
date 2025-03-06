# This file contains basic enums for config structs
# Enums for config styles can be found in config_styles.py
# ButtonType, DPadDirection, ControllerType
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

class DPadDirection(Enum):
    UP = 0
    DOWN = 1
    LEFT = 2
    RIGHT = 3
