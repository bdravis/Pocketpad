import pytest
import enums
from unittest.mock import MagicMock, patch
from PySide6.QtWidgets import QMessageBox, QListWidgetItem, QColorDialog, QDialog
from PySide6.QtGui import QIcon, QCloseEvent, QColor
from PySide6.QtCore import Qt, QSettings
from server_app import MainWindow
from server_app import ColorPickerPopup

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

# NEEDS TO BE REVISED WHEN BLUETOOTH SERVER SHUTDOWN IS PROPERLY FIXED
# def test_bluetooth_button_click(main_window, qtbot):
#     """
#     Function to test if clicking the Bluetooth button properly initiates the Bluetooth server
    
#     @param:
#         main_window - a testing instance of the MainWindow used to display the PocketPad application
#         qtbot - fixture provided pytest-qt for GUI testing
#     """
#     qtbot.mouseClick(main_window.ui.bluetooth_button, Qt.LeftButton)
#     qtbot.wait(100)
#     assert main_window.bluetooth_server_initiated is True
#     assert main_window.network_server_initiated is False

# # NEEDS TO BE REVISED WHEN NETWORK SERVER GETS IMPLEMENTED
# def test_network_button_click(main_window, qtbot):
#     """
#     Function to test if clicking the Network button properly initiates the Network server
    
#     @param:
#         main_window - a testing instance of the MainWindow used to display the PocketPad application
#         qtbot - fixture provided by pytest-qt for GUI testing
#     """
#     qtbot.mouseClick(main_window.ui.network_button, Qt.LeftButton)
#     qtbot.wait(100)
#     assert main_window.network_server_initiated is True
#     assert main_window.bluetooth_server_initiated is False

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

    main_window.get_icon_from_svg = MagicMock(return_value=QIcon())

    main_window.update_player_connection("connect", player_ids[0], controller_types[0])

    assert player_ids[0] in main_window.connected_players
    assert f"icons/switch.svg" in main_window.player_svg_paths_for_icons[player_ids[0]]
    assert main_window.ui.connection_list.count() == 1
    assert main_window.ui.num_connected_label.text() == "1/4"
    assert main_window.player_latency[player_ids[0]] == 0
    assert main_window.player_svg_paths_for_icons[player_ids[0]] == "icons/switch.svg"
    if main_window.ui.latency_setting_box.isChecked():
        main_window.get_icon_from_svg.assert_called_with("icons/switch.svg", "#3BB20A")
    else:
        main_window.get_icon_from_svg.assert_called_with("icons/switch.svg", main_window.application_font_color)
    assert player_ids[0] in main_window.player_checkbox_mapping
    assert player_ids[0] in main_window.player_controller_input_display
    assert main_window.player_controller_input_display[player_ids[0]] is True

    main_window.update_player_connection("connect", player_ids[1], controller_types[1])

    assert player_ids[1] in main_window.connected_players
    assert f"icons/xbox.svg" in main_window.player_svg_paths_for_icons[player_ids[1]]
    assert main_window.ui.connection_list.count() == 2
    assert main_window.ui.num_connected_label.text() == "2/4"
    assert main_window.player_latency[player_ids[1]] == 0
    assert main_window.player_svg_paths_for_icons[player_ids[1]] == "icons/xbox.svg"
    if main_window.ui.latency_setting_box.isChecked():
        main_window.get_icon_from_svg.assert_called_with("icons/xbox.svg", "#3BB20A")
    else:
        main_window.get_icon_from_svg.assert_called_with("icons/xbox.svg", main_window.application_font_color)
    assert player_ids[1] in main_window.player_checkbox_mapping
    assert player_ids[1] in main_window.player_controller_input_display
    assert main_window.player_controller_input_display[player_ids[1]] is True

    main_window.update_player_connection("connect", player_ids[2], controller_types[2])

    assert player_ids[2] in main_window.connected_players
    assert f"icons/playstation.svg" in main_window.player_svg_paths_for_icons[player_ids[2]]
    assert main_window.ui.connection_list.count() == 3
    assert main_window.ui.num_connected_label.text() == "3/4"
    assert main_window.player_latency[player_ids[2]] == 0
    assert main_window.player_svg_paths_for_icons[player_ids[2]] == "icons/playstation.svg"
    if main_window.ui.latency_setting_box.isChecked():
        main_window.get_icon_from_svg.assert_called_with("icons/playstation.svg", "#3BB20A")
    else:
        main_window.get_icon_from_svg.assert_called_with("icons/playstation.svg", main_window.application_font_color)
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

    main_window.get_icon_from_svg = MagicMock(return_value=QIcon())

    main_window.update_player_connection("connect", player_ids[0], controller_types[0])
    main_window.update_player_connection("connect", player_ids[1], controller_types[1])
    main_window.update_player_connection("connect", player_ids[2], controller_types[2])

    main_window.update_player_connection("disconnect", player_ids[0], controller_types[0])

    assert player_ids[0] not in main_window.connected_players
    assert f"icons/{controller_types[0]}.svg" not in main_window.player_svg_paths_for_icons
    assert main_window.ui.connection_list.count() == 2
    assert main_window.ui.num_connected_label.text() == "2/4"
    assert player_ids[0] not in main_window.player_latency
    assert player_ids[0] not in main_window.player_svg_paths_for_icons
    assert player_ids[0] not in main_window.player_checkbox_mapping
    assert player_ids[0] not in main_window.player_controller_input_display
    assert player_ids[0] not in main_window.player_controller_input_display

    main_window.update_player_connection("disconnect", player_ids[1], controller_types[1])

    assert player_ids[1] not in main_window.connected_players
    assert f"icons/{controller_types[1]}.svg" not in main_window.player_svg_paths_for_icons
    assert main_window.ui.connection_list.count() == 1
    assert main_window.ui.num_connected_label.text() == "1/4"
    assert player_ids[1] not in main_window.player_latency
    assert player_ids[1] not in main_window.player_svg_paths_for_icons
    assert player_ids[1] not in main_window.player_checkbox_mapping
    assert player_ids[1] not in main_window.player_controller_input_display
    assert player_ids[1] not in main_window.player_controller_input_display

    main_window.update_player_connection("disconnect", player_ids[2], controller_types[2])

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
    main_window.update_player_connection("connect", player_id, enums.ControllerType.Xbox)
    mock_warning = mocker.patch.object(QMessageBox, "exec")
    main_window.update_player_connection("connect", player_id, enums.ControllerType.Xbox)
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
    main_window.update_player_connection("disconnect", player_id, enums.ControllerType.Xbox)
    mock_warning.assert_called_once()

def test_controller_updates(main_window, monkeypatch):
    """
    Function to test whether the update_controller_type function works as intended or not. Upon calling the function
    it should create a new icon using the get_icon_from_svg using the correct coloring and svg file depending on
    the call to the function and the users latency to determine it 
    
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

    main_window.player_latency = {
        "player_1": 200,
    }
    main_window.update_controller_type("player_1", enums.ControllerType.Xbox)
    main_window.get_icon_from_svg.assert_not_called() 

    main_window.player_latency = {
        "player_1": 10,
    }
    main_window.update_controller_type("player_1", enums.ControllerType.Xbox)
    main_window.get_icon_from_svg.assert_called_with("icons/xbox.svg", "#3BB20A") 
    
    main_window.player_latency = {
        "player_1": 105,
    }
    main_window.update_controller_type("player_1", enums.ControllerType.Playstation)
    main_window.get_icon_from_svg.assert_called_with("icons/playstation.svg", "#Ff0000") 
    
    main_window.player_latency = {
        "player_1": 70,
    }
    main_window.update_controller_type("player_1", enums.ControllerType.Switch)
    main_window.get_icon_from_svg.assert_called_with("icons/switch.svg", "#e6cc00") 
    
    main_window.update_controller_type("player_1", enums.ControllerType.Wii)
    main_window.get_icon_from_svg.assert_called_with("icons/wii.svg", "#e6cc00") 

def test_toggle_controller_input_display(main_window, qtbot):
    """
    Function to test if clicking the "display controller input" checkboxes properly modify values for
    singular and multiple users 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        qtbot - fixture provided by pytest-qt for GUI testing
    """
    main_window.update_player_connection("connect", "player_1", enums.ControllerType.Xbox)
    player1_checkbox = main_window.player_checkbox_mapping["player_1"]

    # Case where player_1 checkbox is unchecked
    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is False
    
    # Case where player_1 checkbox is rechecked
    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is True

    main_window.update_player_connection("connect", "player_2", enums.ControllerType.Switch)
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
    