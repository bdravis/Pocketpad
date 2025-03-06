# This file contains classes that correspond to config structs in Swift
# ButtonConfig, RegularButtonConfig, DPadConfig, JoystickConfig, LayoutConfig
# 
# Created by Jack on 2/27/25

from config_styles import (
    RegularButtonStyle, RegularButtonShape, RegularButtonIconType
)
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
        style: RegularButtonStyle = None,
        turbo: bool = False
    ):
        self.type = ButtonType.REGULAR
        
        self.position = position
        self.scale = scale
        
        self.input_id = input_id
        
        self.input = input
        self.turbo = turbo

        if style is not None:
            self.style = style
        else:
            # create a default style configuration
            self.style = RegularButtonStyle(
                shape = RegularButtonShape.CIRCLE,
                iconType = RegularButtonIconType.TEXT,
                icon = input
            )


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