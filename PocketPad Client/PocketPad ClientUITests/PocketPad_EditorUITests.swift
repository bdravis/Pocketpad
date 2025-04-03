//
//  PocketPad_EditorUITests.swift
//  PocketPad Client
//
//  Created by lemin on 4/3/25.
//

import XCTest

final class PocketPad_EditorUITests: XCTestCase {
    
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
        guard settingsBtn.waitForExistence(timeout: 3) else{
            XCTFail("Settings button open not found")
            return
        }
        settingsBtn.tap()
        let settingsCloseBtn = app.buttons["SettingsCloseButton"]
        guard settingsCloseBtn.waitForExistence(timeout: 3) else { XCTFail("Settings button close not found"); return }
        
        // clear all layouts
        let removeFiles = app.buttons["RemoveLayoutFiles"]
        app.scrollViews["SettingsScrollView"].scrollToElement(removeFiles, upward: false)
        removeFiles.tap()
        
        // create new layout
        let createLayout = app.buttons["CreateNewLayoutButton"]
        app.scrollViews["SettingsScrollView"].scrollToElement(createLayout, upward: true)
        createLayout.tap()
        let nameField = app.textFields["Layout Name"]
        guard nameField.waitForExistence(timeout: 3) else {
            XCTFail("Name field not found")
            return
        }
        let layoutName = "Editor UI Test"
        nameField.typeText(layoutName)
        XCTAssertEqual(nameField.value as? String, layoutName, "Layout name text field did not update correctly.")
        let setButton = app.alerts.buttons["LayoutNameOK"]
        setButton.tap()
        XCTAssertTrue(setButton.waitForNonExistence(timeout: 3), "Ok button did not disappear.")
        
        // verify the name in the controller input
        let controllerPicker = app.buttons["ControllerPicker"]
        app.scrollViews["SettingsScrollView"].scrollToElement(controllerPicker, upward: true)
        XCTAssertEqual(controllerPicker.label, "Picker\(layoutName)", "Layout name did not update the controller picker.")
        controllerPicker.tap()
        let nameInList = app.buttons[layoutName]
        XCTAssertTrue(nameInList.waitForExistence(timeout: 3), "Layout name not found in the list.")
        nameInList.tap()
        
        // test duplicate names
        createLayout.tap()
        guard nameField.waitForExistence(timeout: 3) else {
            XCTFail("Name field not found")
            return
        }
        nameField.typeText(layoutName)
        XCTAssertEqual(nameField.value as? String, layoutName, "Layout name text field did not update correctly.")
        setButton.tap()
        
        // verify that the error message appeared
        let alertDismiss = app.alerts.element.buttons["AlertCancel"]
        XCTAssertTrue(alertDismiss.waitForExistence(timeout: 4))
        XCTAssertTrue(app.alerts.element.staticTexts["A layout with that name already exists."].exists, "The error message wasn't properly shown!")
        alertDismiss.tap()
        
        // open up the editor
        guard settingsCloseBtn.waitForExistence(timeout: 4) else { XCTFail("Settings button close not found"); return }
        settingsCloseBtn.tap()
        let modifyLayoutView = app.buttons["ModifyLayoutView"]
        XCTAssertTrue(modifyLayoutView.waitForExistence(timeout: 3), "No modify button was found.")
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
        XCTAssertTrue(mainEditorView.waitForExistence(timeout: 4), "The main controller screen could not be found.")
        var counter = 0
        for (btnType, inputs) in typesToAdd {
            for (inp, pos) in inputs {
                XCTAssertTrue(newButtonBtn.waitForExistence(timeout: 4), "The new button button was not found.")
                newButtonBtn.tap()
                XCTAssertTrue(btnTypeBtn.waitForExistence(timeout: 4), "The button type button was not found.")
                btnTypeBtn.tap()
                let choice = app.buttons[btnType]
                XCTAssertTrue(choice.waitForExistence(timeout: 4), "Button type option for \(btnType) does not exist.")
                choice.tap()
                if inp != "None" {
                    if btnType == "Trigger" {
                        // set the trigger side
                        let sideBtn = app.buttons[inp]
                        XCTAssertTrue(sideBtn.waitForExistence(timeout: 4), "The side button for \(inp) does not exist.")
                        sideBtn.tap()
                    } else {
                        // select the input
                        let inpBtn = app.buttons["ButtonInputPicker"]
                        XCTAssertTrue(inpBtn.waitForExistence(timeout: 4), "The input picker button does not exist.")
                        inpBtn.tap()
                        let inpChoice = app.buttons[inp]
                        XCTAssertTrue(inpChoice.waitForExistence(timeout: 4), "The button for input \(inp) does not exist.")
                        inpChoice.tap()
                    }
                }
                XCTAssertTrue(addButtonBtn.waitForExistence(timeout: 4), "The add button button doesn't exist.")
                addButtonBtn.tap()
                let button = app.otherElements["SelectedBtn"]
                XCTAssertTrue(button.waitForExistence(timeout: 4), "The selected button was not found on screen.")
                
                // drag the button to the position
                if inp != "Middle" {
                    let startCoord = button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                    let endCoord = mainEditorView.coordinate(withNormalizedOffset: CGVector(dx: pos.x, dy: pos.y))
                    startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
                }
                // make sure the button is on screen
                XCTAssertTrue(button.exists, "The button no longer exists!")
                
                // configure certain properties for certain elements
                if inp == "Start" {
                    // turn it into a pill, set to plus symbol, and rotate 40º
                    let shapePicker = app.buttons["ButtonShapePicker"]
                    XCTAssertTrue(shapePicker.exists, "The button shape picker does not exist.")
                    shapePicker.tap()
                    let pillShape = app.buttons["Pill"]
                    XCTAssertTrue(pillShape.waitForExistence(timeout: 4), "The pill shape choice could not be found.")
                    pillShape.tap()
                    XCTAssertTrue(pillShape.waitForNonExistence(timeout: 4), "The pill shape choice did not disappear.")
                    
                    // set icon type to sf symbol
                    let editList = app.otherElements["EditBtnList"]
                    let iconTypePicker = app.buttons["IconTypePicker"]
                    editList.scrollToElement(iconTypePicker, upward: false, amt: -100)
                    iconTypePicker.tap()
                    let sfBtn = app.buttons["SF Symbol"]
                    XCTAssertTrue(sfBtn.waitForExistence(timeout: 4), "The SF Symbol button does not exist.")
                    sfBtn.tap()
                    XCTAssertTrue(sfBtn.waitForNonExistence(timeout: 4), "The SF Symbol button did not disappear.")
                    
                    // set the icon to plus
                    let iconPicker = app.buttons["PickSymbolBtn"]
                    XCTAssertTrue(iconPicker.waitForExistence(timeout: 3), "The symbol picker button does not exist.")
                    iconPicker.tap()
                    let plusBtn = app.buttons["plus"]
                    XCTAssertTrue(plusBtn.waitForExistence(timeout: 4), "The plus button does not exist.")
                    plusBtn.tap()
                    XCTAssertTrue(iconPicker.waitForExistence(timeout: 4), "The icon picker did not appear.")
                    XCTAssertEqual(iconPicker.label, "plus", "Icon picker label was not updated to plus.")
                    
                    // set rotation
                    let rotBtn = app.buttons["EditorRotationBtn"]
                    editList.scrollToElement(rotBtn, upward: true)
                    XCTAssertTrue(rotBtn.waitForExistence(timeout: 4), "Rotation edit button was not found.")
                    rotBtn.tap()
                    let rotField = app.textFields["0"]
                    guard rotField.waitForExistence(timeout: 3) else {
                        XCTFail("Rotation field not found")
                        return
                    }
                    let rotAmt = "40"
                    rotField.typeText(rotAmt)
                    let doneButton = app.buttons["EditorDoneBtn"]
                    doneButton.tap()
                    XCTAssertTrue(doneButton.waitForNonExistence(timeout: 3), "Done button did not disappear.")
                    XCTAssertEqual(rotBtn.label, "\(rotAmt).00º", "Rotation label is incorrect.")
                    
                    // set scale
                    let scaleBtn = app.buttons["EditorScaleBtn"]
                    XCTAssertTrue(scaleBtn.waitForExistence(timeout: 4), "Scale edit button was not found.")
                    scaleBtn.tap()
                    let scaleField = app.textFields["1"]
                    XCTAssertTrue(scaleField.waitForExistence(timeout: 3), "The scale text field was not found.")
                    scaleField.typeText(".5")
                    doneButton.tap()
                    XCTAssertTrue(doneButton.waitForNonExistence(timeout: 3), "Done button did not disappear.")
                    XCTAssertEqual(scaleBtn.label, "1.50", "Scale label is incorrect.")
                } else if inp == "Middle" {
                    // delete the middle trigger
                    let deleteBtn = app.buttons["DeleteButtonBtn"]
                    app.groups["EditBtnList"].scrollToElement(deleteBtn, upward: false)
                    deleteBtn.tap()
                    let confirmDel = app.buttons["ConfirmDelete"]
                    XCTAssertTrue(confirmDel.waitForExistence(timeout: 4), "The delete confirmation could not be found.")
                    confirmDel.tap()
                    XCTAssertTrue(confirmDel.waitForNonExistence(timeout: 4), "The delete button did not disappear.")
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
        guard nameField.waitForExistence(timeout: 3) else {
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
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: 3), "The settings button does not exist.")
        settingsBtn.tap()
        XCTAssertTrue(controllerPicker.waitForExistence(timeout: 4), "The controller picker does not exist.")
        XCTAssertEqual(controllerPicker.label, "Picker\(newName)", "Layout name did not update the controller picker.")
        controllerPicker.tap()
        XCTAssertTrue(app.buttons[newName].waitForExistence(timeout: 3), "Layout name not found in the list.")
        app.buttons[newName].tap()
        XCTAssertTrue(settingsCloseBtn.waitForExistence(timeout: 3), "The close settings button does not exist.")
        settingsCloseBtn.tap()
        
        // open the controller view and make sure the number of buttons is correct
        let controllerViewBtn = app.buttons["OpenControllerView"]
        guard controllerViewBtn.waitForExistence(timeout: 2) else {
            XCTFail()
            return
        }
        controllerViewBtn.tap()
        XCTAssertTrue(app.buttons["ControllerButton"].waitForExistence(timeout: 2))
        
        // make sure the count of the buttons is equal to the specified controller setup
        XCTAssertEqual(app.buttons.matching(identifier: "ControllerButton").count + app.buttons.matching(identifier: "DPadButton").count, counter, "Incorrect number of buttons.")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // reopen and delete the layout
        XCTAssertTrue(modifyLayoutView.waitForExistence(timeout: 3), "No modify button was found.")
        modifyLayoutView.tap()
        let delLayout = app.buttons["DeleteLayoutBtn"]
        XCTAssertTrue(delLayout.waitForExistence(timeout: 4), "The delete layout button could not be found.")
        delLayout.tap()
        let confDel = app.buttons["ConfirmDelete"]
        XCTAssertTrue(confDel.waitForExistence(timeout: 4), "The delete alert could not be found.")
        confDel.tap()
        
        // verify that the layout was deleted
        XCTAssertTrue(settingsBtn.waitForExistence(timeout: 3), "The settings button does not exist.")
        settingsBtn.tap()
        XCTAssertTrue(controllerPicker.waitForExistence(timeout: 4), "The controller picker does not exist.")
        XCTAssertNotEqual(controllerPicker.label, "Picker\(newName)", "Layout name was not removed from the controller picker.")
        controllerPicker.tap()
        XCTAssertFalse(app.buttons[newName].waitForExistence(timeout: 3), "Layout name was found in the list.")
    }
}
