# This file provides a function that parses raw input data
# Open to breaking up into smaller functions
#
# Created by Jack

import logging
from enums import (ButtonType, DPadDirection, ButtonEvent, ControllerUpdateTypes)
from struct import unpack, unpack_from
from shared_definitions import inputId_to_inputs, input_server

# Same logging setup as bluetooth.py
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(name=__name__)

# Parses raw input data bytes
# Returns player_id, input_id, event
# Or input_error_tuple on error
def parse_input(raw_data):

    # Find number of bytes in input data
    data_length_in_bytes = len(raw_data)
    format_str = "B" * data_length_in_bytes

    # Unpack the raw data into a tuple
    unpacked_data = unpack(format_str, raw_data)

    NUM_COMMON_FIELDS = 0
    player_id = unpacked_data[0]
    input_id = unpacked_data[1]
    raw_type = None
    raw_event = None

    if (input_id == 99):
        pitch = unpack_from('<f', raw_data, offset=2)[0]
        roll  = unpack_from('<f', raw_data, offset=6)[0]
        yaw   = unpack_from('<f', raw_data, offset=10)[0]
        
        logger.debug(f"Motion Data Received from player {player_id}: pitch = {pitch:.2f}, roll = {roll:.2f}, yaw = {yaw:.2f}")
        input_server.update_controller_state(player_id, ControllerUpdateTypes.MOTION.value, [pitch, yaw, roll])
        return
    else:
        # Check that common fields exist
        try:
            # Fields that are common to all sets of input data
            NUM_COMMON_FIELDS = 4
            raw_type = unpacked_data[2]
            raw_event = unpacked_data[3]
        except:
            logger.error("Input format missing common fields")
            return (-1, -1, None)

    # Check if button type is valid
    try:
        button_type = ButtonType(raw_type)
    except:
        logger.error("Invalid button type")
        return (-1, -1, None)
    
    # Check if button event is valid
    try:
        button_event = ButtonEvent(raw_event)
    except:
        logger.error("Invalid button event")
        return (-1, -1, None)
    
    # Find the input string based on the button type
    if button_type == ButtonType.REGULAR:
        logger.debug(f"Received input from button {input_id} from player {player_id}")
        input_server.update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [inputId_to_inputs[input_id].value, raw_event])

    elif button_type == ButtonType.BUMPER:
        logger.debug(f"Received input from bumper {input_id} from player {player_id}")
        input_server.update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [inputId_to_inputs[input_id].value, raw_event])

    elif button_type == ButtonType.TRIGGER:
        logger.debug(f"Received input from trigger {input_id} from player {player_id}")
        input_server.update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [inputId_to_inputs[input_id].value, raw_event])

    elif button_type == ButtonType.JOYSTICK:
        # Check if the data contains values for angle and magnitude
        try:
            raw_angle = unpacked_data[NUM_COMMON_FIELDS]
            raw_magnitude = unpacked_data[NUM_COMMON_FIELDS + 1]

            #input_server.update_controller_state(player_id, ControllerUpdateTypes.JOYSTICK.value, [raw_angle, raw_magnitude])
        except:
            logger.error("Joystick input format missing fields")
            return (-1, -1, None)
        
        logger.debug(f"Received input from joystick {input_id} from player"
        f" {player_id} with angle {raw_angle} and magnitude {raw_magnitude}")

    elif button_type == ButtonType.DPAD:
        # Check if the data contains a value for the DPad direction
        try:
            raw_direction = unpacked_data[NUM_COMMON_FIELDS]
        except:
            logger.error("D-Pad input format missing fields")
            return (-1, -1, None)

        # Check if the value is a valid DPad direction
        try:
            direction = DPadDirection(raw_direction)
        except:
            logger.error("Invalid DPad direction")
            return (-1, -1, None)
        
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
        return (-1, -1, None)


    return player_id, input_id, button_event
