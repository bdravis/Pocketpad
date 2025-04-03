# This file provides a function that parses raw input data
# Open to breaking up into smaller functions
#
# Created by Jack

import logging
from configs import (
    ButtonConfig, RegularButtonConfig, DPadConfig, JoystickConfig, LayoutConfig
)
from enums import (ButtonType, DPadDirection, ButtonEvent)
from struct import unpack

# Same logging setup as bluetooth.py
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(name=__name__)
input_error_tuple = (-1, -1, None)

# Parses raw input data bytes
# Returns player_id, input_id, event
# Or input_error_tuple on error
def parse_input(raw_data) -> tuple[int, int, ButtonEvent]:
    # Find number of bytes in input data
    data_length_in_bytes = len(raw_data)
    format_str = "B" * data_length_in_bytes

    # Unpack the raw data into a tuple
    unpacked_data = unpack(format_str, raw_data)
    # logger.debug(f"Unpacked data: {unpacked_data}")

    # Check that common fields exist
    try:
        # Fields that are common to all sets of input data
        NUM_COMMON_FIELDS = 4
        player_id = unpacked_data[0] # 
        input_id = unpacked_data[1]
        raw_type = unpacked_data[2]
        raw_event = unpacked_data[3]
        # return player_id, input_id, raw_event
    except:
        logger.error("Input format missing common fields")
        return input_error_tuple

    # # Identify the current player layout
    # layout = layouts_by_player_id.get(player_id)
    # if layout is None:
    #     logger.error("Player layout not found")
    #     return input_error_tuple

    # # Identify the list of buttons, based on either portrait or layout mode 
    # in_portrait_mode = True # Hardcoded for now
    # if in_portrait_mode:
    #     buttons_by_input_id = layout.portrait_buttons_by_input_id
    # else:
    #     buttons_by_input_id = layout.landscape_buttons_by_input_id
    
    # # Identify the button associated with the specified input id
    # button = buttons_by_input_id.get(input_id)
    # if button is None:
    #     logger.error("Invalid button input id")
    #     return input_error_tuple

    # Check if button type is valid
    try:
        button_type = ButtonType(raw_type)
    except:
        logger.error("Invalid button type")
        return input_error_tuple
    
    # Check if button event is valid
    try:
        button_event = ButtonEvent(raw_event)
    except:
        logger.error("Invalid button event")
        return input_error_tuple
    
    # Find the input string based on the button type
    if button_type == ButtonType.REGULAR:
        logger.debug(f"Received input from button {input_id} from player {player_id}")
    elif button_type == ButtonType.BUMPER:
        logger.debug(f"Received input from bumper {input_id} from player {player_id}")
    elif button_type == ButtonType.TRIGGER:
        logger.debug(f"Received input from trigger {input_id} from player {player_id}")
    elif button_type == ButtonType.JOYSTICK:
        # Check if the data contains values for angle and magnitude
        try:
            raw_angle = unpacked_data[NUM_COMMON_FIELDS]
            raw_magnitude = unpacked_data[NUM_COMMON_FIELDS + 1]
        except:
            logger.error("Joystick input format missing fields")
            return input_error_tuple
        
        logger.debug(f"Received input from joystick {input_id} from player"
        f" {player_id} with angle {raw_angle} and magnitude {raw_magnitude}")

    elif button_type == ButtonType.DPAD:
        # Check if the data contains a value for the DPad direction
        try:
            raw_direction = unpacked_data[NUM_COMMON_FIELDS]
        except:
            logger.error("D-Pad input format missing fields")
            return input_error_tuple

        # Check if the value is a valid DPad direction
        try:
            direction = DPadDirection(raw_direction)
        except:
            logger.error("Invalid DPad direction")
            return input_error_tuple
        
        # # Find the input corresponding to the specified DPad direction
        # dpad_inputs: dict[DPadDirection, str] = button.inputs
        # try:
        #     dpad_input = dpad_inputs[direction]
        # except:
        #     logger.error("No input found for DPad direction")
        #     return input_error_tuple
        
        # Temporary map for parsing direction
        direction_map: dict[DPadDirection, str] = {
            DPadDirection.UP: "UP",
            DPadDirection.DOWN: "DOWN",
            DPadDirection.LEFT: "LEFT",
            DPadDirection.RIGHT: "RIGHT"
        }
        dpad_input = direction_map[direction]

        logger.debug(f"Received DPad input {dpad_input} from DPad {input_id} from player {player_id}")
    else:
        logger.error("Button type not handled")
        return input_input_error_tuple


    return player_id, input_id, button_event