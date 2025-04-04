//
//  PocketPad_ClientUITests.swift
//  PocketPad ClientUITests
//
//  Created by lemin on 2/17/25.
//

import XCTest

final class PocketPad_ClientUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    @MainActor
    func testOpenandCloseSettingsMenu() throws {
        let app = XCUIApplication()
        app.launch()
        
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: 3) else{
            XCTFail("Settings button open not found")
            return
        }
        
        settingsBtn.tap()
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        guard settingsCloseBtn.waitForExistence(timeout: 3) else{
            XCTFail("Settings button close not found")
            return
        }
        settingsCloseBtn.tap()
    }
    
    @MainActor
    func testChangeControllerName() throws {
        let app = XCUIApplication()
        app.launch()
        
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: 3) else {
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        
        let nameField = app.textFields["NameField"]
        guard nameField.waitForExistence(timeout: 3) else {
            XCTFail("Name field not found")
            return
        }
        nameField.tap()
        let endCoord = nameField.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        endCoord.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 100)
        nameField.typeText(deleteString)
        let newName = "My Controller"
        nameField.typeText(newName)
        XCTAssertEqual(nameField.value as? String, newName, "Controller Name text field did not update correctly.")
        
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        guard settingsCloseBtn.waitForExistence(timeout: 10) else{
            XCTFail("Settings button close not found")
            return
        }
        Thread.sleep(forTimeInterval: 2.0)

        settingsCloseBtn.tap()
        Thread.sleep(forTimeInterval: 1.0)

        settingsBtn.tap()
        Thread.sleep(forTimeInterval: 2.0)

        settingsCloseBtn.tap()
    }
    @MainActor
    func testDPadStyle() throws {
        let app = XCUIApplication()
        app.launch()
        
        let dpadTypes = ["Conjoined", "Split"]
        let settingsBtn = app.buttons["SettingsGearButton"]
        let dpadStyle = app.buttons["DPadStyle"]
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        let controllerViewBtn = app.buttons["OpenControllerView"]
        
        var choseController: Bool = false
        for dpadType in dpadTypes {
            // open settings menu
            guard settingsBtn.waitForExistence(timeout: 3) else {
                XCTFail("Settings button open not found")
                return
            }
            settingsBtn.tap()
            
            if !choseController {
                choseController = true
                // make sure a controller with a dpad is selected
                let controllerPicker = app.buttons["ControllerPicker"]
                guard controllerPicker.waitForExistence(timeout: 2) else {
                    XCTFail()
                    return
                }
                controllerPicker.tap()
                
                let controllerBtn = app.buttons["Xbox"]
                guard controllerBtn.waitForExistence(timeout: 1) else {
                    XCTFail()
                    return
                }
                controllerBtn.tap()
            }
            
            // select dpad style
            XCTAssertTrue(dpadStyle.waitForExistence(timeout: 2))
            dpadStyle.tap()
            let dpadOption = app.buttons[dpadType]
            guard dpadOption.waitForExistence(timeout: 1) else {
                XCTFail()
                return
            }
            dpadOption.tap()
            
            // close settings and go to controller view
            XCTAssertTrue(settingsCloseBtn.exists)
            settingsCloseBtn.tap()
            
            guard controllerViewBtn.waitForExistence(timeout: 3) else {
                XCTFail("ControllerViewButton not found")
                return
            }
            controllerViewBtn.tap()
            
            // make sure that the dpad exists and is the correct type
            if dpadType == "Conjoined" {
                // test for conjoined dpad
                XCTAssertTrue(app.buttons["DPadConjoined"].waitForExistence(timeout: 3))
            } else if dpadType == "Split" {
                // test for split dpad
                XCTAssertTrue(app.buttons["DPadButton"].waitForExistence(timeout: 3))
                XCTAssertFalse(app.buttons["DPadConjoined"].exists)
            } else {
                XCTFail("Invalid dpad type")
            }
            
            // go back to the previous view
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
    
    @MainActor
    func testControllerDisplay() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let validControllers = ["Xbox", "PlayStation", "Switch", "Wii"]
        let controllerBtnCount = [
            "Xbox": 14,
            "PlayStation": 13,
            "Switch": 15,
            "Wii": 9
        ]
        
        // Define the buttons
        let settingsBtn = app.buttons["SettingsGearButton"]
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        let controllerViewBtn = app.buttons["OpenControllerView"]
        let controllerPicker = app.buttons["ControllerPicker"]
        
        for validController in validControllers {
            guard settingsBtn.waitForExistence(timeout: 2) else {
                XCTFail()
                return
            }
            settingsBtn.tap()
            
            // select the controller from the picker
            guard controllerPicker.waitForExistence(timeout: 2) else {
                XCTFail()
                return
            }
            controllerPicker.tap()
            
            let controllerBtn = app.buttons[validController]
            guard controllerBtn.waitForExistence(timeout: 1) else {
                XCTFail()
                return
            }
            controllerBtn.tap()
            XCTAssertTrue(settingsCloseBtn.exists)
            settingsCloseBtn.tap()
            
            // open up the controller view
            guard controllerViewBtn.waitForExistence(timeout: 2) else {
                XCTFail()
                return
            }
            controllerViewBtn.tap()
            
            XCTAssertTrue(app.buttons["ControllerButton"].waitForExistence(timeout: 2))
            
            // make sure the count of the buttons is equal to the specified controller setup
            XCTAssertEqual(app.buttons.matching(identifier: "ControllerButton").count + app.buttons.matching(identifier: "DPadButton").count, controllerBtnCount[validController])
            
            // go back to the previous view
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
    
    @MainActor
    func testLayoutSaving() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let alertDismiss = app.alerts.element.buttons["AlertCancel"]
        
        // open settings
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: 2) else {
            XCTFail()
            return
        }
        settingsBtn.tap()
        
        let removeFiles = app.buttons["RemoveLayoutFiles"]
        XCTAssertTrue(removeFiles.waitForExistence(timeout: 2))
        removeFiles.tap()
        
        // make sure that the buttons don't exist in the list
        let controllerPicker = app.buttons["ControllerPicker"]
        guard controllerPicker.waitForExistence(timeout: 2) else {
            XCTFail()
            return
        }
        controllerPicker.tap()
        XCTAssertTrue(app.buttons["Xbox"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Xbox Saved"].exists)
        XCTAssertFalse(app.buttons["Wii Saved"].exists)
        app.buttons["Xbox"].tap()
        
        let chooseTemplate = app.buttons["ChooseTemplate"]
        XCTAssertTrue(chooseTemplate.exists)
        chooseTemplate.tap()
        
        // try to save malformed
        let malformedBtn = app.buttons["MalformedLayout"]
        XCTAssertTrue(malformedBtn.waitForExistence(timeout: 2))
        malformedBtn.tap()
        
        XCTAssertTrue(alertDismiss.waitForExistence(timeout: 4))
        XCTAssertTrue(app.alerts.element.staticTexts["Failed to save the layout"].exists)
        alertDismiss.tap()
        
        // try to save xbox
        XCTAssertTrue(chooseTemplate.waitForExistence(timeout: 2))
        chooseTemplate.tap()
        let xboxBtn = app.buttons["Xbox Saved"]
        XCTAssertTrue(xboxBtn.waitForExistence(timeout: 2))
        xboxBtn.tap()
        XCTAssertTrue(alertDismiss.waitForExistence(timeout: 4))
        XCTAssertTrue(app.alerts.element.staticTexts["Layout Successfully Saved"].exists)
        alertDismiss.tap()
        // make sure it is in the list
        guard controllerPicker.waitForExistence(timeout: 2) else {
            XCTFail()
            return
        }
        controllerPicker.tap()
        XCTAssertTrue(xboxBtn.waitForExistence(timeout: 2))
        xboxBtn.tap()
        
        // try to save malformed wii
        let saveMalformed = app.switches["SaveAsMalformed"]
        XCTAssertTrue(saveMalformed.waitForExistence(timeout: 2))
        saveMalformed.tap()
        XCTAssertTrue(chooseTemplate.exists)
        chooseTemplate.tap()
        let wiiBtn = app.buttons["Wii Saved"]
        XCTAssertTrue(wiiBtn.waitForExistence(timeout: 2))
        wiiBtn.tap()
        XCTAssertTrue(alertDismiss.waitForExistence(timeout: 4))
        XCTAssertTrue(app.alerts.element.staticTexts["Layout Successfully Saved"].exists)
        alertDismiss.tap()
        // make sure it is in the list
        guard controllerPicker.waitForExistence(timeout: 2) else {
            XCTFail()
            return
        }
        controllerPicker.tap()
        XCTAssertTrue(wiiBtn.waitForExistence(timeout: 2))
        wiiBtn.tap()
        XCTAssertTrue(alertDismiss.waitForExistence(timeout: 4))
        XCTAssertTrue(app.alerts.element.staticTexts["Failed to load layout"].exists)
        alertDismiss.tap()
    }
    
    @MainActor
    func testHideDPad() throws {
        // tests if the settings view dpad option hides when a gamepad without a dpad is selected
        continueAfterFailure = false
        let app = XCUIApplication() // Initializes the XCTest app
        app.launch() // Launches the app
        
        // make it go to the view
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: 5) else {
            XCTFail()
            return
        }
        settingsBtn.tap()
        
        let controllerPicker = app.buttons["ControllerPicker"]
        guard controllerPicker.waitForExistence(timeout: 2) else {
            XCTFail()
            return
        }
        
        controllerPicker.tap()
        
        // set current controller to one that has a dpad
        let xboxBtn = app.buttons["Xbox"]
        guard xboxBtn.waitForExistence(timeout: 1) else {
            XCTFail()
            return
        }
        xboxBtn.tap()
        
        // DPad style should exist now
        let dpadStyleBtn = app.buttons["DPadStyle"]
        XCTAssertTrue(dpadStyleBtn.waitForExistence(timeout: 1))
        
        controllerPicker.tap()
        
        // set to current controller without dpad
        let dpadlessBtn = app.buttons["DPad-less Test"]
        guard dpadlessBtn.waitForExistence(timeout: 1) else {
            XCTFail()
            return
        }
        dpadlessBtn.tap()
        
        // make sure the button is no longer there
        XCTAssertTrue(dpadStyleBtn.waitForNonExistence(timeout: 1))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testChangeTurboRate() throws {
        let app = XCUIApplication()
        app.launch()
        
        let settingsBtn = app.buttons["SettingsGearButton"]
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        let turboRateBtn = app.buttons["TurboRateButton"]
        
        let turboRateSlider = app.sliders["TurboRateSlider"]
        let turboSettingsRateStaticText = app.staticTexts["TurboSettingsRate"]
        let applyTurboRateBtn = app.buttons["ApplyTurboRateButton"]
        
        // Open settings menu
        guard settingsBtn.waitForExistence(timeout: 3) else {
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        
        // Open turbo rate settings menu
        guard turboRateBtn.waitForExistence(timeout: 1) else {
            XCTFail("Turbo rate button not found")
            return
        }
        turboRateBtn.tap()
        
        // Moving slider
        guard turboRateSlider.waitForExistence(timeout: 1) else {
            XCTFail("Slider not found")
            return
        }
        turboRateSlider.adjust(toNormalizedSliderPosition: Double.random(in: 0.0...1.0)) // random value
        
        print(app.debugDescription)
        
        // Store the new value that the turbo rate slider was set to
        guard turboSettingsRateStaticText.waitForExistence(timeout: 5) else {
            XCTFail("Turbo settings rate static text not found")
            return
        }
        let turboRateExpected: String? = turboSettingsRateStaticText.label.components(separatedBy: " ").first // extract number
        
        // Apply changes
        guard applyTurboRateBtn.waitForExistence(timeout: 1) else {
            XCTFail("Apply turbo rate button not found")
            return
        }
        applyTurboRateBtn.tap()
        
        // Close settings
        XCTAssertTrue(settingsCloseBtn.exists)
        settingsCloseBtn.tap()
        
        // Reopen settings menu to check new turbo rate value
        guard settingsBtn.waitForExistence(timeout: 3) else {
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        
        // Check new turbo rate value
        guard turboRateBtn.waitForExistence(timeout: 1) else {
            XCTFail("Turbo rate button not found")
            return
        }
        print("DEBUGGING Label is: \(turboRateBtn.label)")
        let turboRateActual: String? = turboRateBtn.label.components(separatedBy: " ").first // extract number
        XCTAssertTrue(turboRateActual != nil && turboRateExpected != nil && turboRateActual == turboRateExpected)
    }
}
