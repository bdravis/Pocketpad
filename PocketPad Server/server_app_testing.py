import sys
import json
import enums
import pytest
import asyncio
import unittest
from unittest.mock import MagicMock, patch, AsyncMock
from PySide6.QtWidgets import QMessageBox, QListWidgetItem, QColorDialog, QDialog, QWidget, QPushButton, QApplication, QGridLayout
from PySide6.QtGui import QIcon, QCloseEvent, QColor
from PySide6.QtCore import Qt, QSettings
from server_app import MainWindow
from server_app import ColorPickerPopup
from server_app import ControllerWidget

@pytest.fixture
def main_window(qtbot):
    """
    Function that creates a testing instance of the server application of PocketPad

    @param:
        qtbot - fixture provided by pytest-qt for GUI testing
    
    @return:
        window - an instance of the MainWidow used to display the PocketPad application
    """
    test_window = MainWindow()
    test_window.setAttribute(Qt.WA_DontShowOnScreen, True)
    qtbot.addWidget(test_window)
    test_window.show()
    qtbot.wait(100)
    return test_window

def test_app_launch(main_window):
    """
    Function to test whether the GUI window successfully loads up.

    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
    """
    assert main_window.isVisible()

def test_load_application_settings(main_window):
    """
    Test if load_application_settings correctly loads the saved settings into the UI elements and
    different variables
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application.
    """
    # Ensure QSettings is using a test-specific scope
    main_window.settings = QSettings("test_organization", "test_application")

    main_window.settings.beginGroup("Checkbox Settings")
    main_window.settings.setValue("latency_checkbox", True)
    main_window.settings.endGroup()

    main_window.settings.beginGroup("Color Settings")
    main_window.settings.setValue("background_color", "#242424")
    main_window.settings.setValue("widget_color", "#474747")
    main_window.settings.setValue("font_color", "#ffffff")
    main_window.settings.endGroup()

    # Call the function under test
    main_window.load_application_settings(None)

    # Verify if values were loaded correctly
    assert main_window.ui.latency_setting_box.isChecked() is True
    assert main_window.application_background_color == "#242424"
    assert main_window.application_widgets_color == "#474747"
    assert main_window.application_font_color == "#ffffff"

def test_closeEvent_saves_settings(main_window):
    """
    Test if closeEvent correctly saves the proper UI settings into QSettings to be reloaded at a later date
    to keep the application uniform with user preferences 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application.
    """
    test_settings = QSettings("test_organization", "test_application")
    main_window.settings = test_settings
    
    main_window.ui.latency_setting_box.setChecked(False)
    main_window.application_background_color = "#242424"
    main_window.application_widgets_color = "#474747"
    main_window.application_font_color = "#ffffff"

    event = QCloseEvent()
    main_window.closeEvent(event)

    # Re-load settings and verify they were saved correctly
    settings = QSettings("test_organization", "test_application")
    
    settings.beginGroup("Checkbox Settings")
    assert settings.value("latency_checkbox", type=bool) is False
    settings.endGroup()

    settings.beginGroup("Color Settings")
    assert settings.value("background_color", type=str) == "#242424"
    assert settings.value("widget_color", type=str) == "#474747"
    assert settings.value("font_color", type=str) == "#ffffff"
    settings.endGroup()

def test_new_player_connection(main_window):
    """
    Function to test whether the update_player_connection function works as intended or not, creating the widgets
    and assigning variables the correct values when a user is connecting to the server/application
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
    """
    main_window.get_icon_from_svg = MagicMock()

    print("Connect User")
    player_ids = ["player_1", "player_2", "player_3"]
    controller_types = [enums.ControllerType.Switch, enums.ControllerType.Xbox, enums.ControllerType.Playstation]
    json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
    json_str = json.dumps(json_file)

    main_window.get_icon_from_svg = MagicMock(return_value=QIcon())

    main_window.update_player_connection("connect", player_ids[0], controller_types[0], json_str)

    assert player_ids[0] in main_window.connected_players
    assert f"icons/switch.svg" in main_window.player_svg_paths_for_icons[player_ids[0]]
    assert main_window.ui.connection_list.count() == 1
    assert main_window.ui.num_connected_label.text() == "1/4"
    assert main_window.player_latency[player_ids[0]] == 0
    assert main_window.player_svg_paths_for_icons[player_ids[0]] == "icons/switch.svg"
    if main_window.ui.latency_setting_box.isChecked():
        main_window.get_icon_from_svg.assert_any_call("icons/switch.svg", "#3BB20A")
    else:
        main_window.get_icon_from_svg.assert_any_call("icons/switch.svg", main_window.application_font_color)
    assert player_ids[0] in main_window.player_checkbox_mapping
    assert player_ids[0] in main_window.player_controller_input_display
    assert main_window.player_controller_input_display[player_ids[0]] is True

    main_window.update_player_connection("connect", player_ids[1], controller_types[1], json_str)

    assert player_ids[1] in main_window.connected_players
    assert f"icons/xbox.svg" in main_window.player_svg_paths_for_icons[player_ids[1]]
    assert main_window.ui.connection_list.count() == 2
    assert main_window.ui.num_connected_label.text() == "2/4"
    assert main_window.player_latency[player_ids[1]] == 0
    assert main_window.player_svg_paths_for_icons[player_ids[1]] == "icons/xbox.svg"
    if main_window.ui.latency_setting_box.isChecked():
        main_window.get_icon_from_svg.assert_any_call("icons/xbox.svg", "#3BB20A")
    else:
        main_window.get_icon_from_svg.assert_any_call("icons/xbox.svg", main_window.application_font_color)
    assert player_ids[1] in main_window.player_checkbox_mapping
    assert player_ids[1] in main_window.player_controller_input_display
    assert main_window.player_controller_input_display[player_ids[1]] is True

    main_window.update_player_connection("connect", player_ids[2], controller_types[2], json_str)

    assert player_ids[2] in main_window.connected_players
    assert f"icons/playstation.svg" in main_window.player_svg_paths_for_icons[player_ids[2]]
    assert main_window.ui.connection_list.count() == 3
    assert main_window.ui.num_connected_label.text() == "3/4"
    assert main_window.player_latency[player_ids[2]] == 0
    assert main_window.player_svg_paths_for_icons[player_ids[2]] == "icons/playstation.svg"
    if main_window.ui.latency_setting_box.isChecked():
        main_window.get_icon_from_svg.assert_any_call("icons/playstation.svg", "#3BB20A")
    else:
        main_window.get_icon_from_svg.assert_any_call("icons/playstation.svg", main_window.application_font_color)
    assert player_ids[2] in main_window.player_checkbox_mapping
    assert player_ids[2] in main_window.player_controller_input_display
    assert main_window.player_controller_input_display[player_ids[2]] is True

def test_existing_player_disconnection(main_window):
    """
    Function to test whether the update_player_connection function works as intended or not, deleting the widgets
    and assigning variables of the user when a user is disconnecting from the server/application
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
    """
    main_window.get_icon_from_svg = MagicMock()

    print("Connect User")
    player_ids = ["player_1", "player_2", "player_3"]
    controller_types = [enums.ControllerType.Switch, enums.ControllerType.Xbox, enums.ControllerType.Playstation]
    json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
    json_str = json.dumps(json_file)

    main_window.get_icon_from_svg = MagicMock(return_value=QIcon())

    main_window.update_player_connection("connect", player_ids[0], controller_types[0], json_str)
    main_window.update_player_connection("connect", player_ids[1], controller_types[1], json_str)
    main_window.update_player_connection("connect", player_ids[2], controller_types[2], json_str)

    main_window.update_player_connection("disconnect", player_ids[0], controller_types[0], None)

    assert player_ids[0] not in main_window.connected_players
    assert f"icons/{controller_types[0]}.svg" not in main_window.player_svg_paths_for_icons
    assert main_window.ui.connection_list.count() == 2
    assert main_window.ui.num_connected_label.text() == "2/4"
    assert player_ids[0] not in main_window.player_latency
    assert player_ids[0] not in main_window.player_svg_paths_for_icons
    assert player_ids[0] not in main_window.player_checkbox_mapping
    assert player_ids[0] not in main_window.player_controller_input_display
    assert player_ids[0] not in main_window.player_controller_input_display

    main_window.update_player_connection("disconnect", player_ids[1], controller_types[1], None)

    assert player_ids[1] not in main_window.connected_players
    assert f"icons/{controller_types[1]}.svg" not in main_window.player_svg_paths_for_icons
    assert main_window.ui.connection_list.count() == 1
    assert main_window.ui.num_connected_label.text() == "1/4"
    assert player_ids[1] not in main_window.player_latency
    assert player_ids[1] not in main_window.player_svg_paths_for_icons
    assert player_ids[1] not in main_window.player_checkbox_mapping
    assert player_ids[1] not in main_window.player_controller_input_display
    assert player_ids[1] not in main_window.player_controller_input_display

    main_window.update_player_connection("disconnect", player_ids[2], controller_types[2], None)

    assert player_ids[2] not in main_window.connected_players
    assert f"icons/{controller_types[2]}.svg" not in main_window.player_svg_paths_for_icons
    assert main_window.ui.connection_list.count() == 0
    assert main_window.ui.num_connected_label.text() == "0/4"
    assert player_ids[2] not in main_window.player_latency
    assert player_ids[2] not in main_window.player_svg_paths_for_icons
    assert player_ids[2] not in main_window.player_checkbox_mapping
    assert player_ids[2] not in main_window.player_controller_input_display
    assert player_ids[2] not in main_window.player_controller_input_display

def test_existing_player_connection(main_window, mocker):
    """
    Function to test whether the update_player_connection function works as intended or not, creating the widgets
    and assigning variables the correct values when a user is disconnecting from the server/application
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        mocker - fixture provided by pytest for testing
    """
    player_id = "player_1"
    json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
    json_str = json.dumps(json_file)

    main_window.update_player_connection("connect", player_id, enums.ControllerType.Xbox, json_str)
    mock_warning = mocker.patch.object(QMessageBox, "exec")
    main_window.update_player_connection("connect", player_id, enums.ControllerType.Xbox, json_str)
    mock_warning.assert_called_once()

def test_non_existing_player_disconnection(main_window, mocker):
    """
    Function to test whether the update_player_connection function works as intended or not when a user
    is disconnecting from the server/application that does not exist (is not connected to the server)
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        mocker - fixture provided by pytest for testing
    """
    player_id = "Not_Existent"
    mock_warning = mocker.patch.object(QMessageBox, "exec")
    main_window.update_player_connection("disconnect", player_id, enums.ControllerType.Xbox, None)
    mock_warning.assert_called_once()

def test_controller_name_label_creation(main_window):
        player_id = "Player1"
        controller_type = "Playstation"
        json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
        json_str = json.dumps(json_file)

        main_window.update_player_connection("connect", player_id, controller_type, json_str)

        # Retrieve the controller widget associated with the player_id
        controller_info = main_window.player_controller_mapping.get(player_id)
        assert controller_info is not None

        controller_widget = controller_info.get("widget")
        assert controller_widget is not None

        # Find the QLabel within the controller_widget
        controller_name_label = controller_info.get("player_label")
        assert controller_name_label is not None
        assert controller_name_label.text() == f"<h2>{player_id}</h2>"

def test_controller_updates(main_window):
    """
    Function to test whether the update_controller_type function works as intended or not. It should
    call get_icon_from_svg using the correct SVG file and color depending on latency and controller type.
    """
    mock_icon = QIcon()

    # Mock methods with patch
    with patch.object(main_window, "get_icon_from_svg", return_value=mock_icon) as mock_get_icon, \
         patch.object(main_window.controller_grid_layout, "removeWidget", return_value=None) as mock_remove_widget, \
         patch.object(main_window.controller_grid_layout, "addWidget", return_value=None) as mock_add_widget:

        # Define test parameters
        json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
        json_str = json.dumps(json_file)
        player_id = "player_1"

        main_window.player_controller_mapping = {
            player_id: {"widget": MagicMock(), "player_label": MagicMock(), "glow_button": MagicMock(), "latency_label": MagicMock(), "display": MagicMock()}
        }

        main_window.player_controller_location_mapping = {player_id: {"row": 0, "column": 1}}
        test_cases = [70, 200, 105, 50]

        controller_types = [enums.ControllerType.Switch, enums.ControllerType.Xbox, enums.ControllerType.Playstation, enums.ControllerType.Wii]

        test_case = 0
        for latency in test_cases:
            main_window.player_latency = {player_id: latency}
            main_window.update_controller_type(player_id, controller_types[test_case], json_str)
            mock_get_icon.assert_called()
            mock_remove_widget.assert_called()
            mock_add_widget.assert_called()
            test_case+=1

def test_toggle_controller_input_display(main_window, qtbot):
    """
    Function to test if clicking the "display controller input" checkboxes properly modify values for
    singular and multiple users 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        qtbot - fixture provided by pytest-qt for GUI testing
    """

    json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
    json_str = json.dumps(json_file)


    main_window.update_player_connection("connect", "player_1", enums.ControllerType.Xbox, json_str)
    player1_checkbox = main_window.player_checkbox_mapping["player_1"]

    # Case where player_1 checkbox is unchecked
    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is False
    
    # Case where player_1 checkbox is rechecked
    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is True

    main_window.update_player_connection("connect", "player_2", enums.ControllerType.Switch, json_str)
    player2_checkbox = main_window.player_checkbox_mapping["player_2"]

    # Case where player_1 checkbox is unchecked
    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is False
    
    # Case where player_2 checkbox is unchecked
    player2_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_2"] is False

def test_toggle_latency(main_window, monkeypatch):
    """
    Function to test toggling the latency_setting_box properly updates the visibility of widgets and calls
    the necessary function with the correct parameters in order to further update the application when the
    checkbox is toggled 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        monkeypatch - fixture provided by pytest for testing
    """
    main_window.get_icon_from_svg = MagicMock()
    main_window.update_latency = MagicMock()

    mock_item = MagicMock(spec=QListWidgetItem)
    monkeypatch.setattr(main_window.ui.connection_list, 'count', lambda: 1)
    monkeypatch.setattr(main_window.ui.connection_list, 'item', lambda idx: mock_item)

    player_id = "player_1"
    main_window.player_controller_mapping = {
        player_id: {"latency_label": MagicMock()},
    }
    main_window.player_svg_paths_for_icons = {
        "player_1": "icons/player1.svg",
    }
    main_window.player_latency = {
        "player_1": 10,
    }

    need_test = True
    if (main_window.ui.latency_setting_box.isChecked()) and (need_test):
        need_test = False
        main_window.ui.latency_setting_box.toggle()
        main_window.get_icon_from_svg.assert_called_once_with("icons/player1.svg", main_window.application_font_color)
    assert main_window.player_controller_mapping[player_id]["latency_label"].isHidden()

    main_window.ui.latency_setting_box.toggle()

    main_window.update_latency.assert_called_once_with("player_1", 10)
    assert main_window.player_controller_mapping[player_id]["latency_label"].isVisible()

    if (main_window.ui.latency_setting_box.isChecked()) and (need_test):
        main_window.ui.latency_setting_box.toggle()
        main_window.get_icon_from_svg.assert_has_calls
        assert main_window.player_controller_mapping[player_id]["latency_label"].isHidden()

def test_no_latency_display_changes(main_window, monkeypatch):
    """
    Function to test if the update_latency function does not update, call, or modify the different
    variables and widgets when the function is used/called by the server and/or application and the display
    checkbox is not clicked 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        monkeypatch - fixture provided by pytest for testing
    """
    main_window.get_icon_from_svg = MagicMock()

    mock_item = MagicMock(spec=QListWidgetItem)
    monkeypatch.setattr(main_window.ui.connection_list, 'count', lambda: 1)
    monkeypatch.setattr(main_window.ui.connection_list, 'item', lambda idx: mock_item)

    player_id = "player_1"
    main_window.player_controller_mapping = {
        player_id: {"latency_label": MagicMock()},
    }
    main_window.player_svg_paths_for_icons = {
        "player_1": "icons/player1.svg",
    }
    main_window.player_latency = {
        "player_1": None,
    }

    if main_window.ui.latency_setting_box.isChecked():
        main_window.ui.latency_setting_box.toggle()      

    main_window.update_latency("player_1", 5)
    assert main_window.player_latency["player_1"] is None
    assert main_window.player_controller_mapping[player_id]["latency_label"].isHidden()
    
def test_latency_display_changes(main_window, monkeypatch):
    """
    Function to test if the update_latency function properly updates, call, and modifies the different
    variables and widgets when the function is used/called by the server and/or application and the display
    checkbox is clicked 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        monkeypatch - fixture provided by pytest for testing
    """
    main_window.get_icon_from_svg = MagicMock()

    mock_items = [MagicMock(spec=QListWidgetItem) for _ in range(2)]
    monkeypatch.setattr(main_window.ui.connection_list, 'count', lambda: len(mock_items))
    monkeypatch.setattr(main_window.ui.connection_list, 'item', lambda index: mock_items[index] if 0 <= index < len(mock_items) else None)

    player_ids = ["player_1", "player_2"]
    main_window.player_controller_mapping = {
        player_ids[0]: {"latency_label": MagicMock()},
        player_ids[1]: {"latency_label": MagicMock()}
    }
    main_window.player_svg_paths_for_icons = {
        "player_1": "icons/player1.svg",
        "player_2": "icons/player2.svg"
    }
    main_window.player_latency = {
        "player_1": 0,
        "player_2": 0
    }

    main_window.player_controller_mapping["player_1"]["latency_label"].text.return_value = ""
    main_window.player_controller_mapping["player_2"]["latency_label"].text.return_value = ""

    # Test a condition for updating latency 
    if not main_window.ui.latency_setting_box.isChecked():
        main_window.ui.latency_setting_box.toggle()
        
    # Case where player_2 exceeds 150ms ("Terrible" range)
    main_window.update_latency("player_2", 200)
    assert main_window.player_latency["player_2"] == 200
    main_window.player_controller_mapping["player_2"]["latency_label"].text.return_value = "200 ms"
    assert main_window.player_controller_mapping["player_2"]["latency_label"].text() == "200 ms"
        
    # Case where player_1 enters "good" range latency <= 50ms
    main_window.update_latency("player_1", 5)
    assert main_window.player_latency["player_1"] == 5
    main_window.player_controller_mapping["player_1"]["latency_label"].text.return_value = "5 ms"
    assert main_window.player_controller_mapping["player_1"]["latency_label"].text() == "5 ms"
    main_window.get_icon_from_svg.assert_called_with("icons/player1.svg", "#3BB20A")

    # Case where player_1 enters "medium" range (50ms < latency <= 100ms)
    main_window.update_latency("player_1", 60)
    assert main_window.player_latency["player_1"] == 60
    main_window.player_controller_mapping["player_1"]["latency_label"].text.return_value = "60 ms"
    assert main_window.player_controller_mapping["player_1"]["latency_label"].text() == "60 ms"
    main_window.get_icon_from_svg.assert_called_with("icons/player1.svg", "#e6cc00")

    # Case where player_2 enters "good" range latency <= 50ms
    main_window.update_latency("player_2", 10)
    assert main_window.player_latency["player_2"] == 10
    main_window.player_controller_mapping["player_2"]["latency_label"].text.return_value = "10 ms"
    assert main_window.player_controller_mapping["player_2"]["latency_label"].text() == "10 ms"
    main_window.get_icon_from_svg.assert_called_with("icons/player2.svg", "#3BB20A")

    # Case where player_1 enters "bad" range latency > 100ms
    main_window.update_latency("player_1", 105)
    assert main_window.player_latency["player_1"] == 105
    main_window.player_controller_mapping["player_1"]["latency_label"].text.return_value = "105 ms"
    assert main_window.player_controller_mapping["player_1"]["latency_label"].text() == "105 ms"
    main_window.get_icon_from_svg.assert_called_with("icons/player1.svg", "#Ff0000")

    # Case where player_1 exceeds 150ms ("Terrible" range)
    main_window.update_latency("player_1", 170)
    main_window.player_controller_mapping["player_1"]["latency_label"].text.return_value = "170 ms"
    assert main_window.player_controller_mapping["player_1"]["latency_label"].text() == "170 ms"
    assert main_window.player_latency["player_1"] == 170

def fake_get_color_valid_1():
    return QColor("#1aa7ea")

def fake_get_color_valid_2():
    return QColor("#1aa7eb")

def fake_get_color_valid_3():
    return QColor("#1aa7ec")

def fake_get_color_invalid():
    return QColor()

@pytest.fixture
def popup(qtbot):
    # Create an instance of ColorPickerPopup with initial colors
    popup = ColorPickerPopup(QColor("#000000"), QColor("#111111"), QColor("#222222"))
    qtbot.addWidget(popup)
    return popup

def test_reset_colors(popup):
    popup.reset_color()

    assert popup.application_color == "#242424"
    assert popup.widget_color == "#474747"
    assert popup.font_color == "#ffffff"

    assert "background-color: #242424;" in popup.styleSheet()
    assert "background-color: #474747;" in popup.styleSheet()
    assert "color: #ffffff;" in popup.styleSheet()

@patch.object(QColorDialog, 'getColor', side_effect=fake_get_color_valid_1)
def test_update_background(mock_get_color, popup, qtbot):
    qtbot.mouseClick(popup.background_button, Qt.LeftButton)
    assert "#1aa7ea" in popup.styleSheet()

@patch.object(QColorDialog, 'getColor', side_effect=fake_get_color_valid_2)
def test_update_widget(mock_get_color, popup, qtbot):
    qtbot.mouseClick(popup.widget_button, Qt.LeftButton)
    assert "#1aa7eb" in popup.styleSheet()

@patch.object(QColorDialog, 'getColor', side_effect=fake_get_color_valid_3)
def test_update_font(mock_get_color, popup, qtbot):
    qtbot.mouseClick(popup.font_button, Qt.LeftButton)
    assert "#1aa7ec" in popup.styleSheet()

@patch.object(QColorDialog, 'getColor', side_effect=fake_get_color_invalid)
def test_invalid_color_background(mock_get_color, popup, qtbot, mocker):
    mock_warning = mocker.patch.object(QMessageBox, "exec")
    qtbot.mouseClick(popup.background_button, Qt.LeftButton)
    mock_warning.assert_called_once()

@patch.object(QColorDialog, 'getColor', side_effect=fake_get_color_invalid)
def test_invalid_color_widget(mock_get_color, popup, qtbot, mocker):
    mock_warning = mocker.patch.object(QMessageBox, "exec")
    qtbot.mouseClick(popup.widget_button, Qt.LeftButton)
    mock_warning.assert_called_once()

@patch.object(QColorDialog, 'getColor', side_effect=fake_get_color_invalid)
def test_invalid_color_font(mock_get_color, popup, qtbot, mocker):
    mock_warning = mocker.patch.object(QMessageBox, "exec")
    qtbot.mouseClick(popup.font_button, Qt.LeftButton)
    mock_warning.assert_called_once()

def test_return_values(popup):
    captured_colors = []

    def color_handler(app_color, widget_color, font_color):
        captured_colors.extend([app_color, widget_color, font_color])

    popup.color_updated.connect(color_handler)
    popup.confirm_color()

    assert len(captured_colors) == 3

    assert captured_colors[0] == popup.application_color
    assert captured_colors[1] == popup.widget_color
    assert captured_colors[2] == popup.font_color

    assert popup.result() == QDialog.Accepted

    try:
        popup.color_updated.disconnect(color_handler)
    except TypeError:
        pass

def test_apply_background(main_window, qtbot):
    background_color = "#1aa7ec"
    widget_color = "#dadedf"
    font_color = "#0f0f0f"

    # Call the method with string values
    main_window.update_application_color(background_color, widget_color, font_color)
    
    # Verify that the attributes are QColors and their values match the input strings
    assert isinstance(main_window.application_background_color, QColor)
    assert main_window.application_background_color.name() == background_color

    assert isinstance(main_window.application_widgets_color, QColor)
    assert main_window.application_widgets_color.name() == widget_color

    assert isinstance(main_window.application_font_color, QColor)
    assert main_window.application_font_color.name() == font_color

    assert f"background-color: {background_color};" in main_window.styleSheet()
    assert f"color: {font_color};" in main_window.styleSheet()

    darker_widget_color = QColor(widget_color).darker(140).name()
    darkest_widget_color = QColor(widget_color).darker(180).name()
    lighter_widget_color = QColor(widget_color).lighter(140).name()

    assert f"background-color: {darker_widget_color};" in main_window.ui.connection_list_area.styleSheet()
    assert f"color: {font_color};" in main_window.ui.connection_list_area.styleSheet()

    assert f"background-color: {widget_color};" in main_window.ui.connection_list.styleSheet()
    assert f"color: {font_color};" in main_window.ui.connection_list.styleSheet()

    settings_darker_color = main_window.application_widgets_color.darker(110).name()
    settings_lighter_color = main_window.application_widgets_color.lighter(120).name()
    settings_hover_color = main_window.application_widgets_color.lighter(140).name()
    settings_pressed_color = main_window.application_widgets_color.darker(130).name()
    
    assert f"QTabWidget {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {widget_color};" in main_window.ui.settings_selection.styleSheet()
    assert f"color: {font_color};" in main_window.ui.settings_selection.styleSheet()
    
    assert f"QTabWidget::pane {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {widget_color};" in main_window.ui.settings_selection.styleSheet()
    
    assert f"QTabBar {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {widget_color};" in main_window.ui.settings_selection.styleSheet()
    assert f"color: {font_color};" in main_window.ui.settings_selection.styleSheet()
    
    assert f"QTabBar::tab {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {settings_darker_color};" in main_window.ui.settings_selection.styleSheet()
    
    assert f"QTabBar::tab:selected {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {settings_lighter_color};" in main_window.ui.settings_selection.styleSheet()
    assert f"font-weight: bold;" in main_window.ui.settings_selection.styleSheet()
    
    assert f"QTabBar::tab:hover {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {settings_hover_color};" in main_window.ui.settings_selection.styleSheet()
    
    assert f"QTabBar::tab:pressed {{" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {settings_pressed_color};" in main_window.ui.settings_selection.styleSheet()
    
    assert "QWidget {" in main_window.ui.settings_selection.styleSheet()
    assert f"background-color: {widget_color};" in main_window.ui.settings_selection.styleSheet()    

    assert f"background-color: {darker_widget_color};" in main_window.ui.controller_checkboxes.styleSheet()
    assert f"color: {font_color};" in main_window.ui.controller_checkboxes.styleSheet()

    assert f"background-color: {darker_widget_color};" in main_window.ui.bluetooth_button.styleSheet()

    assert f"QPushButton:hover {{" in main_window.ui.bluetooth_button.styleSheet()
    assert f"background-color: {lighter_widget_color};" in main_window.ui.bluetooth_button.styleSheet()

    assert f"QPushButton:pressed {{" in main_window.ui.bluetooth_button.styleSheet()
    assert f"background-color: {darkest_widget_color};" in main_window.ui.bluetooth_button.styleSheet()     

    assert f"background-color: {darker_widget_color};" in main_window.ui.network_button.styleSheet()

    assert f"QPushButton:hover {{" in main_window.ui.network_button.styleSheet()
    assert f"background-color: {lighter_widget_color};" in main_window.ui.network_button.styleSheet()

    assert f"QPushButton:pressed {{" in main_window.ui.network_button.styleSheet()
    assert f"background-color: {darkest_widget_color};" in main_window.ui.network_button.styleSheet()  
    
    assert f"background-color: {darker_widget_color};" in main_window.ui.server_close_button.styleSheet()

    assert f"QPushButton:hover {{" in main_window.ui.server_close_button.styleSheet()
    assert f"background-color: {lighter_widget_color};" in main_window.ui.server_close_button.styleSheet()

    assert f"QPushButton:pressed {{" in main_window.ui.server_close_button.styleSheet()
    assert f"background-color: {darkest_widget_color};" in main_window.ui.server_close_button.styleSheet()
    
    assert f"background-color: {widget_color};" in main_window.ui.connection_code_box.styleSheet()
    assert f"color: {font_color};" in main_window.ui.connection_code_box.styleSheet()   
    
    assert f"background-color: {widget_color};" in main_window.ui.controller_mockup_area.styleSheet()
    assert f"color: {font_color};" in main_window.ui.controller_mockup_area.styleSheet() 
    
    assert f"QPushButton {{" in main_window.ui.customizer_button.styleSheet()
    assert "background-color: transparent;" in main_window.ui.customizer_button.styleSheet()
    assert "border: none;" in main_window.ui.customizer_button.styleSheet() 

    assert f"QPushButton:hover {{" in main_window.ui.customizer_button.styleSheet()
    assert f"background-color: {lighter_widget_color};" in main_window.ui.customizer_button.styleSheet()

    assert f"QPushButton:pressed {{" in main_window.ui.customizer_button.styleSheet()
    assert f"background-color: {darker_widget_color};" in main_window.ui.customizer_button.styleSheet()

    assert "QPushButton { background-color: transparent; border: none; }" in main_window.ui.view_code_button.styleSheet() 

def test_controller_widget_creation():
    json_file = {'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]}
    json_str = json.dumps(json_file)
    application_widgets_color = "#FFFFFF"
    new_controller_display = ControllerWidget(json_str, application_widgets_color)
    assert isinstance(new_controller_display, ControllerWidget)

def test_display_controller_input(main_window):
    """Test if display_controller_input correctly calls set_active_input."""
    
    # Mock the ControllerWidget inside the mapping
    mock_display = MagicMock()
    
    # Setup test data
    player_id = "player_1"
    test_input = 0
    hold_input = enums.ButtonEvent.PRESSED
    
    # Assign a mocked controller display to the player in the mapping
    main_window.player_controller_mapping = {
        player_id: {
            "display": mock_display
        }
    }
    
    # Ensure the player exists in the input display tracking
    main_window.player_controller_input_display = {player_id: True}
    
    main_window.display_controller_input(player_id, test_input, hold_input)
    
    # Verify that set_active_input was called on the correct object with correct arguments
    mock_display.set_active_input.assert_called_once_with(test_input, hold_input)

def test_display_controller_input_multiple_players(main_window):
    """Test if display_controller_input updates only the correct player's input when multiple players are connected."""
    mock_display_1 = MagicMock()
    mock_display_2 = MagicMock()
    
    player_1 = "player_1"
    player_2 = "player_2"
    test_input_1 = 0
    test_input_2 = 1
    hold_input = enums.ButtonEvent.PRESSED
    
    # Assign mocked controller displays to players
    main_window.player_controller_mapping = {
        player_1: {"display": mock_display_1},
        player_2: {"display": mock_display_2},
    }
    
    # Ensure both players exist in the input display tracking
    main_window.player_controller_input_display = {
        player_1: True,
        player_2: True,
    }
    
    main_window.display_controller_input(player_1, test_input_1, hold_input)

    # Verify that set_active_input was called only on player_1's display
    mock_display_1.set_active_input.assert_called_once_with(test_input_1, hold_input)
    mock_display_2.set_active_input.assert_not_called()
    
    mock_display_1.reset_mock()
    mock_display_2.reset_mock()

    main_window.display_controller_input(player_2, test_input_2, hold_input)

    # Verify that set_active_input was called only on player_2's display
    mock_display_1.set_active_input.assert_not_called()
    mock_display_2.set_active_input.assert_called_once_with(test_input_2, hold_input)

def test_display_controller_input_failure(main_window):
    mock_display = MagicMock()
    
    # Setup test data
    player_id = "player_1"
    test_input = 0
    hold_input = enums.ButtonEvent.PRESSED
    
    # Assign a mocked controller display to the player in the mapping
    main_window.player_controller_mapping = {
        player_id: {
            "display": mock_display
        }
    }

    main_window.player_controller_input_display = {}
    main_window.display_controller_input(player_id, test_input, hold_input)
    mock_display.set_active_input.assert_not_called()

class TestControllerWidget(unittest.TestCase):
    def setUp(self):
        controller_config = json.dumps({'name': 'Xbox', 'wrappedButtons': [{'payload': {'turbo': False,'scale': 1,'type': 0,'rotation': 0,'inputId': 0,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'Y'}, 'input': 'Y','position': {'scaledPos': [0.8, 0.6],'offset': [0, -50]}}, 'base': 2},{'payload': {'inputId': 1,'input': 'X','scale': 1,'style': {'iconType': {'Text': {}},'shape': {'Circle': {}},'icon': 'X'},'turbo': False,'type': 0, 'position': {'scaledPos': [0.8, 0.6],'offset': [-50, 0]}, 'rotation': 0}, 'base': 2},{'payload': {'input': 'B','inputId': 2,'rotation': 0,'style': {'icon': 'B','shape': {'Circle': {}},'iconType': {'Text': {}}}, 'position': {'offset': [50, 0],'scaledPos': [0.8, 0.6]}, 'scale': 1, 'type': 0, 'turbo': False}, 'base': 2}, {'base': 2, 'payload': {'inputId': 3, 'type': 0, 'scale': 1, 'rotation': 0, 'style': {'icon': 'A', 'shape': {'Circle': {}}, 'iconType': {'Text': {}}}, 'input': 'A', 'turbo': False, 'position': {'scaledPos': [0.8, 0.6], 'offset': [0, 50]}}}, {'base': 1, 'payload': {'sensitivity': 0, 'type': 1, 'input': 'RightJoystick', 'scale': 1.5, 'deadzone': 0, 'inputId': 4, 'rotation': 0, 'position': {'scaledPos': [0.6, 0.8], 'offset': [0, 0]}}}, {'base': 0, 'payload': {'inputs': [2, 'DPadLeft', 3, 'DPadRight', 1, 'DPadDown', 0, 'DPadUp'], 'scale': 1.5, 'position': {'scaledPos': [0.4, 0.8], 'offset': [0, 0]}, 'type': 2, 'inputId': 5, 'rotation': 0}}, {'payload': {'deadzone': 0, 'position': {'offset': [0, 0], 'scaledPos': [0.2, 0.6]}, 'rotation': 0, 'sensitivity': 0, 'type': 1, 'inputId': 6, 'input': 'LeftJoystick', 'scale': 1.5}, 'base': 1}, {'base': 2, 'payload': {'type': 0, 'style': {'shape': {'Circle': {}}, 'iconType': {'SFSymbol': {}}, 'icon': 'line.3.horizontal'}, 'inputId': 7, 'position': {'scaledPos': [0.5, 0.2], 'offset': [-30, 0]}, 'scale': 0.6, 'input': 'Menu', 'rotation': 0, 'turbo': False}}, {'base': 2, 'payload': {'position': {'offset': [30, 0], 'scaledPos': [0.5, 0.2]}, 'turbo': False, 'inputId': 8, 'style': {'shape': {'Circle': {}}, 'icon': 'macwindow.on.rectangle', 'iconType': {'SFSymbol': {}}}, 'input': 'Window', 'scale': 0.6, 'type': 0, 'rotation': 0}}, {'base': 2,'payload': {'type': 0, 'input': 'Share', 'inputId': 9, 'style': {'shape': {'Circle': {}}, 'icon': 'square.and.arrow.up','iconType': {'SFSymbol': {}}}, 'rotation': 0, 'turbo': False, 'position': {'offset': [0, 30], 'scaledPos': [0.5, 0.2]}, 'scale': 0.6}}, {'payload': {'type': 3, 'inputId': 10, 'position': {'scaledPos': [0.1, 0.1], 'offset': [25, 75]}, 'scale': 1.5, 'rotation': 0, 'input': 'LB', 'style': {'iconType': {'Text': {}}, 'icon': 'LB', 'shape': {'Pill': {}}}, 'turbo': False}, 'base': 3}, {'payload': {'input': 'RB', 'turbo': False, 'rotation': 0, 'inputId': 11, 'scale': 1.5, 'style': {'shape': {'Pill': {}}, 'iconType': {'Text': {}}, 'icon': 'RB'}, 'position': {'scaledPos': [0.9, 0.1], 'offset': [-25, 75]}, 'type': 3}, 'base': 3}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.1, 0.1]}, 'rotation': 0, 'turbo': False, 'scale': 1.5, 'input': 'LT', 'side': 1, 'inputId': 12, 'type': 4}}, {'base': 4, 'payload': {'position': {'offset': [0, 0], 'scaledPos': [0.9, 0.1]}, 'input': 'RT', 'turbo': False, 'inputId': 13, 'scale': 1.5, 'rotation': 0, 'type': 4, 'side': 0}}]})
        controller_config_2 = json.dumps({
            'wrappedButtons': [
                {
                    'base': 2, 
                    'payload': {
                        'rotation': 0, 
                        'scale': 1, 
                        'type': 0, 
                        'position': {
                            'scaledPos': [0.8, 0.6], 
                            'offset': [0, -50]
                        }, 
                        'turbo': False, 
                        'input': 'X', 
                        'inputId': 0, 
                        'style': {
                            'shape': {
                                'Circle': {}
                            }, 
                            'iconType': {
                                'Text': {}
                            },
                            'icon': 'X'
                        }
                    }
                }, 
                {
                    'base': 2, 
                    'payload': {
                        'rotation': 0, 
                        'input': 'Y', 
                        'position': {
                            'scaledPos': [0.8, 0.6], 
                            'offset': [-50, 0]
                        }, 
                        'type': 0, 
                        'scale': 1, 
                        'turbo': False, 
                        'inputId': 1, 
                        'style': {
                            'shape': {
                                'Circle': {}
                            }, 
                            'iconType': {
                                'Text': {}
                            }, 
                            'icon': 'Y'
                        }
                    }
                }, 
                {
                    'base': 2, 
                    'payload': {
                        'style': {
                            'iconType': {
                                'Text': {}
                            }, 
                            'icon': 'A', 
                            'shape': {
                                'Circle': {}
                            }
                        }, 
                        'inputId': 2, 
                        'turbo': False, 
                        'type': 0, 
                        'input': 'A', 
                        'rotation': 0, 
                        'position': {
                            'scaledPos': [0.8, 0.6], 
                            'offset': [50, 0]
                        }, 
                        'scale': 1
                    }
                }, 
                {
                    'payload': {
                        'input': 'B', 
                        'turbo': False, 
                        'inputId': 3, 
                        'type': 0, 
                        'scale': 1, 
                        'style': {
                            'icon': 'B', 
                            'iconType': {
                                'Text': {}
                            }, 
                            'shape': {
                                'Circle': {}
                            }
                        }, 
                        'rotation': 0, 
                        'position': {
                            'offset': [0, 50], 
                            'scaledPos': [0.8, 0.6]
                        }
                    }, 
                    'base': 2
                }, 
                {
                    'base': 1, 
                    'payload': {
                        'deadzone': 0, 
                        'rotation': 0, 
                        'type': 1, 
                        'inputId': 4, 
                        'input': 'RightJoystick', 
                        'position': {
                            'scaledPos': [0.6, 0.7], 
                            'offset': [0, 0]
                        }, 
                        'sensitivity': 0, 
                        'scale': 1.5
                    }
                }, 
                {
                    'base': 0, 
                    'payload': {
                        'type': 2, 
                        'inputs': [
                            1, 'DPadDown', 
                            2, 'DPadLeft', 
                            0, 'DPadUp', 
                            3, 'DPadRight'
                        ], 
                        'rotation': 0, 
                        'inputId': 5, 
                        'position': {
                            'scaledPos': [0.4, 0.8], 
                            'offset': [0, 0]
                        }, 
                        'scale': 1.5
                    }
                }, 
                {
                    'base': 1, 
                    'payload': {
                        'sensitivity': 0, 
                        'position': {
                            'scaledPos': [0.2, 0.6], 
                            'offset': [0, 0]
                        }, 
                        'deadzone': 0, 
                        'input': 'LeftJoystick', 
                        'rotation': 0, 
                        'type': 1, 
                        'scale': 1.5, 
                        'inputId': 6
                    }
                }, 
                {
                    'payload': {
                        'type': 0, 
                        'style': {
                            'shape': {
                                'Circle': {}
                            }, 
                            'iconType': {
                                'SFSymbol': {}
                            }, 
                            'icon': 'plus'
                        }, 
                        'rotation': 0, 
                        'position': {
                            'offset': [-60, -15], 
                            'scaledPos': [0.5, 0.2]
                        }, 
                        'turbo': False, 
                        'input': 'Start', 
                        'scale': 0.6, 
                        'inputId': 7
                    }, 
                    'base': 2
                }, 
                {
                    'payload': {
                        'input': 'Select', 
                        'type': 0, 
                        'inputId': 8, 
                        'scale': 0.6, 
                        'turbo': False, 
                        'style': {
                            'shape': {
                                'Circle': {}
                            }, 
                            'icon': '-', 
                            'iconType': {
                                'Text': {}
                            }
                        }, 
                        'rotation': 0, 
                        'position': {
                            'offset': [60, -15], 
                            'scaledPos': [0.5, 0.2]
                        }
                    }, 
                    'base': 2
                }, 
                {
                    'base': 2, 
                    'payload': {
                        'position': {
                            'scaledPos': [0.5, 0.2], 
                            'offset': [-30, 30]
                        }, 
                        'scale': 0.6, 
                        'type': 0, 
                        'input': 'Home', 
                        'rotation': 0, 
                        'style': {
                            'icon': 'house', 
                            'iconType': {
                                'SFSymbol': {}
                            }, 
                            'shape': {
                                'Circle': {}
                            }
                        }, 
                        'inputId': 9, 
                        'turbo': False
                    }
                }, 
                {
                    'payload': {
                        'input': 'Screenshot', 
                        'position': {
                            'offset': [30, 30], 
                            'scaledPos': [0.5, 0.2]
                        }, 
                        'type': 0, 
                        'style': {
                            'iconType': {
                                'SFSymbol': {}
                            }, 
                            'shape': {
                                'Circle': {}
                            }, 
                            'icon': 'square'
                        }, 
                        'turbo': False, 
                        'inputId': 10, 
                        'scale': 0.6, 
                        'rotation': 0
                    }, 
                    'base': 2
                }, 
                {
                    'payload': {
                        'type': 3, 
                        'rotation': 0, 
                        'turbo': False, 
                        'scale': 1.5, 
                        'style': {
                            'icon': 'LB', 
                            'iconType': {
                                'Text': {}
                            }, 
                            'shape': {
                                'Pill': {}
                            }
                        }, 
                        'inputId': 10, 
                        'input': 'LB', 
                        'position': {
                            'offset': [25, 75], 
                            'scaledPos': [0.1, 0.1]
                        }
                    }, 
                    'base': 3
                }, 
                {
                    'base': 3, 
                    'payload': {
                        'rotation': 0, 
                        'type': 3, 
                        'scale': 1.5, 
                        'inputId': 11, 
                        'position': {
                            'scaledPos': [0.9, 0.1], 
                            'offset': [-25, 75]
                        }, 
                        'style': {
                            'iconType': {
                                'Text': {}
                            }, 
                            'icon': 'RB', 
                            'shape': {
                                'Pill': {}
                            }
                        }, 
                        'input': 'RB', 
                        'turbo': False
                    }
                }, 
                {
                    'base': 4, 
                    'payload': {
                        'input': 'LT', 
                        'side': 1, 
                        'type': 4, 
                        'position': {
                            'offset': [0, 0], 
                            'scaledPos': [0.1, 0.1]
                        }, 
                        'scale': 1.5, 
                        'inputId': 12, 
                        'rotation': 0, 
                        'turbo': False
                    }
                }, 
                {
                    'base': 4, 
                    'payload': {
                        'rotation': 0, 
                        'type': 4, 
                        'input': 'RT', 
                        'scale': 1.5, 
                        'inputId': 13, 
                        'position': {
                            'offset': [0, 0], 
                            'scaledPos': [0.9, 0.1]
                        }, 
                        'turbo': False, 
                        'side': 0
                    }
                }
            ],
            'name': 'Switch'
        })
        controller_config_3 = json.dumps({
            'wrappedButtons': [
                {
                    'base': 2, 
                    'payload': {
                        'rotation': 0, 
                        'scale': 1, 
                        'type': 0, 
                        'position': {
                            'scaledPos': [0.8, 0.6], 
                            'offset': [0, -50]
                        }, 
                        'turbo': False, 
                        'input': 'X', 
                        'inputId': 0, 
                        'style': {
                            'shape': {
                                'Circle': {}
                            }, 
                            'iconType': {
                                'Text': {}
                            },
                            'icon': 'X'
                        }
                    }
                }, 
                {
                    'base': 1, 
                    'payload': {
                        'deadzone': 0, 
                        'rotation': 0, 
                        'type': 1, 
                        'inputId': 4, 
                        'input': 'RightJoystick', 
                        'position': {
                            'scaledPos': [0.6, 0.7], 
                            'offset': [0, 0]
                        }, 
                        'sensitivity': 0, 
                        'scale': 1.5
                    }
                },
                {
                    'base': 1, 
                    'payload': {
                        'sensitivity': 0, 
                        'position': {
                            'scaledPos': [0.2, 0.6], 
                            'offset': [0, 0]
                        }, 
                        'deadzone': 0, 
                        'input': 'LeftJoystick', 
                        'rotation': 0, 
                        'type': 1, 
                        'scale': 1.5, 
                        'inputId': 6
                    }
                }
            ],
            'name': 'Switch'
        })
        self.widget = ControllerWidget(controller_config, "#FF0000")
        self.widget_2 = ControllerWidget(controller_config_2, "#ABCDEF")
        self.widget_3 = ControllerWidget(controller_config_3, "#123456")

    def test_initialization(self):
        self.assertEqual(self.widget.color_scheme, "#FF0000")
        self.assertIsInstance(self.widget.glow_color, QColor)
        self.assertEqual(len(self.widget.controller_widgets), 14)

        self.assertEqual(self.widget_2.color_scheme, "#ABCDEF")
        self.assertIsInstance(self.widget_2.glow_color, QColor)
        self.assertEqual(len(self.widget_2.controller_widgets), 15)

        self.assertEqual(self.widget_3.color_scheme, "#123456")
        self.assertIsInstance(self.widget_3.glow_color, QColor)
        self.assertEqual(len(self.widget_3.controller_widgets), 3)

    def test_widget_resizing(self):
        """Ensure resizing updates the cache."""
        self.widget.resize(800, 600)
        self.assertEqual(self.widget.width(), 800)
        self.assertEqual(self.widget.height(), 600)

        self.widget.resize(500, 300)
        self.assertEqual(self.widget.width(), 500)
        self.assertEqual(self.widget.height(), 300)

        self.widget.resize(300, 100)
        self.assertEqual(self.widget.width(), 300)
        self.assertEqual(self.widget.height(), 100)

    def test_update_widget_color(self):
        """Ensure color updates properly."""
        self.widget.update_widget_color("#00FF00")
        self.assertEqual(self.widget.color_scheme, "#00FF00")

        self.widget_2.update_widget_color("#FEDCBA")
        self.assertEqual(self.widget_2.color_scheme, "#FEDCBA")

        self.widget_3.update_widget_color("#654321")
        self.assertEqual(self.widget_3.color_scheme, "#654321")

    def test_set_active_input_on_pressed(self):
        """Ensure button press is registered correctly."""
        self.widget.set_active_input(0, enums.ButtonEvent.PRESSED)
        self.assertEqual(self.widget.input_held.get(0), enums.ButtonEvent.PRESSED)

        self.widget_2.set_active_input(13, enums.ButtonEvent.PRESSED)
        self.assertEqual(self.widget_2.input_held.get(13), enums.ButtonEvent.PRESSED)

        self.widget_3.set_active_input(4, enums.ButtonEvent.PRESSED)
        self.assertEqual(self.widget_3.input_held.get(4), enums.ButtonEvent.PRESSED)

    def test_clear_active_input(self):
        """Ensure button release is registered correctly."""
        self.widget.set_active_input(0, enums.ButtonEvent.PRESSED)
        self.widget.clear_active_input(0, enums.ButtonEvent.RELEASED)
        self.assertEqual(self.widget.input_held.get(0), enums.ButtonEvent.RELEASED)

        self.widget_2.set_active_input(0, enums.ButtonEvent.PRESSED)
        self.widget_2.clear_active_input(0, enums.ButtonEvent.RELEASED)
        self.assertEqual(self.widget_2.input_held.get(0), enums.ButtonEvent.RELEASED)

        self.widget_3.set_active_input(6, enums.ButtonEvent.PRESSED)
        self.widget_3.clear_active_input(6, enums.ButtonEvent.RELEASED)
        self.assertEqual(self.widget_3.input_held.get(6), enums.ButtonEvent.RELEASED)

class TestGridLayoutRefresh(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up QApplication once for all tests."""
        if QApplication.instance() is None:
            cls.app = QApplication(sys.argv)
        else:
            cls.app = QApplication.instance()

    def setUp(self):
        """Create a dummy UI layout with mock data."""
        self.window = QWidget()
        self.controller_grid_layout = QGridLayout()
        self.window.setLayout(self.controller_grid_layout)

        self.player_controller_mapping = {
            "player1": {"widget": QPushButton("Player 1")},
            "player2": {"widget": QPushButton("Player 2")},
            "player3": {"widget": QPushButton("Player 3")},
        }

        self.player_controller_location_mapping = {
            "player1": {"row": 0, "column": 0},
            "player2": {"row": 1, "column": 0},
            "player3": {"row": 1, "column": 1},
        }

        for player, data in self.player_controller_mapping.items():
            row, col = self.player_controller_location_mapping[player]["row"], self.player_controller_location_mapping[player]["column"]
            self.controller_grid_layout.addWidget(data["widget"], row, col)
            self.assertIsNotNone(self.controller_grid_layout.itemAtPosition(row, col))

    def refresh_grid_layout(self, player_id):
        """Implementation of refresh_grid_layout for testing."""
        row = self.player_controller_location_mapping[player_id]["row"]
        column = self.player_controller_location_mapping[player_id]["column"]
        controller_to_remove = self.controller_grid_layout.itemAtPosition(row, column)

        if controller_to_remove:
            controller_widget = controller_to_remove.widget()
            if controller_widget:
                self.controller_grid_layout.removeWidget(controller_widget)
                controller_widget.setParent(None)

        del self.player_controller_mapping[player_id]
        del self.player_controller_location_mapping[player_id]

        for player in list(self.player_controller_mapping.keys()):
            player_row = self.player_controller_location_mapping[player]["row"]
            player_column = self.player_controller_location_mapping[player]["column"]

            if player_row == row and player_column > column:
                self.controller_grid_layout.removeWidget(self.player_controller_mapping[player]["widget"])
                self.controller_grid_layout.addWidget(self.player_controller_mapping[player]["widget"], player_row, player_column - 1)
                self.player_controller_location_mapping[player]["column"] -= 1

            elif player_row > row:
                self.controller_grid_layout.removeWidget(self.player_controller_mapping[player]["widget"])
                self.controller_grid_layout.addWidget(self.player_controller_mapping[player]["widget"], player_row - 1, player_column)
                self.player_controller_location_mapping[player]["row"] -= 1

    def test_refresh_grid_layout_removes_widget(self):
        """Ensure that refresh_grid_layout removes the specified widget."""
        self.refresh_grid_layout("player1")
        self.assertIsNotNone(self.controller_grid_layout.itemAtPosition(0, 0))
        self.assertIsNotNone(self.controller_grid_layout.itemAtPosition(0, 1))
        self.assertIsNone(self.controller_grid_layout.itemAtPosition(1, 0))

