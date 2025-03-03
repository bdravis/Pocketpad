# This file contains classes that correspond to config structs in Swift
# ButtonConfig, RegularButtonConfig, DPadConfig, JoystickConfig, LayoutConfig
# 
# Created by Jack on 2/27/25

from enums import (ButtonType, DPadDirection)
from typing import Optional

# Class for general button configuration
class ButtonConfig:
    pass

# Class for regular button configuration
class RegularButtonConfig(ButtonConfig):
    def __init__(
        self,
        position: tuple[float, float],
        scale: float,
        input_id: int,
        input: str,
        turbo: bool = False
    ):
        self.type = ButtonType.REGULAR
        
        self.position = position
        self.scale = scale
        
        self.input_id = input_id
        
        self.input = input
        self.turbo = turbo

# Class for DPad configuration
class DPadConfig(ButtonConfig):
    def __init__(
        self,
        position: tuple[float, float],
        scale: float,
        input_id: int,
        inputs: dict[DPadDirection, str]
    ):
        self.type = ButtonType.DPAD
        
        self.position = position
        self.scale = scale
        
        self.input_id = input_id
        
        self.inputs = inputs

# Class for joystick configuration
class JoystickConfig(ButtonConfig):
    def __init__(
        self,
        position: tuple[float, float],
        scale: float,
        input_id: int,
        input: str,
        sensitivity: float = 0.0,
        deadzone: float = 0.0
    ):
        self.type = ButtonType.JOYSTICK
        
        self.position = position
        self.scale = scale
        
        self.input_id = input_id
        
        self.input = input
        self.sensitivity = sensitivity
        self.deadzone = deadzone

# Class for layout configuration
class LayoutConfig:
    def __init__(
        self,
        name: str,
        landscape_buttons: list[ButtonConfig],
        portrait_buttons: list[ButtonConfig]
    ):
        self.name = name
        self.landscape_buttons = landscape_buttons
        self.portrait_buttons = portrait_buttons
        
        self.landscape_buttons_by_input_id: dict[int, ButtonConfig] = {
            button.input_id: button for button in landscape_buttons
        }
        self.portrait_buttons_by_input_id: dict[int, ButtonConfig] = {
            button.input_id: button for button in portrait_buttons
        }


# Debug Buttons
# The same hardcoded values as the debug buttons in Swift client
DEBUG_BUTTONS: list[ButtonConfig] = [
    RegularButtonConfig(position = (300, 200), scale = 1.0, input_id = 0, input = "X"),
    RegularButtonConfig(position = (240, 260), scale = 1.0, input_id = 1, input = "Y"),
    RegularButtonConfig(position = (360, 260), scale = 1.0, input_id = 2, input = "A"),
    RegularButtonConfig(position = (300, 320), scale = 1.0, input_id = 3, input = "B"),

    JoystickConfig(position = (0, 400), scale = 1.0, input_id = 4, input = "RightJoystick"),

    DPadConfig(position = (100, 0), scale = 1.0, input_id = 5, inputs = {
        DPadDirection.UP: "DPadUp",
        DPadDirection.RIGHT: "DPadRight",
        DPadDirection.DOWN: "DPadDown",
        DPadDirection.LEFT: "DPadLeft", 
    })
]

# Debug layout, which contains debug buttons
DEBUG_LAYOUT = LayoutConfig(
    name = "Debug Layout",
    landscape_buttons = [], # Only testing portrait mode for now
    portrait_buttons = DEBUG_BUTTONS
)

# Maps player IDs to their current layout configurations
# The actual mapping may be more complex in the system
# This dictionary is simply a proof of concept
layouts_by_player_id: dict[int, Optional[LayoutConfig]] = {
    0: DEBUG_LAYOUT,
    1: None,
    2: None
}