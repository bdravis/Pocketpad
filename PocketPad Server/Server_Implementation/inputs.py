import json
from enums import (ButtonType, DPadDirection)

def parse_input(raw_data):
    # parse into dict
    input_dict = json.loads(raw_data.decode('utf-8'))

    # extract type and input value
    raw_type = input_dict["type"]
    raw_input_value = input_dict["inputValue"]

    # check if type is a valid buttonType
    try:
        button_type = ButtonType(raw_type)

        if button_type == ButtonType.REGULAR:
            print("TBD")
        elif button_type == ButtonType.JOYSTICK:
            print("TBD")
        elif button_type == ButtonType.DPAD:
            # check if value is a valid D-pad Direction
            try:
                direction = DPadDirection(raw_input_value)

                if direction == DPadDirection.UP:
                    print("Received UP")
                elif direction == DPadDirection.DOWN:
                    print("Received DOWN")
                elif direction == DPadDirection.LEFT:
                    print("Received LEFT")
                elif direction == DPadDirection.RIGHT:
                    print("Received RIGHT")
            except:
                print("Error: Invalid DPad Direction")
    except:
        print("Error: Invalid Button Type")
