# This Python file uses the following encoding: utf-8
import sys

from Server_Implementation import bluetooth

from PySide6.QtWidgets import QApplication, QMainWindow, QListWidgetItem, QMessageBox

# Important:
# You need to run the following command to generate the ui_form.py file
#     pyside6-uic form.ui -o ui_form.py, or
#     pyside2-uic form.ui -o ui_form.py
from ui_form import Ui_MainWindow

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        self.ui.bluetooth_button.clicked.connect(self.start_bluetooth_server)
        self.bluetooth_server_initiated=False

        self.ui.network_button.clicked.connect(self.start_network_server)
        self.network_server_initiated=False

        self.ui.latency_setting_box.stateChanged.connect(self.toggle_latency)

        #server.set_latency_callback(self.update_latency)

        self.connected_players = []
        #server.set_connection_callback(self.update_player_connection)

        #server.set_connection_callback(self.update_controller_type)


    def start_network_server(self):
        self.bluetooth_server_initiated=False
        if (self.network_server_initiated == False):
            self.network_server_initiated=True
        else:
            already_initiated = QMessageBox()
            already_initiated.setText("Network Server is already running")
            already_initiated.exec()

    
    def start_bluetooth_server(self):
        self.network_server_initiated=False
        if (self.bluetooth_server_initiated == False):
            self.bluetooth_server_initiated=True
            # Function to start up Bluetooth server
            #

            #
            # Function to start up Bluetooth server
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
        print("Updating Player Connection")
        if connection == "connect":
            print("Connect")

        elif connection == "disconnect":
            print("Disconnect")

    def update_controller_type(self, player_id, controller_type):
        print("Updating Controller")

    def toggle_controller_input(self, player_id):
        print("Toggling Controller Input")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec())
