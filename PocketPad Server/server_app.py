# This Python file uses the following encoding: utf-8
import sys

import bluetooth_server

from PySide6.QtWidgets import QApplication, QMainWindow, QListWidgetItem, QMessageBox, QCheckBox, QVBoxLayout, QWidget

from PySide6.QtGui import QFont

# Important:
# You need to run the following command to generate the ui_form.py file
#     pyside6-uic PocketPad.ui -o ui_form.py, or
#     pyside2-uic form.ui -o ui_form.py
from ui_form import Ui_MainWindow

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.connected_players = []
        self.player_checkbox_mapping = {}
        self.num_players_connected = 0
        
        self.ui.bluetooth_button.clicked.connect(self.start_bluetooth_server)
        self.bluetooth_server_initiated=False

        self.ui.network_button.clicked.connect(self.start_network_server)
        self.network_server_initiated=False

        self.ui.latency_setting_box.stateChanged.connect(self.toggle_latency)

        # Callback function for updating a given player's latency
        #
        bluetooth_server.set_latency_callback(self.update_latency)
        #
        # Callback function for updating a given player's latency 
        
        # Callback function for updating player connection list
        #
        bluetooth_server.set_connection_callback(self.update_player_connection)
        #
        # Callback function for updating player connection list

        # Callback function for updating a given player's controller type (Idk if function name will differ so feel free to change)
        #
        bluetooth_server.set_connection_callback(self.update_controller_type)
        #
        # Callback function for updating a given player's controller type

        self.checkbox_container = QWidget()
        self.checkbox_layout = QVBoxLayout(self.checkbox_container)
        self.ui.controller_checkboxes.setWidget(self.checkbox_container)
        self.ui.controller_checkboxes.setWidgetResizable(True)        

        # Dev testing function calls
        #
        #self.ui.bluetooth_button.clicked.connect(lambda: self.update_player_connection("disconnect", f"player {self.num_players_connected - 1}", "xbox"))
        #self.ui.network_button.clicked.connect(lambda: self.update_player_connection("connect", f"player {self.num_players_connected}", "xbox"))
        #
        # Dev testing function calls

    def start_network_server(self):
        self.bluetooth_server_initiated=False
        if (self.network_server_initiated == False):
            self.network_server_initiated=True
        else:
            already_initiated = QMessageBox()
            already_initiated.setText("Network Server is already running")
            already_initiated.exec()

    #   This function will start up a bluetooth server (and eventually shut down a network server) using the
    #   functionality implemented for server start-up in bluetooth_server.py. If the bluetooth server is
    #   already advertising, it will display a messagebox on the user's screen letting them know that the
    #   bluetooth server is already advertising. 
    #
    #   @param: self - the instance of the PocketPadWindow
    #
    #   @return: none
    #
    def start_bluetooth_server(self):
        self.network_server_initiated=False
        if not self.bluetooth_server_initiated:
            self.bluetooth_server_initiated=True
            bluetooth_server.start_server()
        else:
            already_initiated = QMessageBox()
            already_initiated.setText("Bluetooth Server is already running")
            already_initiated.exec()

    #   This function will update the different labels and icons for the a player's device latency. This function
    #   takes in a player identifier and the device latency, and it will update the corresponding widgets on the
    #   PocketPadWindow that are used to display representations of device latency by updating the text and color
    #   of those different widgets. 
    #
    #   @param: self - the instance of the PocketPadWindow
    #           player_id - a string storing a data identifier corresponding to a given player/device
    #           latency - a float containing the latency of the connected device 
    #
    #   @return: none
    #
    def update_latency(self, player_id, latency):
        if self.ui.latency_setting_box.isChecked():
            # Implementation is in later sprint, so dummy implementation for server tests
            #
            latency_item = QListWidgetItem()
            latency_item.setText(latency)
            self.ui.connection_list.addItem(latency_item)
            #
            # Implementation is in later sprint, so dummy implementation for server tests

    #   This function will update the visibilty of the different labels and icons used to display
    #   device latency. This function will update visibility of the corresponding widgets on the
    #   PocketPadWindow that are used to display representations of the device latency depending on
    #   state of the latency setting checkbox
    #
    #   @param: self - the instance of the PocketPadWindow
    #
    #   @return: none
    #
    def toggle_latency(self):
        print()
        if self.ui.latency_setting_box.isChecked():
            print("Display Latency")
        else:
            print("Hide Latency")
    
    def update_player_connection(self, connection, player_id, controller_type):
        if (connection == "connect"):
            if player_id not in self.connected_players:
                player_connection = QListWidgetItem()

                # Generate player name
                #
                player_connection_font = QFont()
                player_connection_font.setPointSize(14)
                player_connection.setText(player_id)
                player_connection.setFont(player_connection_font)
                self.connected_players.append(player_id)
                #
                # Generate player name
                
                # Implement functionality for creating icons
                #
                #if (controller_type == "custom"):
                #    player_connection.setIcon(QIcon(_<enter path to icon>_))
                #elif ():
                #
                # Implement functionality for creating icons

                self.ui.connection_list.addItem(player_connection)

                # Generate user checkboxes
                #
                controller_checkbox = QCheckBox(f"Display {player_id}'s inputs")
                controller_checkbox.setStyleSheet("QCheckBox { font-size: 16px; background-color: transparent;}")
                controller_checkbox.setMinimumHeight(25)
                controller_checkbox.setMaximumHeight(50)
                #controller_checkbox.stateChanged.connect(lambda state, cb=controller_checkbox: self.on_checkbox_toggled(cb, state))
                self.checkbox_layout.addWidget(controller_checkbox)
                self.player_checkbox_mapping[player_id] = controller_checkbox
                #
                # Generate user checkboxes 

                # Implement generate controller mockup
                #
                
                #
                # Implement generate controller mockup

                # Update number of connected users
                #
                self.num_players_connected+=1
                self.ui.num_connected_label.setText(f"{self.num_players_connected}/4")
                #
                # Update number of connected users
            else:
                already_initiated = QMessageBox()
                already_initiated.setText(f"A player with player_id, {player_id}, already is connected")
                already_initiated.exec()

        elif (connection == "disconnect"):

            for player_index in range(self.ui.connection_list.count()):
                player_connection = self.ui.connection_list.item(player_index)
                if (player_connection.text() == player_id):
                    self.ui.connection_list.takeItem(player_index)

            # Remove player's checkbox
            #
            if (player_id in self.player_checkbox_mapping):
                controller_checkbox = self.player_checkbox_mapping[player_id]
                self.checkbox_layout.removeWidget(controller_checkbox)
                controller_checkbox.deleteLater()
                del self.player_checkbox_mapping[player_id]
            else:
                already_initiated = QMessageBox()
                already_initiated.setText(f"A player with player_id, {player_id}, does not exist")
                already_initiated.exec()
            #
            # Remove player's checkbox

            # Implement remove controller mockups
            #

            #
            # Implement remove controller mockups
            
            if (player_id in self.connected_players):
                self.connected_players.remove(player_id)
                self.num_players_connected-=1
                self.ui.num_connected_label.setText(f"{self.num_players_connected}/4")
            else:
                already_initiated = QMessageBox()
                already_initiated.setText(f"A player with player_id, {player_id}, does not exist")
                already_initiated.exec()

    def update_controller_type(self, player_id, controller_type):
        print("Updating Controller")

    def display_controller_input(self, player_id, input):
        print("Display Controller Input")

    def toggle_controller_input(self, player_id):
        print("Toggling Controller Input")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec())
