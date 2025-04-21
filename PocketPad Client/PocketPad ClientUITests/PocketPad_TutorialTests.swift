//
//  PocketPad_TutorialTests.swift
//  PocketPad Client
//
//  Created by lemin on 4/18/25.
//

import XCTest

final class PocketPad_TutorialTests: XCTestCase {
    
    private var TIMEOUT: TimeInterval = 15
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func clickThroughTutorial(app: XCUIApplication) {
        let tutNextBtn = app.buttons["OnBoardingNext"]
        let numScreens = 5
        for _ in 1...numScreens {
            XCTAssertTrue(tutNextBtn.waitForExistence(timeout: TIMEOUT), "The tutorial next button did not appear")
            tutNextBtn.tap()
        }
        
        // make sure the tutorial screen is gone
        XCTAssertTrue(tutNextBtn.waitForNonExistence(timeout: TIMEOUT), "The tutorial did not disappear")
    }
    
    @MainActor
    func testTutorial() throws {
        // MARK: First Launch, show tutorial
        var app = XCUIApplication() // Initializes the XCTest app
        app.launchArguments = ["show-tutorial"]
        app.launch() // Launches the app
        
        // check tutorial screen
        clickThroughTutorial(app: app)
        
        // reopen the app and make sure tutorial does not appear again
        app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(app.buttons["SettingsGearButton"].waitForExistence(timeout: TIMEOUT), "The tutorial appeared again")
        XCTAssertFalse(app.buttons["OnBoardingNext"].exists, "The tutorial appeared again")
    }
    
    @MainActor
    func testResetTutorial() throws {
        let app = XCUIApplication() // Initializes the XCTest app
        app.launchArguments = ["no-tutorial"]
        app.launch() // Launches the app
        
        // open settings
        let settingsBtn = app.buttons["SettingsGearButton"]
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: TIMEOUT), "The settings button could not be found")
        settingsBtn.tap()
        let viewTutBtn = app.buttons["ViewTutorial"]
        XCTAssertTrue(viewTutBtn.waitForExistence(timeout: TIMEOUT), "The view tutorial button could not be found")
        viewTutBtn.tap()
        
        // check tutorial screen
        clickThroughTutorial(app: app)
    }
    
    @MainActor
    func testPopoverTips() throws {
        let app = XCUIApplication() // Initializes the XCTest app
        app.launchArguments = ["reset-tips", "no-tutorial", "remove-layouts"]
        app.launch() // Launches the app
        
        // open settings
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: TIMEOUT) else{
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        guard settingsCloseBtn.waitForExistence(timeout: TIMEOUT) else { XCTFail("Settings button close not found"); return }
        
        // create new layout
        let createLayout = app.buttons["CreateNewLayoutButton"]
        createLayout.tap()
        let nameField = app.textFields["Layout Name"]
        guard nameField.waitForExistence(timeout: TIMEOUT) else {
            XCTFail("Name field not found")
            return
        }
        let layoutName = "Tutorial Popover Test"
        nameField.typeText(layoutName)
        XCTAssertEqual(nameField.value as? String, layoutName, "Layout name text field did not update correctly.")
        let setButton = app.alerts.buttons["LayoutNameOK"]
        setButton.tap()
        XCTAssertTrue(setButton.waitForNonExistence(timeout: TIMEOUT), "Ok button did not disappear.")
        
        // verify the name in the controller input
        let controllerPicker = app.buttons["ControllerPicker"]
        XCTAssertEqual(controllerPicker.label, "Picker\(layoutName)", "Layout name did not update the controller picker.")
        
        // open up the editor
        guard settingsCloseBtn.waitForExistence(timeout: TIMEOUT) else { XCTFail("Settings button close not found"); return }
        settingsCloseBtn.tap()
        let modifyLayoutView = app.buttons["ModifyLayoutView"]
        XCTAssertTrue(modifyLayoutView.waitForExistence(timeout: TIMEOUT), "No modify button was found.")
        modifyLayoutView.tap()
        
        let mainEditorView = app.otherElements["MainControllerScreen"]
        XCTAssertTrue(mainEditorView.waitForExistence(timeout: TIMEOUT), "The main controller screen could not be found.")
        
        // check if the rotation tip appeared
        XCTAssertTrue(app.otherElements["PopoverDismissRegion"].waitForExistence(timeout: TIMEOUT), "The orientation tip did not appear")
        app.otherElements["PopoverDismissRegion"].tap()
        
        // add a button
        let newButtonBtn = app.buttons["NewButtonBtn"]
        let addButtonBtn = app.buttons["AddButtonBtn"]
        XCTAssertTrue(newButtonBtn.waitForExistence(timeout: TIMEOUT), "The new button button was not found.")
        newButtonBtn.tap()
        XCTAssertTrue(addButtonBtn.waitForExistence(timeout: TIMEOUT), "The add button button doesn't exist.")
        addButtonBtn.tap()
        let button = app.otherElements["SelectedBtn"]
        XCTAssertTrue(button.waitForExistence(timeout: TIMEOUT), "The selected button was not found on screen.")
        button.tap()
        app.buttons["ControllerButton"].tap() // fix a SwiftUI bug
        
        // make sure the override toggle is on screen
        let overrideToggle = app.switches.element(matching: .switch, identifier: "OverrideOrientation")
        XCTAssertTrue(overrideToggle.waitForExistence(timeout: TIMEOUT), "Override toggle was not found")
        // check if the override tip exists
        XCTAssertTrue(app.otherElements["PopoverDismissRegion"].waitForExistence(timeout: TIMEOUT), "The override tip did not appear")
        app.otherElements["PopoverDismissRegion"].tap()
    }
}
