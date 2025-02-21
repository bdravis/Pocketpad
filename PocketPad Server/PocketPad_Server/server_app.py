# This Python file uses the following encoding: utf-8
import sys

import bluetooth as server

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

        server.set_latency_callback(self.update_latency)


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

    
    def update_latency(self, player_id, latency):
        latency_item = QListWidgetItem()
        latency_item.setText(latency)
        self.ui.connection_list.addItem(latency_item)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec())
