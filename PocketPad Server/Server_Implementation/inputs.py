from enums import (ButtonType, DPadDirection)
from struct import unpack

def parse_input(raw_data):
    # Find number of bytes in input data
    data_length_in_bytes = len(raw_data)
    format_str = "B" * data_length_in_bytes

    # Unpack the raw data into a tuple
    unpacked_data = unpack(format_str, raw_data)
    print("DEBUG: Unpacked data")
    print(unpacked_data)

    # Check that common fields exist
    try:
        # Fields that are common to all sets of input data
        num_common_fields = 4
        raw_player_id = unpacked_data[0]
        raw_controller_id = unpacked_data[1]
        raw_input_id = unpacked_data[2]
        raw_type = unpacked_data[3]
    except:
        print("Error: Input format missing fields")
        return

    # Check for valid button type
    try:
        button_type = ButtonType(raw_type)
    except:
        print("Error: Invalid Button Type")
        return

    if button_type == ButtonType.REGULAR:
        print("Regular Button, TBD")
    elif button_type == ButtonType.JOYSTICK:
        print("Joystick, TBD")
    elif button_type == ButtonType.DPAD:
        # check if value is a valid D-pad Direction
        try:
            raw_direction = unpacked_data[num_common_fields]
        except:
            print("Error: D-Pad input format missing fields")
            return

        try:
            direction = DPadDirection(raw_direction)
        except:
            print("Error: Invalid DPad direction")
            return
        
        if direction == DPadDirection.UP:
            print("Received UP")
        elif direction == DPadDirection.DOWN:
            print("Received DOWN")
        elif direction == DPadDirection.LEFT:
            print("Received LEFT")
        elif direction == DPadDirection.RIGHT:
            print("Received RIGHT")
        else:
            print("Error: DPad direction not handled")
    else:
        print("Error: Button type not handled")