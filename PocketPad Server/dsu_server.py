# This file contains the UDP server implementing the DSU / Cemuhook protocol to send
# inputs to the dolphin emulator
# Created by James Burrows

import socket
from threading import Thread
import struct
import zlib
import time
from enums import ControllerUpdateTypes, AllButtons, Sticks, ButtonEvent
from server_constants import ConnectionMessage
import math

# If this doesn't work first try I am going to drive my car into a telephone pole

class DSU_Server:

    class Controller_State:
        def __init__(self, is_null: bool):
            self.is_null = is_null
            self.connected = False
            self.sending = False
            self.dpad_mask = 0
            self.button_mask = 0
            self.home = 0
            self.touch_button = 0
            self.left_stick_x = 128
            self.left_stick_y = 128
            self.right_stick_x = 128
            self.right_stick_y = 128
            self.motion_timestamp = 0
            self.pitch = 0
            self.yaw = 0
            self.roll = 0

            self.last_request_time = 0

    def __init__(self, port=26760):
        self.port = port
        self.running = False
        self.server_id = 5
        self.packet_counter = 0

        self.addr = ("127.0.0.1",0)

        self.nullstate = self.Controller_State(True)

        self.controller_states = []  # Stores controller data (key: controller_id)
        self.controller_states.append(self.Controller_State(False))
        self.controller_states.append(self.Controller_State(False))
        self.controller_states.append(self.Controller_State(False))
        self.controller_states.append(self.Controller_State(False))

        self.request_timeout = 5 # Seconds after request that inputs stop sending

    def start(self):
        """Start the UDP server in a background thread."""
        self.running = True
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.bind(("127.0.0.1", self.port))
        Thread(target=self._listen_loop, daemon=True).start()
        Thread(target=self._input_loop, daemon=True).start()
        print(f"DSU Server listening on port {self.port}")

    def stop(self):
        """Stop the server."""
        self.running = False
        self.sock.close()

    def _listen_loop(self):
        while self.running:
            try:
                data, addr = self.sock.recvfrom(1024)
                self._handle_message(data, addr)
                
            except OSError:
                break  # Socket closed


    def _handle_message(self, data, addr):

        # packet_length does not include header
        event_type = struct.unpack("<I", data[16:20])[0]

        if event_type == 0x100001:
            self._handle_info_request(data, addr)

        if event_type == 0x100002:
            print("data HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
            self._handle_controller_data(data, addr)


    # --- Message Type Handlers ---
    def _handle_info_request(self, data, addr):

        print(struct.unpack("<IHHIIII", data[:24]))

        # for debugging

        input_with_crc = struct.unpack("<IHHIIIII", data)
        input_without_crc = struct.pack(
                "<IHHIIIII",
                input_with_crc[0],
                input_with_crc[1],
                input_with_crc[2],
                0,
                input_with_crc[4],
                input_with_crc[5],
                input_with_crc[6],
                input_with_crc[7],
                )

        ports = struct.unpack("<I", data[20:24])[0]

        self.addr = addr
        
        requested_slots = struct.unpack(f"<{ports}B", data[24:24+ports])
        for slot_number in requested_slots:
            #subdata_start = 23 - i 
            #subdata_end = 24 - i 
            #slot_number = struct.unpack("<B", data[subdata_start:subdata_end])[0]

            #if i > 0:
            #    slot_number = 0

            slot_state = 0
            gyro = 0
            connection_type = 0
            slot_number_to_report = slot_number
            battery = 0
            if self.controller_states[slot_number].connected == True:
                slot_state = 2
                gyro = 2 # Partial gyro 1, full is 2
                connection_type = 2
                slot_number_to_report = slot_number
                battery = 0x04



            slot_packet_no_crc = struct.pack(
                    "<IHHIIIBBBB6BBB",
                    0x44535553, # Magic string
                    1001, # Protocol version
                    16, # Packet length without header
                    0, # Will be crc
                    self.server_id, # Server id
                    0x100001, # Event type
                    slot_number_to_report, # slot number
                    slot_state, # Slot state
                    gyro, # Device model / gyro
                    connection_type, # Connection type
                    0,0,0,0,0,0, # MAC address
                    battery, # Battery status
                    0) # Null byte

            #crc = self.crc32custom(slot_packet_no_crc)
            crc = zlib.crc32(slot_packet_no_crc) & 0xFFFFFFFF

            slot_packet = struct.pack(
                    "<IHHIIIBBBB6BBB",
                    0x44535553, # Magic string
                    1001, # Protocol version
                    16, # Packet length without header
                    crc, # crc
                    self.server_id, # Server id
                    0x100001, # Event type
                    slot_number_to_report, # slot number
                    slot_state, # Slot state
                    gyro, # Device model / gyro
                    connection_type, # Connection type
                    0,0,0,0,0,0, # MAC address
                    battery, # Battery status
                    0) # Null byte


            print(struct.unpack("<IHHIIIBBBB6BBB", slot_packet))
            print("Raw bytes:", slot_packet.hex(' '))
            print(addr)
            self.sock.sendto(slot_packet, addr)

    def crc32custom(self, s: bytes) -> int:
        crc = 0xFFFFFFFF
        
        for byte in s:
            crc ^= byte
            for _ in range(8):
                if crc & 1:
                    crc = (crc >> 1) ^ 0xedb88320
                else:
                    crc >>= 1
        
        return ~crc & 0xFFFFFFFF

    def is_any_controller_sending(self) -> bool:
        for state in self.controller_states:
            if state.sending:
                return True
        return False

    def _handle_controller_data(self, data, addr):

        actions_requested = int.from_bytes(struct.unpack("<B", data[20:21]))

        if actions_requested == 1:
            slot_requested = int.from_bytes(struct.unpack("<B", data[21:22]))
            state_requested = self.controller_states[slot_requested]

            if (state_requested.is_null):
                print("invalid state requested")
                return

            if state_requested.connected:
                state_requested.sending = True


        if actions_requested == 2:
            print("Client requested MAC for controller registration: this feature is not implemented in PocketPad")
            return

        if actions_requested == 0:

            for state in self.controller_states:
                if state.connected:
                    state.sending = True



    
    def _input_loop(self):
        while True:
            time.sleep(0.5)
            for index, state in enumerate(self.controller_states):

                # print(state.connected, state.sending, state.last_request_time)

                if state.connected == False:
                    state.sending = False
                    continue

                if state.sending == False:
                    continue

                if state.last_request_ != 0 and time.time() - state.last_request_time > self.request_timeout:
                    state.sending = False
                    continue

                print("=========================================================")

                slot_state_int = 0
                if state.connected:
                    slot_state_int = 2

                connected_int = 0
                if state.connected:
                    connected_int = 2

                packet_number = self.packet_counter
                self.packet_counter += 1

                input_packet_no_crc = struct.pack(
                        "IHHIIIBBBBHHHBBIBBBBBBBBBBBBBBBBBBBBBBBHHBBHHQIIIIII",
                        "DSUS".encode(), # Magic string
                        1001, # Protocol version
                        84, # Len without header
                        0, # crc
                        self.server_id,
                        0x100002, #event type
                        index, # slot
                        slot_state_int, # slot state (connected / not connected)
                        2, # device model (gyro)
                        0, # Connection type
                        0, #MAC
                        0, #MAC
                        0, #MAC
                        0, #Battery
                        connected_int,
                        packet_number,
                        state.dpad_mask,
                        state.button_mask,
                        state.home,
                        state.touch_button,
                        state.left_stick_x,
                        state.left_stick_y,
                        state.right_stick_x,
                        state.right_stick_y,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        state.motion_timestamp,
                        0,
                        0,
                        0,
                        state.pitch,
                        state.yaw,
                        state.roll
                        )

                crc = zlib.crc32(input_packet_no_crc)

                input_packet = struct.pack(
                        "IHHIIIBBBBHHHBBIBBBBBBBBBBBBBBBBBBBBBBBHHBBHHQIIIIII",
                        "DSUS".encode(), # Magic string
                        1001, # Protocol version
                        84, # Len without header
                        crc, # crc
                        self.server_id,
                        0x100002, #event type
                        index, # slot
                        slot_state_int, # slot state (connected / not connected)
                        2, # device model (gyro)
                        0, # Connection type
                        0, #MAC
                        0, #MAC
                        0, #MAC
                        0, #Battery
                        connected_int,
                        packet_number,
                        state.dpad_mask,
                        state.button_mask,
                        state.home,
                        state.touch_button,
                        state.left_stick_x,
                        state.left_stick_y,
                        state.right_stick_x,
                        state.right_stick_y,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        state.motion_timestamp,
                        0,
                        0,
                        0,
                        state.pitch,
                        state.yaw,
                        state.roll
                        )


                self.sock.sendto(input_packet, self.addr)




    def update_controller_state(self, player_num, event_type, value):

        # Value is always an array, but has different number of elements
        # If event type is CONNECTION, value is either connecting or disconnecting
        # If event type is BUTTON, value is [AllButtons int, ButtonEvent enum]
        # If event type is JOYSTICK, value is [Sticks int, angle, magnitude]
        # if event type is MOTION, value is [pitch, yaw, roll]

        state = self.controller_states[player_num]

        if event_type == ControllerUpdateTypes.CONNECTION.value:

            if value[0] == ConnectionMessage.connecting.value:
                state.connected = True

            if value[0] == ConnectionMessage.disconnecting.value:
                state.connected = False

        if event_type == ControllerUpdateTypes.BUTTON.value:
            if value[0] == AllButtons.top_diamond:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 4
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 4

            elif value[0] == AllButtons.bottom_diamond:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 6
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 6

            elif value[0] == AllButtons.left_diamond:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 7
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 7

            elif value[0] == AllButtons.right_diamond:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 5
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 5

            elif value[0] == AllButtons.up_dpad:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.dpad_mask &= 1 << 4
                if value[1] == ButtonEvent.RELEASED.value:
                    state.dpad_mask &= 0 << 4

            elif value[0] == AllButtons.down_dpad:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.dpad_mask &= 1 << 6
                if value[1] == ButtonEvent.RELEASED.value:
                    state.dpad_mask &= 0 << 6

            elif value[0] == AllButtons.left_dpad:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.dpad_mask &= 1 << 7
                if value[1] == ButtonEvent.RELEASED.value:
                    state.dpad_mask &= 0 << 7

            elif value[0] == AllButtons.right_dpad:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.dpad_mask &= 1 << 5
                if value[1] == ButtonEvent.RELEASED.value:
                    state.dpad_mask &= 0 << 5

            elif value[0] == AllButtons.left_bumper:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 2
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 2

            elif value[0] == AllButtons.right_bumper:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 3
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 3

            elif value[0] == AllButtons.left_trigger:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 0
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 0

            elif value[0] == AllButtons.right_trigger:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.button_mask &= 1 << 1
                if value[1] == ButtonEvent.RELEASED.value:
                    state.button_mask &= 0 << 1

            elif value[0] == AllButtons.options:
                if value[1] == ButtonEvent.PRESSED.value:
                    state.dpad_mask &= 1 << 3
                if value[1] == ButtonEvent.RELEASED.value:
                    state.dpad_mask &= 0 << 3


        if event_type == ControllerUpdateTypes.JOYSTICK.value:
            if value[0] == Sticks.left.value:

                angle_radians = 2 * math.pi * (value[1] / 255)

                state.left_stick_x = value[2] * math.cos(angle_radians)
                state.left_stick_y = value[2] * math.sin(angle_radians)


            if value[0] == Sticks.right.value:
                angle_radians = 2 * math.pi * (value[1] / 255)

                state.right_stick_x = value[2] * math.cos(angle_radians)
                state.right_stick_y = value[2] * math.sin(angle_radians)

        if event_type == ControllerUpdateTypes.MOTION.value:
            state.motion_timestamp = int(time.time() * 1_000_000)
            state.pitch = value[1]
            state.yaw = value[2]
            state.roll = value[3]
