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

class ControllerUpdateTypes(Enum):
    BUTTON = 0
    JOYSTICK = 1
    MOTION = 2
    CONNECTION = 3

class AllButtons(Enum):
    top_diamond = 0
    bottom_diamond = 1
    left_diamond = 2
    right_diamond = 3
    up_dpad = 4
    down_dpad = 5
    left_dpad = 6
    right_dpad = 7
    left_bumper = 8
    right_bumper = 9
    left_trigger = 10
    right_trigger = 11
    options = 12

class Sticks(Enum):
    left = 0
    right = 1
