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
import random
from dataclasses import dataclass

class DSU_Server:
    _instance = None
    
    class Controller_State:
        def __init__(self, is_null: bool):

            self.addr = ("127.0.0.1", 0)

            self.is_null = is_null
            self.connected = False
            self.sending = False
            self.dpad_mask = 0
            self.button_mask = 0

            self.sq = 0
            self.cr = 0
            self.ci = 0
            self.tr = 0

            self.le = 0
            self.do = 0
            self.ri = 0
            self.up = 0

            self.l1 = 0
            self.l2 = 0
            self.r1 = 0
            self.r2 = 0

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

            self.x_acceleration = 0
            self.y_acceleration = 0
            self.z_acceleration = 0

            self.last_request_time = 0
            
    @staticmethod
    def instance():
        if DSU_Server._instance is None:
            DSU_Server._instance = DSU_Server()
        DSU_Server._instance.start()
        return DSU_Server._instance

    def __init__(self, port=26760):
        self.port = port
        self.running = False
        self.server_id = 5
        self.packet_counter = 0
        
        self.inputId_to_inputs = [{} for _ in range(4)]

        self.addr = ("127.0.0.1",26760)

        self.nullstate = self.Controller_State(True)

        self.controller_states = []  # Stores controller data (key: controller_id)
        self.controller_states.append(self.Controller_State(False))
        self.controller_states.append(self.Controller_State(False))
        self.controller_states.append(self.Controller_State(False))
        self.controller_states.append(self.Controller_State(False))

        self.request_timeout = 5 # Seconds after request that inputs stop sending
        
        self.started = False

    def start(self):
        """Start the UDP server in a background thread."""
        if self.started:
            return
        self.started = True
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
                print("OSError")
                break  # Socket closed


    def _handle_message(self, data, addr):

        # packet_length does not include header
        event_type = struct.unpack("<I", data[16:20])[0]
        #print("event type:", event_type)
        #print(addr)
        #print(data)

        if event_type == 0x100001:
            self._handle_info_request(data, addr)

        if event_type == 0x100002:
            self._handle_controller_data(data, addr)

        if event_type == 0x110001:
            print("rumble sent")

        if event_type == 0x110002:
            print("rumble sent")

    # --- Message Type Handlers ---
    def _handle_info_request(self, data, addr):

        #print(struct.unpack("<IHHIIII", data[:24]))

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

        #server_id = input_with_crc[4]
        server_id = 5

        ports = struct.unpack("<I", data[20:24])[0]

        response_addr = addr
        
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
            padding = 0
            if self.controller_states[slot_number].connected == True:
                slot_state = 2
                gyro = 2 # Partial gyro 1, full is 2
                connection_type = 2
                slot_number_to_report = slot_number
                battery = 0x04
                padding = 1


            randmac = random.randint(0,255)

            slot_packet_no_crc = struct.pack(
                    "<IHHIIIBBBB6BBB",
                    #0x44535553, # Magic string
                    0x53555344,
                    1001, # Protocol version
                    16, # Packet length without header
                    0, # Will be crc
                    server_id, # Server id
                    0x100001, # Event type
                    slot_number_to_report, # slot number
                    slot_state, # Slot state
                    gyro, # Device model / gyro
                    #1, # TEMP NO GYRO
                    connection_type, # Connection type
                    0,0,0,0,0,0, # MAC address
                    battery, # Battery status
                    padding) # Null byte

            #crc = self.crc32custom(slot_packet_no_crc)
            crc = zlib.crc32(slot_packet_no_crc) & 0xFFFFFFFF

            slot_packet = struct.pack(
                    "<IHHIIIBBBB6BBB",
                    #0x44535553, # Magic string
                    0x53555344,
                    1001, # Protocol version
                    16, # Packet length without header
                    crc, # crc
                    server_id, # Server id
                    0x100001, # Event type
                    slot_number_to_report, # slot number
                    slot_state, # Slot state
                    gyro, # Device model / gyro
                    #1, # TEMP NO GYRO
                    connection_type, # Connection type
                    0,0,0,0,0,0, # MAC address
                    battery, # Battery status
                    padding) # Null byte


            #print(struct.unpack("<IHHIIIBBBB6BBB", slot_packet))
            #print("Raw bytes:", slot_packet.hex(' '))
            #print(response_addr)
            self.sock.sendto(slot_packet, response_addr)

    def _handle_controller_data(self, data, addr):

        actions_requested = int.from_bytes(struct.unpack("<B", data[20:21]))

        self.addr = addr

        if actions_requested == 1:
            slot_requested = int.from_bytes(struct.unpack("<B", data[21:22]))
            # print(f"data requested from slot {slot_requested}")
            state_requested = self.controller_states[slot_requested]
            self.controller_states[slot_requested].addr = addr

            if (state_requested.is_null):
                print("invalid state requested")
                return

            if state_requested.connected:
                state_requested.sending = True


        if actions_requested == 2:
            print("Client requested MAC for controller registration: this feature is not implemented in PocketPad")
            return

        if actions_requested == 0:

            print("data requested from all slots")
            for state in self.controller_states:
                if state.connected:
                    state.sending = True



    
    def _input_loop(self):
        while True:
            time.sleep(0.01)
            for index, state in enumerate(self.controller_states):

                if state.connected == False:
                    state.sending = False
                    continue

                if state.sending == False:
                    continue

                if state.last_request_time != 0 and time.time() - state.last_request_time > self.request_timeout:
                    state.sending = False
                    continue

                slot_state_int = 0
                if state.connected:
                    slot_state_int = 2

                connected_int = 0
                if state.connected:
                    connected_int = 1

                packet_number = self.packet_counter
                self.packet_counter += 1
                
                # use for testing bad crc
                randmac = random.randint(0,255)


                input_packet_no_crc_packed = struct.pack(
                        "<IHHIIIBBBB6BBBIBBBBBBBBBBBBBBBBBBBBHHHHHHQffffff",
                        0x53555344,
                        1001, # Protocol version
                        84, # Len without header
                        0, # crc
                        self.server_id,
                        0x100002, #event type
                        index, # slot
                        slot_state_int, # slot state (connected / not connected)
                        2, # device model (gyro)
                        2, # Connection type
                        0,0,0,0,0,0, # MAC address
                        0x4, #Battery
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
                        state.le, # ana_dpad left
                        state.do, # ana_dpad down
                        state.ri, # ana_dpad right
                        state.up, # ana_dpad up
                        state.sq,
                        state.cr,
                        state.ci,
                        state.tr,
                        state.r1, # ana_r1
                        state.l1, # ana_l1
                        state.r2, # ana_r2
                        state.l2, # ana_l2
                        0, # Touch 1
                        0, # Touch 1
                        0, # Touch 1
                        0, # Touch 2
                        0, # Touch 2
                        0, # Touch 2
                        state.motion_timestamp,
                        state.x_acceleration, # Accel x
                        state.y_acceleration, # Accel y
                        state.z_acceleration, # Accel z
                        state.pitch,
                        state.yaw,
                        state.roll
                        )

                crc = zlib.crc32(input_packet_no_crc_packed)

                input_packet_no_crc = struct.unpack("<IHHIIIBBBB6BBBIBBBBBBBBBBBBBBBBBBBBHHHHHHQffffff", input_packet_no_crc_packed)
                input_packet = struct.pack(
                        "<IHHIIIBBBB6BBBIBBBBBBBBBBBBBBBBBBBBHHHHHHQffffff",
                        input_packet_no_crc[0],
                        input_packet_no_crc[1],
                        input_packet_no_crc[2],
                        crc, # crc
                        input_packet_no_crc[4],
                        input_packet_no_crc[5],
                        input_packet_no_crc[6],
                        input_packet_no_crc[7],
                        input_packet_no_crc[8],
                        input_packet_no_crc[9],
                        input_packet_no_crc[10],
                        input_packet_no_crc[11],
                        input_packet_no_crc[12],
                        input_packet_no_crc[13],
                        input_packet_no_crc[14],
                        input_packet_no_crc[15],
                        input_packet_no_crc[16],
                        input_packet_no_crc[17],
                        input_packet_no_crc[18],
                        input_packet_no_crc[19],
                        input_packet_no_crc[20],
                        input_packet_no_crc[21],
                        input_packet_no_crc[22],
                        input_packet_no_crc[23],
                        input_packet_no_crc[24],
                        input_packet_no_crc[25],
                        input_packet_no_crc[26],
                        input_packet_no_crc[27],
                        input_packet_no_crc[28],
                        input_packet_no_crc[29],
                        input_packet_no_crc[30],
                        input_packet_no_crc[31],
                        input_packet_no_crc[32],
                        input_packet_no_crc[33],
                        input_packet_no_crc[34],
                        input_packet_no_crc[35],
                        input_packet_no_crc[36],
                        input_packet_no_crc[37],
                        input_packet_no_crc[38],
                        input_packet_no_crc[39],
                        input_packet_no_crc[40],
                        input_packet_no_crc[41],
                        input_packet_no_crc[42],
                        input_packet_no_crc[43],
                        input_packet_no_crc[44],
                        input_packet_no_crc[45],
                        input_packet_no_crc[46],
                        input_packet_no_crc[47],
                        input_packet_no_crc[48],
                        input_packet_no_crc[49],
                        input_packet_no_crc[50],
                        input_packet_no_crc[51],
                        )

                self.sock.sendto(input_packet, self.controller_states[index].addr)




    def update_controller_state(self, player_num, event_type, value):

        # Value is always an array, but has different number of elements
        # If event type is CONNECTION, value is either connecting or disconnecting
        # If event type is BUTTON, value is [AllButtons int, ButtonEvent enum]
        # If event type is JOYSTICK, value is [Sticks int, angle, magnitude]
        # if event type is MOTION, value is [pitch, yaw, roll]

        if event_type == ControllerUpdateTypes.CONNECTION.value:

            if value[0] == ConnectionMessage.connecting.value:
                self.controller_states[player_num].connected = True

            if value[0] == ConnectionMessage.disconnecting.value:
                self.controller_states[player_num].connected = False

        if event_type == ControllerUpdateTypes.BUTTON.value:

            if value[0] == AllButtons.top_diamond.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 4
                    self.controller_states[player_num].tr = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 4)
                    self.controller_states[player_num].tr = 0

            elif value[0] == AllButtons.bottom_diamond.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 6
                    self.controller_states[player_num].cr = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 6)
                    self.controller_states[player_num].cr = 0

            elif value[0] == AllButtons.left_diamond.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 7
                    self.controller_states[player_num].sq = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 7)
                    self.controller_states[player_num].sq = 0

            elif value[0] == AllButtons.one.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 7
                    self.controller_states[player_num].sq = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 7)
                    self.controller_states[player_num].sq = 0

            elif value[0] == AllButtons.two.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 7
                    self.controller_states[player_num].tr = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 7)
                    self.controller_states[player_num].tr = 0

            elif value[0] == AllButtons.right_diamond.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 5
                    self.controller_states[player_num].ci = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 5)
                    self.controller_states[player_num].ci = 0

            elif value[0] == AllButtons.up_dpad.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 4
                    self.controller_states[player_num].up = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 4)
                    self.controller_states[player_num].up = 0

            elif value[0] == AllButtons.down_dpad.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 6
                    self.controller_states[player_num].do = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 6)
                    self.controller_states[player_num].do = 0

            elif value[0] == AllButtons.left_dpad.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 7
                    self.controller_states[player_num].le = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 7)
                    self.controller_states[player_num].le = 0

            elif value[0] == AllButtons.right_dpad.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 5
                    self.controller_states[player_num].ri = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 5)
                    self.controller_states[player_num].ri = 0

            elif value[0] == AllButtons.left_bumper.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 2
                    self.controller_states[player_num].l1 = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 2)
                    self.controller_states[player_num].l1 = 0

            elif value[0] == AllButtons.right_bumper.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 3
                    self.controller_states[player_num].r1 = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 3)
                    self.controller_states[player_num].r1 = 0

            elif value[0] == AllButtons.z.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 3
                    self.controller_states[player_num].r1 = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 3)
                    self.controller_states[player_num].r1 = 0

            elif value[0] == AllButtons.left_trigger.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 0
                    self.controller_states[player_num].l2 = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 0)
                    self.controller_states[player_num].l2 = 0

            elif value[0] == AllButtons.right_trigger.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].button_mask |= 1 << 1
                    self.controller_states[player_num].r2 = 255
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].button_mask &= ~(1 << 1)
                    self.controller_states[player_num].r2 = 0

            elif value[0] == AllButtons.options.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 3
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 3)

            elif value[0] == AllButtons.select.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 2
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 2)

            elif value[0] == AllButtons.share.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].dpad_mask |= 1 << 0
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].dpad_mask &= ~(1 << 0)

            elif value[0] == AllButtons.home.value:
                if value[1] == ButtonEvent.PRESSED.value:
                    self.controller_states[player_num].home = 1
                if value[1] == ButtonEvent.RELEASED.value:
                    self.controller_states[player_num].home = 0


        if event_type == ControllerUpdateTypes.JOYSTICK.value:
            if value[0] == AllButtons.left_stick.value:

                angle_radians = 2 * math.pi * (value[1] / 255)

                raw_x = value[2] * math.cos(angle_radians)
                raw_y = value[2] * math.sin(angle_radians)

                adjusted_x = min(math.floor(((raw_x / 100) * 128) + 128), 255)
                adjusted_y = min(math.floor(((raw_y / 100) * 128) + 128), 255)

                self.controller_states[player_num].left_stick_x = adjusted_x
                self.controller_states[player_num].left_stick_y = adjusted_y


            if value[0] == AllButtons.right_stick.value:
                angle_radians = 2 * math.pi * (value[1] / 255)

                raw_x = value[2] * math.cos(angle_radians)
                raw_y = value[2] * math.sin(angle_radians)

                adjusted_x = min(math.floor(((raw_x / 100) * 128) + 128), 255)
                adjusted_y = min(math.floor(((raw_y / 100) * 128) + 128), 255)

                self.controller_states[player_num].right_stick_x = adjusted_x
                self.controller_states[player_num].right_stick_y = adjusted_y

        if event_type == ControllerUpdateTypes.MOTION.value:

            self.controller_states[player_num].motion_timestamp = int(time.time() * 1_000_000)

            self.controller_states[player_num].pitch = 1 * math.degrees(value[0])
            self.controller_states[player_num].yaw = -1 * math.degrees(value[1])
            self.controller_states[player_num].roll =  1 * math.degrees(value[2])



            # Doing weird stuff 
            self.controller_states[player_num].x_acceleration = 1 * value[3] if abs(value[3]) > 0.02 else 0
            self.controller_states[player_num].z_acceleration = -1 * value[4] if abs(value[4]) > 0.02 else 0
            self.controller_states[player_num].y_acceleration =  1 * value[5] if abs(value[5]) > 0.02 else 0

            """
            self.controller_states[player_num].x_acceleration = -1 * value[3] if abs(value[3]) > 0.02 else 0
            self.controller_states[player_num].z_acceleration = 1 * value[4] if abs(value[4]) > 0.02 else 0
            self.controller_states[player_num].y_acceleration =  1 * value[5] if abs(value[5]) > 0.02 else 0
            """


DSU_Server.instance() # init and start the server immediately
