# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'PocketPad.ui'
##
## Created by: Qt User Interface Compiler version 6.8.2
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QAbstractItemView, QApplication, QCheckBox, QFrame,
    QHBoxLayout, QLabel, QListWidget, QListWidgetItem,
    QMainWindow, QMenuBar, QPushButton, QScrollArea,
    QSizePolicy, QSpacerItem, QStatusBar, QTabWidget,
    QVBoxLayout, QWidget)

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        if not MainWindow.objectName():
            MainWindow.setObjectName(u"MainWindow")
        MainWindow.resize(800, 599)
        self.centralwidget = QWidget(MainWindow)
        self.centralwidget.setObjectName(u"centralwidget")
        self.horizontalLayout = QHBoxLayout(self.centralwidget)
        self.horizontalLayout.setObjectName(u"horizontalLayout")
        self.connection_widgets = QWidget(self.centralwidget)
        self.connection_widgets.setObjectName(u"connection_widgets")
        sizePolicy = QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.connection_widgets.sizePolicy().hasHeightForWidth())
        self.connection_widgets.setSizePolicy(sizePolicy)
        self.connection_widgets.setMaximumSize(QSize(16777215, 16777215))
        self.verticalLayout_2 = QVBoxLayout(self.connection_widgets)
        self.verticalLayout_2.setObjectName(u"verticalLayout_2")
        self.connection_list_area = QFrame(self.connection_widgets)
        self.connection_list_area.setObjectName(u"connection_list_area")
        sizePolicy.setHeightForWidth(self.connection_list_area.sizePolicy().hasHeightForWidth())
        self.connection_list_area.setSizePolicy(sizePolicy)
        self.connection_list_area.setMinimumSize(QSize(50, 275))
        self.connection_list_area.setMaximumSize(QSize(350, 16777215))
        self.connection_list_area.setFrameShape(QFrame.Shape.StyledPanel)
        self.connection_list_area.setProperty(u"widgetResizable", True)
        self.verticalLayout_3 = QVBoxLayout(self.connection_list_area)
        self.verticalLayout_3.setObjectName(u"verticalLayout_3")
        self.controllers_label = QLabel(self.connection_list_area)
        self.controllers_label.setObjectName(u"controllers_label")
        sizePolicy1 = QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred)
        sizePolicy1.setHorizontalStretch(0)
        sizePolicy1.setVerticalStretch(0)
        sizePolicy1.setHeightForWidth(self.controllers_label.sizePolicy().hasHeightForWidth())
        self.controllers_label.setSizePolicy(sizePolicy1)
        self.controllers_label.setMaximumSize(QSize(16777215, 30))
        font = QFont()
        font.setPointSize(14)
        font.setBold(True)
        self.controllers_label.setFont(font)
        self.controllers_label.setAlignment(Qt.AlignmentFlag.AlignHCenter|Qt.AlignmentFlag.AlignTop)

        self.verticalLayout_3.addWidget(self.controllers_label)

        self.connection_list = QListWidget(self.connection_list_area)
        self.connection_list.setObjectName(u"connection_list")
        self.connection_list.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAsNeeded)
        self.connection_list.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)

        self.verticalLayout_3.addWidget(self.connection_list)

        self.num_connected_label = QLabel(self.connection_list_area)
        self.num_connected_label.setObjectName(u"num_connected_label")
        sizePolicy1.setHeightForWidth(self.num_connected_label.sizePolicy().hasHeightForWidth())
        self.num_connected_label.setSizePolicy(sizePolicy1)
        font1 = QFont()
        font1.setPointSize(10)
        self.num_connected_label.setFont(font1)
        self.num_connected_label.setAlignment(Qt.AlignmentFlag.AlignRight|Qt.AlignmentFlag.AlignTrailing|Qt.AlignmentFlag.AlignVCenter)

        self.verticalLayout_3.addWidget(self.num_connected_label)


        self.verticalLayout_2.addWidget(self.connection_list_area)

        self.verticalSpacer = QSpacerItem(20, 20, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Fixed)

        self.verticalLayout_2.addItem(self.verticalSpacer)

        self.settings_area = QFrame(self.connection_widgets)
        self.settings_area.setObjectName(u"settings_area")
        sizePolicy.setHeightForWidth(self.settings_area.sizePolicy().hasHeightForWidth())
        self.settings_area.setSizePolicy(sizePolicy)
        self.settings_area.setMinimumSize(QSize(50, 225))
        self.settings_area.setMaximumSize(QSize(350, 16777215))
        self.settings_area.setFrameShape(QFrame.Shape.StyledPanel)
        self.verticalLayout_4 = QVBoxLayout(self.settings_area)
        self.verticalLayout_4.setObjectName(u"verticalLayout_4")
        self.settings_label = QLabel(self.settings_area)
        self.settings_label.setObjectName(u"settings_label")
        self.settings_label.setFont(font)
        self.settings_label.setFrameShape(QFrame.Shape.NoFrame)
        self.settings_label.setFrameShadow(QFrame.Shadow.Raised)
        self.settings_label.setAlignment(Qt.AlignmentFlag.AlignCenter)

        self.verticalLayout_4.addWidget(self.settings_label)

        self.settings_selection = QTabWidget(self.settings_area)
        self.settings_selection.setObjectName(u"settings_selection")
        self.settings_selection.setAutoFillBackground(False)
        self.settings_selection.setTabPosition(QTabWidget.TabPosition.North)
        self.settings_selection.setElideMode(Qt.TextElideMode.ElideNone)
        self.network_tab = QWidget()
        self.network_tab.setObjectName(u"network_tab")
        self.verticalLayout_6 = QVBoxLayout(self.network_tab)
        self.verticalLayout_6.setObjectName(u"verticalLayout_6")
        self.connection_selection = QFrame(self.network_tab)
        self.connection_selection.setObjectName(u"connection_selection")
        sizePolicy.setHeightForWidth(self.connection_selection.sizePolicy().hasHeightForWidth())
        self.connection_selection.setSizePolicy(sizePolicy)
        self.connection_selection.setMinimumSize(QSize(0, 75))
        self.connection_selection.setFrameShape(QFrame.Shape.StyledPanel)
        self.verticalLayout_7 = QVBoxLayout(self.connection_selection)
        self.verticalLayout_7.setObjectName(u"verticalLayout_7")
        self.label = QLabel(self.connection_selection)
        self.label.setObjectName(u"label")
        sizePolicy.setHeightForWidth(self.label.sizePolicy().hasHeightForWidth())
        self.label.setSizePolicy(sizePolicy)

        self.verticalLayout_7.addWidget(self.label)

        self.network_button = QPushButton(self.connection_selection)
        self.network_button.setObjectName(u"network_button")
        sizePolicy2 = QSizePolicy(QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        sizePolicy2.setHorizontalStretch(0)
        sizePolicy2.setVerticalStretch(0)
        sizePolicy2.setHeightForWidth(self.network_button.sizePolicy().hasHeightForWidth())
        self.network_button.setSizePolicy(sizePolicy2)
        self.network_button.setMaximumSize(QSize(16777215, 50))

        self.verticalLayout_7.addWidget(self.network_button)

        self.bluetooth_button = QPushButton(self.connection_selection)
        self.bluetooth_button.setObjectName(u"bluetooth_button")
        sizePolicy2.setHeightForWidth(self.bluetooth_button.sizePolicy().hasHeightForWidth())
        self.bluetooth_button.setSizePolicy(sizePolicy2)
        self.bluetooth_button.setMaximumSize(QSize(16777215, 50))

        self.verticalLayout_7.addWidget(self.bluetooth_button)

        self.server_close_button = QPushButton(self.connection_selection)
        self.server_close_button.setObjectName(u"server_close_button")
        sizePolicy2.setHeightForWidth(self.server_close_button.sizePolicy().hasHeightForWidth())
        self.server_close_button.setSizePolicy(sizePolicy2)
        self.server_close_button.setMaximumSize(QSize(16777215, 50))

        self.verticalLayout_7.addWidget(self.server_close_button)


        self.verticalLayout_6.addWidget(self.connection_selection)

        self.verticalSpacer_3 = QSpacerItem(20, 5, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Fixed)

        self.verticalLayout_6.addItem(self.verticalSpacer_3)

        self.latency_setting_box = QCheckBox(self.network_tab)
        self.latency_setting_box.setObjectName(u"latency_setting_box")
        sizePolicy3 = QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        sizePolicy3.setHorizontalStretch(0)
        sizePolicy3.setVerticalStretch(0)
        sizePolicy3.setHeightForWidth(self.latency_setting_box.sizePolicy().hasHeightForWidth())
        self.latency_setting_box.setSizePolicy(sizePolicy3)
        self.latency_setting_box.setChecked(True)
        self.latency_setting_box.setTristate(False)

        self.verticalLayout_6.addWidget(self.latency_setting_box)

        self.settings_selection.addTab(self.network_tab, "")
        self.controller_tab = QWidget()
        self.controller_tab.setObjectName(u"controller_tab")
        self.verticalLayout_5 = QVBoxLayout(self.controller_tab)
        self.verticalLayout_5.setObjectName(u"verticalLayout_5")
        self.controller_checkboxes = QScrollArea(self.controller_tab)
        self.controller_checkboxes.setObjectName(u"controller_checkboxes")
        self.controller_checkboxes.setVerticalScrollBarPolicy(Qt.ScrollBarPolicy.ScrollBarAsNeeded)
        self.controller_checkboxes.setWidgetResizable(True)
        self.scrollAreaWidgetContents = QWidget()
        self.scrollAreaWidgetContents.setObjectName(u"scrollAreaWidgetContents")
        self.scrollAreaWidgetContents.setGeometry(QRect(0, 0, 236, 139))
        self.controller_checkboxes.setWidget(self.scrollAreaWidgetContents)

        self.verticalLayout_5.addWidget(self.controller_checkboxes)

        self.settings_selection.addTab(self.controller_tab, "")

        self.verticalLayout_4.addWidget(self.settings_selection)


        self.verticalLayout_2.addWidget(self.settings_area)


        self.horizontalLayout.addWidget(self.connection_widgets)

        self.main_layout_spacer_left = QSpacerItem(20, 20, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Minimum)

        self.horizontalLayout.addItem(self.main_layout_spacer_left)

        self.main_application_area = QWidget(self.centralwidget)
        self.main_application_area.setObjectName(u"main_application_area")
        sizePolicy4 = QSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)
        sizePolicy4.setHorizontalStretch(1)
        sizePolicy4.setVerticalStretch(0)
        sizePolicy4.setHeightForWidth(self.main_application_area.sizePolicy().hasHeightForWidth())
        self.main_application_area.setSizePolicy(sizePolicy4)
        self.main_application_area.setMinimumSize(QSize(400, 100))
        self.verticalLayout = QVBoxLayout(self.main_application_area)
        self.verticalLayout.setObjectName(u"verticalLayout")
        self.verticalSpacer_4 = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Fixed)

        self.verticalLayout.addItem(self.verticalSpacer_4)

        self.graphicsView = QFrame(self.main_application_area)
        self.graphicsView.setObjectName(u"graphicsView")
        sizePolicy4.setHeightForWidth(self.graphicsView.sizePolicy().hasHeightForWidth())
        self.graphicsView.setSizePolicy(sizePolicy4)
        self.graphicsView.setMinimumSize(QSize(25, 375))
        self.graphicsView.setFrameShape(QFrame.Shape.StyledPanel)

        self.verticalLayout.addWidget(self.graphicsView)

        self.code_depression_spacer = QSpacerItem(20, 10, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Fixed)

        self.verticalLayout.addItem(self.code_depression_spacer)

        self.connection_code_area = QFrame(self.main_application_area)
        self.connection_code_area.setObjectName(u"connection_code_area")
        sizePolicy.setHeightForWidth(self.connection_code_area.sizePolicy().hasHeightForWidth())
        self.connection_code_area.setSizePolicy(sizePolicy)
        self.connection_code_area.setMinimumSize(QSize(400, 75))
        self.connection_code_area.setMaximumSize(QSize(16777215, 125))
        self.connection_code_area.setAutoFillBackground(False)
        self.connection_code_area.setFrameShape(QFrame.Shape.NoFrame)
        self.horizontalLayout_2 = QHBoxLayout(self.connection_code_area)
        self.horizontalLayout_2.setObjectName(u"horizontalLayout_2")
        self.horizontalSpacer = QSpacerItem(40, 20, QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Minimum)

        self.horizontalLayout_2.addItem(self.horizontalSpacer)

        self.connection_code_box = QFrame(self.connection_code_area)
        self.connection_code_box.setObjectName(u"connection_code_box")
        sizePolicy.setHeightForWidth(self.connection_code_box.sizePolicy().hasHeightForWidth())
        self.connection_code_box.setSizePolicy(sizePolicy)
        self.connection_code_box.setMinimumSize(QSize(300, 75))
        self.connection_code_box.setMaximumSize(QSize(400, 125))
        self.connection_code_box.setFrameShape(QFrame.Shape.StyledPanel)
        self.connection_code_box.setFrameShadow(QFrame.Shadow.Sunken)
        self.verticalLayout_8 = QVBoxLayout(self.connection_code_box)
        self.verticalLayout_8.setObjectName(u"verticalLayout_8")
        self.widget = QWidget(self.connection_code_box)
        self.widget.setObjectName(u"widget")
        self.horizontalLayout_3 = QHBoxLayout(self.widget)
        self.horizontalLayout_3.setObjectName(u"horizontalLayout_3")
        self.horizontalSpacer_4 = QSpacerItem(40, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Minimum)

        self.horizontalLayout_3.addItem(self.horizontalSpacer_4)

        self.label_3 = QLabel(self.widget)
        self.label_3.setObjectName(u"label_3")
        self.label_3.setAlignment(Qt.AlignmentFlag.AlignCenter)

        self.horizontalLayout_3.addWidget(self.label_3)

        self.view_code = QPushButton(self.widget)
        self.view_code.setObjectName(u"view_code")
        sizePolicy5 = QSizePolicy(QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Fixed)
        sizePolicy5.setHorizontalStretch(0)
        sizePolicy5.setVerticalStretch(0)
        sizePolicy5.setHeightForWidth(self.view_code.sizePolicy().hasHeightForWidth())
        self.view_code.setSizePolicy(sizePolicy5)
        self.view_code.setMinimumSize(QSize(0, 25))
        self.view_code.setMaximumSize(QSize(50, 16777215))

        self.horizontalLayout_3.addWidget(self.view_code)

        self.horizontalSpacer_3 = QSpacerItem(60, 20, QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Minimum)

        self.horizontalLayout_3.addItem(self.horizontalSpacer_3)


        self.verticalLayout_8.addWidget(self.widget)

        self.label_2 = QLabel(self.connection_code_box)
        self.label_2.setObjectName(u"label_2")
        font2 = QFont()
        font2.setPointSize(30)
        font2.setBold(True)
        self.label_2.setFont(font2)
        self.label_2.setTextFormat(Qt.TextFormat.PlainText)
        self.label_2.setAlignment(Qt.AlignmentFlag.AlignCenter)

        self.verticalLayout_8.addWidget(self.label_2)


        self.horizontalLayout_2.addWidget(self.connection_code_box)

        self.horizontalSpacer_2 = QSpacerItem(40, 20, QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Minimum)

        self.horizontalLayout_2.addItem(self.horizontalSpacer_2)


        self.verticalLayout.addWidget(self.connection_code_area)

        self.code_elevation_spacer = QSpacerItem(20, 10, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Fixed)

        self.verticalLayout.addItem(self.code_elevation_spacer)


        self.horizontalLayout.addWidget(self.main_application_area)

        self.main_layout_spacer_right = QSpacerItem(50, 20, QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Minimum)

        self.horizontalLayout.addItem(self.main_layout_spacer_right)

        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QMenuBar(MainWindow)
        self.menubar.setObjectName(u"menubar")
        self.menubar.setGeometry(QRect(0, 0, 800, 19))
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QStatusBar(MainWindow)
        self.statusbar.setObjectName(u"statusbar")
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)

        self.settings_selection.setCurrentIndex(0)


        QMetaObject.connectSlotsByName(MainWindow)
    # setupUi

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QCoreApplication.translate("MainWindow", u"PocketPad", None))
        self.controllers_label.setText(QCoreApplication.translate("MainWindow", u"Connected Controllers", None))
        self.num_connected_label.setText(QCoreApplication.translate("MainWindow", u"0/4", None))
        self.settings_label.setText(QCoreApplication.translate("MainWindow", u"<html><head/><body><p>Settings</p></body></html>", None))
        self.label.setText(QCoreApplication.translate("MainWindow", u"<html><head/><body><p><span style=\" font-size:10pt; font-weight:700;\">Server Options:</span></p></body></html>", None))
        self.network_button.setText(QCoreApplication.translate("MainWindow", u"Network Server", None))
        self.bluetooth_button.setText(QCoreApplication.translate("MainWindow", u"Bluetooth Server", None))
        self.server_close_button.setText(QCoreApplication.translate("MainWindow", u"Shut Down Server", None))
        self.latency_setting_box.setText(QCoreApplication.translate("MainWindow", u"Display Controller Latency", None))
        self.settings_selection.setTabText(self.settings_selection.indexOf(self.network_tab), QCoreApplication.translate("MainWindow", u"Networks", None))
        self.settings_selection.setTabText(self.settings_selection.indexOf(self.controller_tab), QCoreApplication.translate("MainWindow", u"Controllers", None))
        self.label_3.setText(QCoreApplication.translate("MainWindow", u"<html><head/><body><p><span style=\" font-size:14pt; font-weight:700;\">Pair Code:</span></p></body></html>", None))
        self.view_code.setText(QCoreApplication.translate("MainWindow", u"Button", None))
        self.label_2.setText(QCoreApplication.translate("MainWindow", u"123 456", None))
    # retranslateUi

