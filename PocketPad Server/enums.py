# This file contains basic enums for config structs
# Enums for config styles can be found in config_styles.py
# ButtonType, DPadDirection, ButtonEvent
# 
# Created by Jack

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

class ButtonEvent(Enum):
    PRESSED = 0
    RELEASED = 1
    HELD = 2