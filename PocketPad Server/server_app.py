import random

# This Python file uses the following encoding: utf-8
import sys

import bluetooth_server

import xml.etree.ElementTree as ET

from PySide6.QtWidgets import QApplication, QMainWindow, QListWidgetItem, QMessageBox, QCheckBox, QVBoxLayout, QWidget, QLabel, QHBoxLayout, QFrame, QGridLayout, QSystemTrayIcon, QMenu
from PySide6.QtCore import Qt, QSettings, QByteArray, QBuffer, QSize
from PySide6.QtGui import QFont, QIcon, QAction, QPixmap, QPainter, QImage, QColor
from PySide6.QtSvg import QSvgRenderer

# Important:
# You need to run the following command to generate the ui_form.py file
#     pyside6-uic PocketPad.ui -o ui_form.py
from ui_form import Ui_MainWindow

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super().__init__(parent)

        self.settings = QSettings("YourCompany", "PocketPad")

        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.setWindowIcon(QIcon("icons/logo.png"))
        self.application_background_color = "#242424"
        self.application_widgets_color = "#474747"
        self.application_font_color = "#FFFFFF"
        
        # Set the Application Icon  with correct image to appear in the tray
        #
        self.tray_icon = QSystemTrayIcon(QIcon("icons/logo.png"), self)
        self.tray_icon.setToolTip("PocketPad")

        tray_menu = QMenu()
        quit_action = QAction("Quit", self)
        quit_action.triggered.connect(QApplication.instance().quit)
        tray_menu.addAction(quit_action)
        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.show()
        #
        # Set the Application Icon with correct image to appear in the tray

        self.player_latency = {}
        self.connected_players = []
        self.player_checkbox_mapping = {}
        self.player_controller_mapping = {}
        self.player_svg_paths_for_icons = {}
        self.player_controller_input_display = {}
        self.num_players_connected = 0
        
        self.hazard_icon = self.get_icon_from_svg("icons/hazard.svg", "#Ff0000")

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
        bluetooth_server.set_controller_callback(self.update_controller_type)
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
        self.ui.controller_mockup_area.setFrameShape(QFrame.StyledPanel)
        self.ui.controller_mockup_area.setContentsMargins(10, 10, 10, 10)
        self.controller_grid_layout = QGridLayout(self.ui.controller_mockup_area)
        self.controller_grid_layout.setAlignment(Qt.AlignTop | Qt.AlignLeft)
        self.controller_grid_layout.setSpacing(5)
        self.ui.controller_mockup_area.setLayout(self.controller_grid_layout)
        #
        # Widget and widget layout for controller mockups

        # Dev testing function calls
        #

        #self.ui.bluetooth_button.clicked.connect(lambda: self.update_player_connection("disconnect", f"player {self.num_players_connected - 1}", "switch"))
        #self.ui.bluetooth_button.clicked.connect(lambda: self.dev_testing(f"player {self.num_players_connected - 1}", random.randint(1, 4)))
        #self.ui.network_button.clicked.connect(lambda: self.update_player_connection("connect", f"player {self.num_players_connected}", "switch"))
        #self.ui.server_close_button.clicked.connect(lambda: self.update_latency(f"player {self.num_players_connected - 1}", random.randint(1, 200)))

        #
        # Dev testing function calls

        self.load_application_settings(None)

    # REMOVE AFTER SPRINTS
    def dev_testing(self, player_id, num):
        options = ["switch", "xbox", "playstation", "wii"]
        selected_option = options[num-1]
        self.update_controller_type(player_id, selected_option)
    # REMOVE AFTER SPRINTS
    
    # NEEDS WORK
    def update_application_color(self):
        """
        This function will update the style sheet of the different widgets based on the
        color preferences of the user as stored in different variables
    
        @param: self - the instance of the PocketPadWindow
     
        @return: none
        """
        self.setStyleSheet(f"""QMainWindow {{background-color: {self.application_background_color}}}""")
        self.ui.connection_list_area.setStyleSheet(f"""QFrame {{background-color: {self.application_widgets_color}}};
                                                    border-radius: 10px;
                                                    border: none;""")
        self.ui.settings_area.setStyleSheet(f"""QFrame {{background-color: {self.application_widgets_color}}};
                                            border-radius: 20px;""")
        self.ui.connection_code_box.setStyleSheet(f"""QFrame {{background-color: {self.application_widgets_color}}};
                                                  border-radius: 20px;""")
        self.ui.controller_mockup_area.setStyleSheet(f"""QFrame {{background-color: {self.application_widgets_color}}};
                                                     border-radius: 20px;""")
    # NEEDS WORK

    # NEEDS WORK
    def start_network_server(self):
        self.bluetooth_server_initiated=False
        if (self.network_server_initiated == False):
            self.network_server_initiated=True
            #bluetooth_server.stop_server()
        else:
            already_initiated = QMessageBox()
            already_initiated.setText("Network Server is already running")
            already_initiated.exec()
    # NEEDS WORK

    def start_bluetooth_server(self):
        """
        This function will start up a bluetooth server (and eventually shut down a network server) using the
        functionality implemented for server start-up in bluetooth_server.py. If the bluetooth server is
        already advertising, it will display a messagebox on the user's screen letting them know that the
        bluetooth server is already advertising. 
    
        @param: self - the instance of the PocketPadWindow
     
        @return: none
        """
        self.network_server_initiated=False
        if not self.bluetooth_server_initiated:
            self.bluetooth_server_initiated=True
            #bluetooth_server.start_server()
        else:
            already_initiated = QMessageBox()
            already_initiated.setText("Bluetooth Server is already running")
            already_initiated.exec()

    def update_latency(self, player_id, latency):
        """
        This function will update the different labels and icons for the a player's device latency. This function
        takes in a player identifier and the device latency, and it will update the corresponding widgets on the
        PocketPadWindow that are used to display representations of device latency by updating the text and color
        of those different widgets. 
     
        @param: self - the instance of the PocketPadWindow
                player_id - a string storing a data identifier corresponding to a given player/device
                latency - a float containing the latency of the connected device 
     
        @return: none
        """
        if self.ui.latency_setting_box.isChecked():
            if player_id in self.player_controller_mapping:
                self.player_latency[player_id] = latency
                
                # Text change for latency
                #
                self.player_controller_mapping[player_id]["latency_label"].setText(f"{latency} ms")
                #
                # Text change for latency

                # Color change for latency
                #
                new_icon_svg = self.player_svg_paths_for_icons[player_id]
                if (latency <= 50):
                    player_icon = self.get_icon_from_svg(new_icon_svg, "#3BB20A")
                elif ((latency > 50) and (latency <= 100)):
                    player_icon = self.get_icon_from_svg(new_icon_svg, "#e6cc00")
                elif ((latency > 100) and (latency <= 150)):
                    player_icon = self.get_icon_from_svg(new_icon_svg, "#Ff0000")
                else:
                    player_icon = self.hazard_icon

                for player_index in range(self.ui.connection_list.count()):
                    player_connection = self.ui.connection_list.item(player_index)

                    if ((player_connection != None) and (player_connection.text() == player_id)):
                        player_connection.setIcon(player_icon)
                #
                # Color change for latency

    def toggle_latency(self):
        """
        This function will update the visibilty of the different labels and icons used to display
        device latency. This function will update visibility of the corresponding widgets on the
        PocketPadWindow that are used to display representations of the device latency depending on
        state of the latency setting checkbox
     
        @param: self - the instance of the PocketPadWindow
     
        @return: none
        """
        if self.ui.latency_setting_box.isChecked():
            for player_id in self.player_controller_mapping:
                # Change latency label visibilty
                #
                self.player_controller_mapping[player_id]["latency_label"].setVisible(True)

                self.update_latency(player_id, self.player_latency[player_id])
                #
                # Change latency label visibilty
        else:
            for player_id in self.player_controller_mapping:
                # Change latency label visibilty
                #
                self.player_controller_mapping[player_id]["latency_label"].setVisible(False)

                player_icon = self.get_icon_from_svg(self.player_svg_paths_for_icons[player_id], self.application_font_color)

                for player_index in range(self.ui.connection_list.count()):
                    player_connection = self.ui.connection_list.item(player_index)

                    if ((player_connection != None) and (player_connection.text() == player_id)):
                        player_connection.setIcon(player_icon)
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
                
                # Creating icons
                #
                if (controller_type == "playstation"):
                    icon_type = "icons/playstation.svg"
                elif (controller_type == "switch"):
                    icon_type = "icons/switch.svg"
                elif (controller_type == "wii"):
                    icon_type = "icons/wii.svg"
                elif (controller_type == "xbox"):
                    icon_type = "icons/xbox.svg"


                self.player_svg_paths_for_icons[player_id] = icon_type
                self.player_latency[player_id] = 0
                if (self.ui.latency_setting_box.isChecked()):
                    player_icon = self.get_icon_from_svg(icon_type, "#3BB20A")
                else:
                    player_icon = self.get_icon_from_svg(icon_type, self.application_font_color)
                player_connection.setIcon(player_icon)
                #
                # Creating icons

                self.ui.connection_list.addItem(player_connection)

                # Generate user checkboxes
                #
                controller_checkbox = QCheckBox(f"Display {player_id}'s inputs")
                controller_checkbox.setStyleSheet("QCheckBox { font-size: 16px; background-color: transparent;}")
                controller_checkbox.setMinimumHeight(25)
                controller_checkbox.setMaximumHeight(50)
                controller_checkbox.setChecked(True)
                controller_checkbox.toggled.connect(lambda: self.toggle_controller_input(controller_checkbox, player_id))
                self.player_checkbox_mapping[player_id] = controller_checkbox
                self.checkbox_layout.addWidget(controller_checkbox)
                self.player_controller_input_display[player_id] = True
                #
                # Generate user checkboxes 

                # Implement generate controller mockup
                #
                controller_widget = QWidget()
        
                controller_name = QLabel(f"{player_id}'s Controller")
                controller_latency = QLabel("0 ms")
                if not self.ui.latency_setting_box.isChecked():
                    controller_latency.setVisible(False)
        
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

            if (player_id in self.connected_players):
                # Remove player's checkbox
                #
                if (player_id in self.player_checkbox_mapping):
                    controller_checkbox = self.player_checkbox_mapping[player_id]
                    self.checkbox_layout.removeWidget(controller_checkbox)
                    controller_checkbox.deleteLater()
                    del self.player_checkbox_mapping[player_id]
                    #self.refresh_grid_layout((self.num_players_connected-1))
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
                #
                # Implement remove controller mockups
            
                self.connected_players.remove(player_id)
                del self.player_latency[player_id]
                del self.player_svg_paths_for_icons[player_id]
                del self.player_controller_input_display[player_id]
                self.num_players_connected-=1
                self.ui.num_connected_label.setText(f"{self.num_players_connected}/4")
            else:
                already_initiated = QMessageBox()
                already_initiated.setText(f"A player with player_id, {player_id}, does not exist")
                already_initiated.exec()

    def update_controller_type(self, player_id, controller_type):
        """
        Update the icon for the player whose player id is passed as a parameter to the function. Depending on
        the controller type passed to the function, it will swap the svg path for the correct svg and  

        @param: self - the instance of the PocketPadWindow
                player_id - a string storing a data identifier corresponding to a given player/device
                controller_type - the type of the controller that the user is now tryign to connect with

        @return: none
        """
        if (controller_type == "playstation"):
            icon_type = "icons/playstation.svg"
        elif (controller_type == "switch"):
            icon_type = "icons/switch.svg"
        elif (controller_type == "wii"):
            icon_type = "icons/wii.svg"
        elif (controller_type == "xbox"):
            icon_type = "icons/xbox.svg"

        self.player_svg_paths_for_icons[player_id] = icon_type        

        latency = self.player_latency[player_id]
        if (latency <= 50):
            player_icon = self.get_icon_from_svg(icon_type, "#3BB20A")
        elif ((latency > 50) and (latency <= 100)):
            player_icon = self.get_icon_from_svg(icon_type, "#e6cc00")
        elif ((latency > 100) and (latency <= 150)):
            player_icon = self.get_icon_from_svg(icon_type, "#Ff0000")
        else:
            player_icon = self.hazard_icon

        for player_index in range(self.ui.connection_list.count()):
            player_connection = self.ui.connection_list.item(player_index)

            if ((player_connection != None) and (player_connection.text() == player_id)):
                player_connection.setIcon(player_icon)

        # Implement Updating controller mockups (later sprint)
        #

        #
        # Implement Updating controller mockups (later sprint)

    def display_controller_input(self, player_id, input):
        if self.player_controller_input_display[player_id]:
            print("Display Controller Input")
            # Implement in later sprint
            #

            #
            # Implement in later sprint
    
    def toggle_controller_input(self, checkbox, player_id):
        """
        This function edits the boolean characteristic for a given player which will determine whether or not
        that players controller inputs will be displayed on PocketPad's server application. If the checkbox is
        checked it will set the corresponding player's characteristic to true and vice versa if the checkbox is
        not checked.
    
        @param: self - the instance of the PocketPadWindow
                checkbox - a checkbox widget currently within the instance of PocketPadWindow 
                player_id - a string storing a data identifier corresponding to a given player/device
     
        @return: none
        """
        if checkbox.isChecked():
            self.player_controller_input_display[player_id] = True
        else:
            self.player_controller_input_display[player_id] = False
    
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

    def get_icon_from_svg(self, svg_path, color):
        """
        Using a pased path to a svg file and a color represented in hexidecimal format, contstruct
        a QIcon by converting the svg into an image of the passed color to be later converted into
        a QIcon to be returned by the function.

        @param: svg_path - a path to a svg file
                color - hexidecimal representation of a color

        @return: player_icon - a QIcon representing the player's connected controller type
        """
        renderer = QSvgRenderer(svg_path)
        image = QImage(32, 32, QImage.Format_ARGB32)
        image.fill(0) 
        painter = QPainter(image)
        renderer.render(painter)
        painter.setCompositionMode(QPainter.CompositionMode_SourceIn)
        painter.fillRect(image.rect(), QColor(color))
        painter.end()     

        player_icon = QIcon(QPixmap.fromImage(image))

        return player_icon
        
    
    def load_application_settings(self, event):
        """
        Loads the players saved data/state into the format/look of the application

        @param: self - the instance of the PocketPadWindow
                event - an event that triggered the function call 
     
        @return: none
        """
        self.settings.beginGroup("Checkbox Settings")
        latency_checkbox_state = self.settings.value("latency_checkbox", True, type=bool)
        self.settings.endGroup()

        self.ui.latency_setting_box.setChecked(latency_checkbox_state)

        self.settings.beginGroup("Color Settings")
        self.application_background_color = self.settings.value("background_color", "#ffffff", type=str)
        self.application_widgets_color = self.settings.value("widget_color", "#ffffff", type=str)
        self.application_font_color = self.settings.value("font_color", "#ffffff", type=str)
        self.settings.endGroup()

        #self.update_application_color()

    def closeEvent(self, event):
        """
        Saves the players data/state into QSettings for future use of the application

        @param: self - the instance of the PocketPadWindow
                event - an event that triggered the function call
     
        @return: none
        """
        self.settings.beginGroup("Checkbox Settings")
        self.settings.setValue("latency_checkbox", self.ui.latency_setting_box.isChecked())
        self.settings.endGroup()
        
        self.settings.beginGroup("Color Settings")
        self.settings.setValue("background_color", self.application_background_color)
        self.settings.setValue("widget_color", self.application_widgets_color)
        self.settings.setValue("font_color", self.application_font_color)
        self.settings.endGroup()
        super().closeEvent(event)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setWindowIcon(QIcon("icons/logo.png"))
    widget = MainWindow()
    widget.show()
    sys.exit(app.exec())
