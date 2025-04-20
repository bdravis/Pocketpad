//
//  PocketPad_EditorUITests.swift
//  PocketPad Client
//
//  Created by lemin on 4/3/25.
//

import XCTest

final class PocketPad_EditorUITests: XCTestCase {
    
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
    
    @MainActor
    func testEditorFunctionality() throws {
        let app = XCUIApplication()
        app.launch()
        
        // open settings
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: TIMEOUT) else{
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        guard settingsCloseBtn.waitForExistence(timeout: TIMEOUT) else { XCTFail("Settings button close not found"); return }
        
        // clear all layouts
        let removeFiles = app.buttons["RemoveLayoutFiles"]
        removeFiles.tap()
        
        // create new layout
        let createLayout = app.buttons["CreateNewLayoutButton"]
        createLayout.tap()
        let nameField = app.textFields["Layout Name"]
        guard nameField.waitForExistence(timeout: TIMEOUT) else {
            XCTFail("Name field not found")
            return
        }
        let layoutName = "Editor UI Test"
        nameField.typeText(layoutName)
        XCTAssertEqual(nameField.value as? String, layoutName, "Layout name text field did not update correctly.")
        let setButton = app.alerts.buttons["LayoutNameOK"]
        setButton.tap()
        XCTAssertTrue(setButton.waitForNonExistence(timeout: TIMEOUT), "Ok button did not disappear.")
        
        // verify the name in the controller input
        let controllerPicker = app.buttons["ControllerPicker"]
        XCTAssertEqual(controllerPicker.label, "Picker\(layoutName)", "Layout name did not update the controller picker.")
        controllerPicker.tap()
        let nameInList = app.buttons[layoutName]
        XCTAssertTrue(nameInList.waitForExistence(timeout: TIMEOUT), "Layout name not found in the list.")
        nameInList.tap()
        
        // test duplicate names
        createLayout.tap()
        guard nameField.waitForExistence(timeout: TIMEOUT) else {
            XCTFail("Name field not found")
            return
        }
        nameField.typeText(layoutName)
        XCTAssertEqual(nameField.value as? String, layoutName, "Layout name text field did not update correctly.")
        setButton.tap()
        
        // verify that the error message appeared
        let alertDismiss = app.alerts.element.buttons["AlertCancel"]
        XCTAssertTrue(alertDismiss.waitForExistence(timeout: TIMEOUT))
        XCTAssertTrue(app.alerts.element.staticTexts["A layout with that name already exists."].exists, "The error message wasn't properly shown!")
        alertDismiss.tap()
        
        // open up the editor
        guard settingsCloseBtn.waitForExistence(timeout: TIMEOUT) else { XCTFail("Settings button close not found"); return }
        settingsCloseBtn.tap()
        let modifyLayoutView = app.buttons["ModifyLayoutView"]
        XCTAssertTrue(modifyLayoutView.waitForExistence(timeout: TIMEOUT), "No modify button was found.")
        modifyLayoutView.tap()
        
        // add a bunch of buttons
        let typesToAdd: [String: [String: CGPoint]] = [
            "Regular": [
                "A": CGPoint(x: 0.1, y: 0.1),
                "Start": CGPoint(x: 0.4, y: 0.1)
            ],
            "Joystick": [
                "RightJoystick": CGPoint(x: 0.7, y: 0.6),
                "LeftJoystick": CGPoint(x: 0.3, y: 0.6)
            ],
            "DPad": [
                "None": CGPoint(x: 0.9, y: 0.5)
            ],
            "Bumper": [
                "LB": CGPoint(x: 0.2, y: 0.8),
                "RB": CGPoint(x: 0.8, y: 0.8)
            ],
            "Trigger": [
                "Left": CGPoint(x: 0.5, y: 0.3),
                "Middle": CGPoint(x: 0.5, y: 0.5),
                "Right": CGPoint(x: 0.5, y: 0.7)
            ]
        ]
        let newButtonBtn = app.buttons["NewButtonBtn"]
        let btnTypeBtn = app.buttons["ButtonTypePicker"]
        let addButtonBtn = app.buttons["AddButtonBtn"]
        let mainEditorView = app.otherElements["MainControllerScreen"]
        XCTAssertTrue(mainEditorView.waitForExistence(timeout: TIMEOUT), "The main controller screen could not be found.")
        var counter = 0
        for (btnType, inputs) in typesToAdd {
            for (inp, pos) in inputs {
                XCTAssertTrue(newButtonBtn.waitForExistence(timeout: TIMEOUT), "The new button button was not found.")
                newButtonBtn.tap()
                XCTAssertTrue(btnTypeBtn.waitForExistence(timeout: TIMEOUT), "The button type button was not found.")
                btnTypeBtn.tap()
                let choice = app.buttons[btnType]
                XCTAssertTrue(choice.waitForExistence(timeout: TIMEOUT), "Button type option for \(btnType) does not exist.")
                choice.tap()
                if inp != "None" {
                    if btnType == "Trigger" {
                        // set the trigger side
                        let sideBtn = app.buttons[inp]
                        XCTAssertTrue(sideBtn.waitForExistence(timeout: TIMEOUT), "The side button for \(inp) does not exist.")
                        sideBtn.tap()
                    } else {
                        // select the input
                        let inpBtn = app.buttons["ButtonInputPicker"]
                        XCTAssertTrue(inpBtn.waitForExistence(timeout: TIMEOUT), "The input picker button does not exist.")
                        inpBtn.tap()
                        let inpChoice = app.buttons[inp]
                        XCTAssertTrue(inpChoice.waitForExistence(timeout: TIMEOUT), "The button for input \(inp) does not exist.")
                        inpChoice.tap()
                    }
                }
                XCTAssertTrue(addButtonBtn.waitForExistence(timeout: TIMEOUT), "The add button button doesn't exist.")
                addButtonBtn.tap()
                let button = app.otherElements["SelectedBtn"]
                XCTAssertTrue(button.waitForExistence(timeout: TIMEOUT), "The selected button was not found on screen.")
                
                // drag the button to the position
                let startCoord = button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                let endCoord = mainEditorView.coordinate(withNormalizedOffset: CGVector(dx: pos.x, dy: pos.y))
                startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
                if !button.exists {
                    let deselCoord = mainEditorView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                    deselCoord.tap()
                }
                // make sure the button is on screen
                XCTAssertTrue(button.exists, "The button no longer exists!")
                
                // configure certain properties for certain elements
                let editList = app.otherElements["EditBtnList"]
                if inp == "Start" {
                    // turn it into a pill, set to plus symbol, and rotate 40º
                    let shapePicker = app.buttons["ButtonShapePicker"]
                    // first do slanted pill
                    editList.scrollToElement(shapePicker, upward: false, amt: -100)
                    XCTAssertTrue(shapePicker.exists, "The button shape picker does not exist.")
                    shapePicker.tap()
                    let slantedPillShape = app.buttons["Slanted Pill"]
                    XCTAssertTrue(slantedPillShape.waitForExistence(timeout: TIMEOUT), "The slanted pill shape choice could not be found.")
                    slantedPillShape.tap()
                    XCTAssertTrue(slantedPillShape.waitForNonExistence(timeout: TIMEOUT), "The slanted pill shape choice did not disappear.")
                    
                    // next try regular pill
                    XCTAssertTrue(shapePicker.exists, "The button shape picker does not exist.")
                    shapePicker.tap()
                    let pillShape = app.buttons["Pill"]
                    XCTAssertTrue(pillShape.waitForExistence(timeout: TIMEOUT), "The pill shape choice could not be found.")
                    pillShape.tap()
                    XCTAssertTrue(pillShape.waitForNonExistence(timeout: TIMEOUT), "The pill shape choice did not disappear.")
                    
                    // set icon type to sf symbol
                    let iconTypePicker = app.buttons["IconTypePicker"]
                    editList.scrollToElement(iconTypePicker, upward: false, amt: -100)
                    iconTypePicker.tap()
                    let sfBtn = app.buttons["SF Symbol"]
                    XCTAssertTrue(sfBtn.waitForExistence(timeout: TIMEOUT), "The SF Symbol button does not exist.")
                    sfBtn.tap()
                    XCTAssertTrue(sfBtn.waitForNonExistence(timeout: TIMEOUT), "The SF Symbol button did not disappear.")
                    
                    // set the icon to plus
                    let iconPicker = app.buttons["PickSymbolBtn"]
                    XCTAssertTrue(iconPicker.waitForExistence(timeout: TIMEOUT), "The symbol picker button does not exist.")
                    iconPicker.tap()
                    let plusBtn = app.buttons["plus"]
                    XCTAssertTrue(plusBtn.waitForExistence(timeout: TIMEOUT), "The plus button does not exist.")
                    plusBtn.tap()
                    XCTAssertTrue(iconPicker.waitForExistence(timeout: TIMEOUT), "The icon picker did not appear.")
                    XCTAssertEqual(iconPicker.label, "plus", "Icon picker label was not updated to plus.")
                    
                    // set rotation
                    let rotBtn = app.buttons["EditorRotationBtn"]
                    editList.scrollToElement(rotBtn, upward: true, amt: -100)
                    XCTAssertTrue(rotBtn.waitForExistence(timeout: TIMEOUT), "Rotation edit button was not found.")
                    rotBtn.tap()
                    let rotField = app.textFields["0"]
                    guard rotField.waitForExistence(timeout: TIMEOUT) else {
                        XCTFail("Rotation field not found")
                        return
                    }
                    let rotAmt = "40"
                    rotField.typeText(rotAmt)
                    let doneButton = app.buttons["EditorDoneBtn"]
                    doneButton.tap()
                    XCTAssertTrue(doneButton.waitForNonExistence(timeout: TIMEOUT), "Done button did not disappear.")
                    XCTAssertEqual(rotBtn.label, "\(rotAmt).00º", "Rotation label is incorrect.")
                    
                    // set scale
                    let scaleBtn = app.buttons["EditorScaleBtn"]
                    XCTAssertTrue(scaleBtn.waitForExistence(timeout: TIMEOUT), "Scale edit button was not found.")
                    scaleBtn.tap()
                    let scaleField = app.textFields["1"]
                    XCTAssertTrue(scaleField.waitForExistence(timeout: TIMEOUT), "The scale text field was not found.")
                    scaleField.typeText(".5")
                    doneButton.tap()
                    XCTAssertTrue(doneButton.waitForNonExistence(timeout: TIMEOUT), "Done button did not disappear.")
                    XCTAssertEqual(scaleBtn.label, "1.50", "Scale label is incorrect.")
                } else if inp == "A" {
                    // set border thickness and text label
                    let iconField = app.textFields["Icon"]
                    editList.scrollToElement(iconField, upward: false, amt: -100)
                    iconField.tap()
                    let endCoord = iconField.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
                    endCoord.tap()
                    let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 100)
                    iconField.typeText(deleteString)
                    let newIcon = "Go"
                    iconField.typeText(newIcon)
                    XCTAssertTrue((iconField.value as? String ?? "").contains(newIcon), "Icon text field did not update correctly.")
                    
                    // set border
                    let thicknessSlider = app.sliders["SliderStroke Thickness"]
                    editList.scrollToElement(thicknessSlider, upward: false)
                    thicknessSlider.adjust(toNormalizedSliderPosition: 1.0)
                    let thicknessBtn = app.buttons["EditorStroke ThicknessBtn"]
                    XCTAssertEqual(thicknessBtn.label, "15.00", "Thickness label was not properly updated.")
                } else if inp == "Middle" {
                    // delete the middle trigger
                    let deleteBtn = app.buttons["DeleteButtonBtn"]
                    editList.scrollToElement(deleteBtn, upward: false)
                    deleteBtn.tap()
                    let confirmDel = app.buttons["ConfirmDelete"]
                    XCTAssertTrue(confirmDel.waitForExistence(timeout: TIMEOUT), "The delete confirmation could not be found.")
                    confirmDel.tap()
                    XCTAssertTrue(confirmDel.waitForNonExistence(timeout: TIMEOUT), "The delete button did not disappear.")
                    XCTAssertFalse(button.exists, "The button did not properly delete.")
                    continue
                }
                counter += 1
                // tap to deselect button
                let deselCoord = mainEditorView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                deselCoord.tap()
            }
        }
        
        // rename the layout
        let renameBtn = app.buttons["RenameLayoutBtn"]
        XCTAssertTrue(renameBtn.exists, "The rename button does not exist.")
        renameBtn.tap()
        guard nameField.waitForExistence(timeout: TIMEOUT) else {
            XCTFail("Name field not found")
            return
        }
        let newName = "Editor UI Test 2"
        nameField.typeText(newName)
        XCTAssertEqual(nameField.value as? String, newName, "Layout name text field did not update correctly.")
        setButton.tap()
        
        // go back to the previous view
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // verify that the layout renamed
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: TIMEOUT), "The settings button does not exist.")
        settingsBtn.tap()
        XCTAssertTrue(controllerPicker.waitForExistence(timeout: TIMEOUT), "The controller picker does not exist.")
        XCTAssertEqual(controllerPicker.label, "Picker\(newName)", "Layout name did not update the controller picker.")
        controllerPicker.tap()
        XCTAssertTrue(app.buttons[newName].waitForExistence(timeout: TIMEOUT), "Layout name not found in the list.")
        app.buttons[newName].tap()
        XCTAssertTrue(settingsCloseBtn.waitForExistence(timeout: TIMEOUT), "The close settings button does not exist.")
        settingsCloseBtn.tap()
        
        // open the controller view and make sure the number of buttons is correct
        let controllerViewBtn = app.buttons["OpenControllerView"]
        guard controllerViewBtn.waitForExistence(timeout: TIMEOUT) else {
            XCTFail()
            return
        }
        controllerViewBtn.tap()
        XCTAssertTrue(app.buttons["ControllerButton"].waitForExistence(timeout: TIMEOUT))
        
        // make sure the count of the buttons is equal to the specified controller setup
        XCTAssertEqual(app.buttons.matching(identifier: "ControllerButton").count + app.buttons.matching(identifier: "DPadButton").count, counter, "Incorrect number of buttons.")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // reopen and delete the layout
        XCTAssertTrue(modifyLayoutView.waitForExistence(timeout: TIMEOUT), "No modify button was found.")
        modifyLayoutView.tap()
        let delLayout = app.buttons["DeleteLayoutBtn"]
        XCTAssertTrue(delLayout.waitForExistence(timeout: TIMEOUT), "The delete layout button could not be found.")
        delLayout.tap()
        let confDel = app.buttons["ConfirmDelete"]
        XCTAssertTrue(confDel.waitForExistence(timeout: TIMEOUT), "The delete alert could not be found.")
        confDel.tap()
        
        // verify that the layout was deleted
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: TIMEOUT), "The settings button does not exist.")
        settingsBtn.tap()
        XCTAssertTrue(controllerPicker.waitForExistence(timeout: TIMEOUT), "The controller picker does not exist.")
        XCTAssertNotEqual(controllerPicker.label, "Picker\(newName)", "Layout name was not removed from the controller picker.")
        controllerPicker.tap()
        XCTAssertFalse(app.buttons[newName].waitForExistence(timeout: TIMEOUT), "Layout name was found in the list.")
    }
    
    @MainActor
    func testEditorOrientationOverrides() throws {
        let app = XCUIApplication()
        app.launch()
        
        // start in portrait
        XCUIDevice.shared.orientation = .portrait
        
        // open settings
        let settingsBtn = app.buttons["SettingsGearButton"]
        guard settingsBtn.waitForExistence(timeout: TIMEOUT) else{
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        guard settingsCloseBtn.waitForExistence(timeout: TIMEOUT) else { XCTFail("Settings button close not found"); return }
        
        // clear all layouts
        let removeFiles = app.buttons["RemoveLayoutFiles"]
        removeFiles.tap()
        
        // create new layout
        let createLayout = app.buttons["CreateNewLayoutButton"]
        createLayout.tap()
        let nameField = app.textFields["Layout Name"]
        guard nameField.waitForExistence(timeout: TIMEOUT) else {
            XCTFail("Name field not found")
            return
        }
        let layoutName = "Editor Orientation Test"
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
        
        // unlock rotation
        let rotLockBtn = app.navigationBars.switches["RotationLock"]
        XCTAssertTrue(rotLockBtn.exists, "The rotation lock button does not exist")
        rotLockBtn.tap()
        
        // add a button
        let newButtonBtn = app.buttons["NewButtonBtn"]
        let addButtonBtn = app.buttons["AddButtonBtn"]
        XCTAssertTrue(newButtonBtn.waitForExistence(timeout: TIMEOUT), "The new button button was not found.")
        newButtonBtn.tap()
        XCTAssertTrue(addButtonBtn.waitForExistence(timeout: TIMEOUT), "The add button button doesn't exist.")
        addButtonBtn.tap()
        let button = app.otherElements["SelectedBtn"]
        XCTAssertTrue(button.waitForExistence(timeout: TIMEOUT), "The selected button was not found on screen.")
        // move it to the far left
        let startCoord = button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = mainEditorView.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.4))
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        // make sure the button is on screen
        XCTAssertTrue(button.exists, "The button no longer exists!")
        
        // rotate device and override orientation
        XCUIDevice.shared.orientation = .landscapeLeft
        let delayExpectation = XCTestExpectation()
        delayExpectation.isInverted = true
        XCTWaiter().wait(for: [delayExpectation], timeout: 3)
        XCTAssertGreaterThan(mainEditorView.frame.size.width, mainEditorView.frame.size.height, "The editor view did not rotate")
        let finalBtn = app.buttons["ControllerButton"]
        let overrideToggle = app.switches.element(matching: .switch, identifier: "OverrideOrientation")
        XCTAssertTrue(overrideToggle.waitForExistence(timeout: TIMEOUT), "Override toggle was not found")
        overrideToggle.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(overrideToggle.value as? String, "1", "The toggle was not set to true")
        
        // move button to right side
        let startCoord2 = button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord2 = mainEditorView.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.4))
        startCoord2.press(forDuration: 0.01, thenDragTo: endCoord2)
        // make sure the button is on screen
        XCTAssertTrue(button.exists, "The button no longer exists!")
        
        // save and exit
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCUIDevice.shared.orientation = .portrait
        
        // open up the main controller view
        let controllerViewBtn = app.buttons["OpenControllerView"]
        XCTAssertTrue(controllerViewBtn.waitForExistence(timeout: TIMEOUT), "The controller view button does not exist")
        controllerViewBtn.tap()
        
        // find the button
        XCTAssertTrue(finalBtn.waitForExistence(timeout: TIMEOUT), "The controller button could not be found")
        // make sure the button is on the correct side
        XCTAssertLessThan(finalBtn.frame.midX, mainEditorView.frame.midX, "The button is not on the left side of the screen")
        // rotate and make sure it is on the correct side again
        XCUIDevice.shared.orientation = .landscapeLeft
        let delayExpectation2 = XCTestExpectation()
        delayExpectation2.isInverted = true
        XCTWaiter().wait(for: [delayExpectation2], timeout: 3)
        XCTAssertGreaterThan(finalBtn.frame.midX, mainEditorView.frame.midX, "The button is not on the right side of the screen")
        
        // set back to portrait
        XCUIDevice.shared.orientation = .portrait
    }
}
