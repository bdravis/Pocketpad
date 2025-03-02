# This file provides a function that parses raw input data
# Open to breaking up into smaller functions
#
# Created by Jack

import logging
from configs import (
    ButtonConfig, RegularButtonConfig, DPadConfig, JoystickConfig, LayoutConfig,
    layouts_by_player_id
)
from enums import (ButtonType, DPadDirection)
from struct import unpack

# Same logging setup as bluetooth.py
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(name=__name__)

# Parses raw input data bytes
# Returns 0 on success, -1 on error
def parse_input(raw_data) -> int:
    # Find number of bytes in input data
    data_length_in_bytes = len(raw_data)
    format_str = "B" * data_length_in_bytes

    # Unpack the raw data into a tuple
    unpacked_data = unpack(format_str, raw_data)
    logger.debug(f"Unpacked data: {unpacked_data}")

    # Check that common fields exist
    try:
        # Fields that are common to all sets of input data
        NUM_COMMON_FIELDS = 3
        player_id = unpacked_data[0] # 
        input_id = unpacked_data[1]
        raw_type = unpacked_data[2]
    except:
        logger.error("Input format missing common fields")
        return -1

    # Identify the current player layout
    layout = layouts_by_player_id.get(player_id)
    if layout is None:
        logger.error("Player layout not found")
        return -1

    # Identify the list of buttons, based on either portrait or layout mode 
    in_portrait_mode = True # Hardcoded for now
    if in_portrait_mode:
        buttons_by_input_id = layout.portrait_buttons_by_input_id
    else:
        buttons_by_input_id = layout.landscape_buttons_by_input_id
    
    # Identify the button associated with the specified input id
    button = buttons_by_input_id.get(input_id)
    if button is None:
        logger.error("Invalid button input id")
        return -1

    # Check if button type is valid
    try:
        button_type = ButtonType(raw_type)
    except:
        logger.error("Invalid button type")
        return -1
    
    # Find the input string based on the button type
    if button_type == ButtonType.REGULAR:
        logger.debug(f"Received button input {button.input} from player {player_id}")
    elif button_type == ButtonType.JOYSTICK:
        logger.debug(f"Received joystick input {button.input} from player {player_id}")
        # TODO Parse joystick input
    elif button_type == ButtonType.DPAD:
        # Check if the data contains a value for the DPad direction
        try:
            raw_direction = unpacked_data[NUM_COMMON_FIELDS]
        except:
            logger.error("D-Pad input format missing fields")
            return -1

        # Check if the value is a valid DPad direction
        try:
            direction = DPadDirection(raw_direction)
        except:
            logger.error("Invalid DPad direction")
            return -1
        
        # Find the input corresponding to the specified DPad direction
        dpad_inputs: dict[DPadDirection, str] = button.inputs
        try:
            dpad_input = dpad_inputs[direction]
        except:
            logger.error("No input found for DPad direction")
            return -1
        
        logger.debug(f"Received DPad input {dpad_input} from player {player_id}")
    else:
        logger.error("Button type not handled")
        return -1
    
    return 0