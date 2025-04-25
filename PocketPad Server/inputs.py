# This file provides a function that parses raw input data
# Open to breaking up into smaller functions
#
# Created by Jack

import logging
from enums import (ButtonType, DPadDirection, ButtonEvent, ControllerUpdateTypes, AllButtons)
from struct import unpack, unpack_from
from dsu_server import DSU_Server

# Same logging setup as bluetooth.py
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(name=__name__)

def map_inputID_to_inputs(json):
    for item in json['wrappedButtons']:
        if not isinstance(item, dict) or 'base' not in item or 'payload' not in item:
            continue
            
        payload = item['payload']
        input_id = payload.get('inputId')
        input_val = payload.get('input')
        
        if input_id is None:
            continue
            
        # Handle D-Pad (special case - maps to all 4 directions)
        if item['base'] == 'dPadConfig':
            DSU_Server.instance().inputId_to_inputs[input_id] = {
                AllButtons.up_dpad,
                AllButtons.down_dpad,
                AllButtons.left_dpad,
                AllButtons.right_dpad
            }
            continue
            
        # Handle diamond buttons
        if input_val == 'X':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.top_diamond
        elif input_val == 'B':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.bottom_diamond
        elif input_val == 'Y':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.left_diamond
        elif input_val == 'A':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.right_diamond
        elif input_val == 'Z':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.z
            
        # Handle other buttons
        elif input_val == 'LB':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.left_bumper
        elif input_val == 'RB':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.right_bumper
        elif input_val == 'LT':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.left_trigger
        elif input_val == 'RT':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.right_trigger

        elif input_val == 'Start':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.options
        elif input_val == 'Select':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.select
        elif input_val == 'Share':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.share
            
        elif input_val == 'LeftJoystick':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.left_stick
        elif input_val == 'RightJoystick':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.right_stick
        elif input_val == 'Home':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.home
        elif input_val == '1':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.one
        elif input_val == '2':
            DSU_Server.instance().inputId_to_inputs[input_id] = AllButtons.two

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
        x_acceleration = unpack_from('<f', raw_data, offset=14)[0]
        y_acceleration  = unpack_from('<f', raw_data, offset=18)[0]
        z_acceleration   = unpack_from('<f', raw_data, offset=22)[0]

        logger.debug(f"Motion Data Received from player {player_id}: pitch = {pitch:.2f}, roll = {roll:.2f}, yaw = {yaw:.2f}\n xAcceleration = {x_acceleration:.2f}, yAcceleration = {y_acceleration:.2f}, zAcceleration = {z_acceleration:.2f}")
        DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.MOTION.value, [pitch, yaw, roll, x_acceleration, y_acceleration, z_acceleration])
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
        # logger.debug(f"Received input from button {input_id} from player {player_id}")
        DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [DSU_Server.instance().inputId_to_inputs[input_id].value, raw_event])

    elif button_type == ButtonType.BUMPER:
        # logger.debug(f"Received input from bumper {input_id} from player {player_id}")
        DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [DSU_Server.instance().inputId_to_inputs[input_id].value, raw_event])

    elif button_type == ButtonType.TRIGGER:
        # logger.debug(f"Received input from trigger {input_id} from player {player_id}")
        DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [DSU_Server.instance().inputId_to_inputs[input_id].value, raw_event])

    elif button_type == ButtonType.JOYSTICK:
        # Check if the data contains values for angle and magnitude
        try:
            raw_angle = unpacked_data[NUM_COMMON_FIELDS]
            raw_magnitude = unpacked_data[NUM_COMMON_FIELDS + 1]

            logger.debug(f"Updating Joystick: {player_id} -- {ControllerUpdateTypes.JOYSTICK.value} -- {DSU_Server.instance().inputId_to_inputs[input_id].value} -- {raw_angle} -- {raw_magnitude}")
            DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.JOYSTICK.value, [DSU_Server.instance().inputId_to_inputs[input_id].value, raw_angle, raw_magnitude])
        except:
            logger.error("Joystick input format missing fields")
            return (-1, -1, None)
        
        logger.debug(f"Received input from joystick {input_id} from player" f" {player_id} with angle {raw_angle} and magnitude {raw_magnitude}")

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
        # direction_map: dict[DPadDirection, str] = {
        #     DPadDirection.UP: "UP",
        #     DPadDirection.DOWN: "DOWN",
        #     DPadDirection.LEFT: "LEFT",
        #     DPadDirection.RIGHT: "RIGHT"
        # }
        # dpad_input = direction_map[direction]

        vc_direction_map: dict[DPadDirection, AllButtons] = {
            DPadDirection.UP: AllButtons.up_dpad,
            DPadDirection.DOWN: AllButtons.down_dpad,
            DPadDirection.LEFT: AllButtons.left_dpad,
            DPadDirection.RIGHT: AllButtons.right_dpad
        }
        vc_dpad_input = vc_direction_map[direction]

        DSU_Server.instance().update_controller_state(player_id, ControllerUpdateTypes.BUTTON.value, [vc_dpad_input.value, raw_event])

        # logger.debug(f"Received DPad input {dpad_input} from DPad {input_id} from player {player_id}")
    else:
        logger.error("Button type not handled")
        return (-1, -1, None)


    return player_id, input_id, button_event
