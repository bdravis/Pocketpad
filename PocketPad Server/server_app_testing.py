import pytest
from PySide6.QtWidgets import QApplication, QMessageBox
from PySide6.QtCore import Qt
from server_app import MainWindow  # Import your main application file

@pytest.fixture
def main_window(qtbot):
    """
    Function that creates a testing instance of the server application of PocketPad

    @param:
        qtbot - fixture provided pytest-qt for GUI testing
    
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

# NEEDS TO BE REVISED WHEN BLUETOOTH SERVER SHUTDOWN IS PROPERLY FIXED
def test_bluetooth_button_click(main_window, qtbot):
    """
    Function to test if clicking the Bluetooth button properly initiates the Bluetooth server
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        qtbot - fixture provided pytest-qt for GUI testing
    """
    qtbot.mouseClick(main_window.ui.bluetooth_button, Qt.LeftButton)
    qtbot.wait(100)
    assert main_window.bluetooth_server_initiated is True
    assert main_window.network_server_initiated is False

# NEEDS TO BE REVISED WHEN NETWORK SERVER GETS IMPLEMENTED
def test_network_button_click(main_window, qtbot):
    """
    Function to test if clicking the Network button properly initiates the Network server
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        qtbot - fixture provided pytest-qt for GUI testing
    """
    qtbot.mouseClick(main_window.ui.network_button, Qt.LeftButton)
    qtbot.wait(100)
    assert main_window.network_server_initiated is True
    assert main_window.bluetooth_server_initiated is False

# NEEDS TO BE REVISED ONCE COLORED ICONS ARE ADDED
def test_latency_display_checkbox(main_window, qtbot):
    """
    Function to test if clicking the "display latency" checkbox properly modify values and toggles
    visibility of different labels within the application 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        qtbot - fixture provided pytest-qt for GUI testing
    """

def test_input_display_checkboxes(main_window, qtbot):
    """
    Function to test if clicking the "display controller input" checkboxes properly modify values for
    singular and multiple users 
    
    @param:
        main_window - a testing instance of the MainWindow used to display the PocketPad application
        qtbot - fixture provided pytest-qt for GUI testing
    """
    main_window.update_player_connection("connect", "player_1", "xbox")
    player1_checkbox = main_window.player_checkbox_mapping["player_1"]

    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is False
    
    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is True

    main_window.update_player_connection("connect", "player_2", "custom")
    player2_checkbox = main_window.player_checkbox_mapping["player_2"]

    player1_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_1"] is False
    
    player2_checkbox.toggle()
    qtbot.wait(100)
    assert main_window.player_controller_input_display["player_2"] is False

