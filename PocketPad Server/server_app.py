import random

# This Python file uses the following encoding: utf-8
import sys

import bluetooth_server

from PySide6.QtWidgets import QApplication, QMainWindow, QListWidgetItem, QMessageBox, QCheckBox, QVBoxLayout, QWidget, QLabel, QHBoxLayout, QFrame, QGridLayout
from PySide6.QtCore import Qt

from PySide6.QtGui import QFont

# Important:
# You need to run the following command to generate the ui_form.py file
#     pyside6-uic PocketPad.ui -o ui_form.py, or
from ui_form import Ui_MainWindow

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.connected_players = []
        self.player_checkbox_mapping = {}
        self.player_controller_mapping = {}
        self.player_controller_input_display = {}
        self.num_players_connected = 0
        
        #self.ui.bluetooth_button.clicked.connect(self.start_bluetooth_server)
        self.bluetooth_server_initiated=False

        #self.ui.network_button.clicked.connect(self.start_network_server)
        self.network_server_initiated=False

        self.ui.latency_setting_box.stateChanged.connect(self.toggle_latency)

        # Callback function for updating a given player's latency
        #
        #bluetooth_server.set_latency_callback(self.update_latency)
        #
        # Callback function for updating a given player's latency 
        
        # Callback function for updating player connection list
        #
        #bluetooth_server.set_connection_callback(self.update_player_connection)
        #
        # Callback function for updating player connection list

        # Callback function for updating a given player's controller type (Idk if function name will differ so feel free to change)
        #
        #bluetooth_server.set_connection_callback(self.update_controller_type)
        #
        # Callback function for updating a given player's controller type

        # Widget and widget layout for input checkboxes
        #
        self.checkbox_container = QWidget()
        self.checkbox_layout = QVBoxLayout(self.checkbox_container)
        self.ui.controller_checkboxes.setWidget(self.checkbox_container)
        self.ui.controller_checkboxes.setWidgetResizable(True)
        #
        # Widget and widget layout for input checkboxes

        # Widget and widget layout for controller mockups
        #
        self.ui.graphicsView.setFrameShape(QFrame.StyledPanel)
        self.ui.graphicsView.setContentsMargins(10, 10, 10, 10)
        self.controller_grid_layout = QGridLayout(self.ui.graphicsView)
        self.controller_grid_layout.setAlignment(Qt.AlignTop | Qt.AlignLeft)
        self.controller_grid_layout.setSpacing(5)
        self.ui.graphicsView.setLayout(self.controller_grid_layout)
        #
        # Widget and widget layout for controller mockups

        # Dev testing function calls
        #
        self.ui.bluetooth_button.clicked.connect(lambda: self.update_player_connection("disconnect", f"player {self.num_players_connected - 2}", "xbox"))
        self.ui.network_button.clicked.connect(lambda: self.update_player_connection("connect", f"player {self.num_players_connected}", "xbox"))
        self.ui.server_close_button.clicked.connect(lambda: self.update_latency(f"player {self.num_players_connected-2}", random.randint(1, 100)))
        #
        # Dev testing function calls

    # NEEDS WORK
    def start_network_server(self):
        self.bluetooth_server_initiated=False
        if (self.network_server_initiated == False):
            self.network_server_initiated=True
            bluetooth_server.stop_server()
        else:
            already_initiated = QMessageBox()
            already_initiated.setText("Network Server is already running")
            already_initiated.exec()
    # NEEDS WORK

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
            if player_id in self.player_controller_mapping:
                # Text change for latency
                #
                self.player_controller_mapping[player_id]["latency_label"].setText(f"{latency} ms")
                #
                # Text change for latency

                # Implement color change for latency (need access to icon's first)
                #

                #
                # Implement color change for latency (need access to icon's first)

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
        if self.ui.latency_setting_box.isChecked():
            for player_id in self.player_controller_mapping:
                # Change latency label visibilty
                #
                self.player_controller_mapping[player_id]["latency_label"].setVisible(True)
                #
                # Change latency label visibilty
        else:
            for player_id in self.player_controller_mapping:
                # Change latency label visibilty
                #
                self.player_controller_mapping[player_id]["latency_label"].setVisible(False)
                #
                # Change latency label visibilty
    
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
                controller_checkbox.setChecked(True)
                controller_checkbox.stateChanged.connect(lambda: self.toggle_controller_input(controller_checkbox, player_id))
                self.checkbox_layout.addWidget(controller_checkbox)
                self.player_checkbox_mapping[player_id] = controller_checkbox
                self.player_controller_input_display[player_id] = True
                #
                # Generate user checkboxes 

                # Implement generate controller mockup
                #
                controller_widget = QWidget()
        
                controller_name = QLabel(f"{player_id}'s Controller")
                controller_latency = QLabel("0 ms")
        
                text_format_layout = QHBoxLayout()
                text_format_layout.addWidget(controller_name)
                text_format_layout.addWidget(controller_latency)
        
                controller_widget.setLayout(text_format_layout)
        
                main_layout = QVBoxLayout()
                main_layout.addWidget(controller_widget)
                main_layout.addStretch()

                self.controller_grid_layout.addWidget(controller_widget, (self.num_players_connected//2), (self.num_players_connected%2))                
        
                self.player_controller_mapping[player_id] = {
                    "widget": controller_widget,
                    "latency_label": controller_latency
                }

                # Set the main layout on the widget.
                self.setLayout(main_layout)
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

                if ((player_connection != None) and (player_connection.text() == player_id)):
                    self.ui.connection_list.takeItem(player_index)

            # Remove player's checkbox
            #
            if (player_id in self.player_checkbox_mapping):
                controller_checkbox = self.player_checkbox_mapping[player_id]
                self.checkbox_layout.removeWidget(controller_checkbox)
                controller_checkbox.deleteLater()
                del self.player_checkbox_mapping[player_id]
                self.refresh_grid_layout((self.num_players_connected-1))
            else:
                already_initiated = QMessageBox()
                already_initiated.setText(f"A player with player_id, {player_id}, does not exist")
                already_initiated.exec()
            #
            # Remove player's checkbox

            # Implement remove controller mockups
            #
            if (player_id in self.player_controller_mapping):
                controller_info = self.player_controller_mapping[player_id]
                controller_widget = controller_info["widget"]
                self.controller_grid_layout.removeWidget(controller_widget)
                controller_widget.deleteLater()
                del self.player_controller_mapping[player_id]
            else:
                already_initiated = QMessageBox()
                already_initiated.setText(f"A player with player_id, {player_id}, does not exist")
                already_initiated.exec()
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

    
    #   This function edits the boolean characteristic for a given player which will determine whether or not
    #   that players controller inputs will be displayed on PocketPad's server application. If the checkbox is
    #   checked it will set the corresponding player's characteristic to true and vice versa if the checkbox is
    #   not checked.
    #
    #   @param:  self - the instance of the PocketPadWindow
    #           checkbox - a checkbox widget currently within the instance of PocketPadWindow 
    #           player_id - a string storing a data identifier corresponding to a given player/device
    #
    #   @return: none
    #
    def toggle_controller_input(self, checkbox, player_id):
        if checkbox.isChecked():
            self.player_controller_input_display[player_id] = True
        else:
            self.player_controller_input_display[player_id] = True

    
    # NEEDS WORKS 
    def refresh_grid_layout(self, index):
        for controller_index in reversed(range(index, self.controller_grid_layout.count())):
            print(controller_index)
            controller_item = self.controller_grid_layout.itemAt(controller_index)
            if controller_item:
                controller_widget = controller_item.widget()
                if controller_widget:
                    self.controller_grid_layout.removeWidget(controller_widget)
                    controller_widget.setParent(None)
        
        #row = 0
        #column = 0
        #for player_id, controller_info in self.player_controller_mapping.items():
        #    self.controller_grid_layout.addWidget(controller_info["widget"], row, column)
        #    column += 1
        #    if column == 2:
        #        column = 0
        #        row += 1

    # NEEDS WORKS


if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec())
