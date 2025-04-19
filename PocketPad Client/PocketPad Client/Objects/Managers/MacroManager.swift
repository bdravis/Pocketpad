//
//  MacroManager.swift
//  PocketPad Client
//
//  Created by Jack Fang on 4/18/25.
//

import Foundation

class MacroManager : ObservableObject {
    // MARK: Variables
    static let shared = MacroManager()
    private var isRecording: Bool = false // True if 'Record' Button has been pressed
    
    // Variables to allow capturing of user inputs for macros
    private struct TimeStampedInput {
        var input: Data
        var timestamp: Date
    }
    private var currentMacro : [TimeStampedInput] = [] // An array of captured inputs during the current macro recording
    
    // Macro variables
    // A macro is essentially an array of timestamped inputs (TimeStampedInput)
    private var macrosByButton: [ButtonInput : [TimeStampedInput]] = [:] // Macro-assigned buttons for current controller (not persistent)
    private var macrosByName: [String : [TimeStampedInput]] = [:] // Used for displaying list of macros + assigning macros to buttons
    
    // MARK: Functions for recording and capturing inputs
    // Allow inputs to be recorded for the new macro
    func startRecording() {
        currentMacro = [] // To ensure clean slate
        isRecording = true
    }
    
    // Inputs can no longer be recorded for the macro
    func stopRecording() {
        isRecording = false
    }
    
    // While recording is on, capture every controller input into the currentInputsReceived array
    func sendInput(_ data: Data, timestamp: Date) {
        if isRecording {
#if DEBUG
            print("Recording currently")
#endif
            currentMacro.append(TimeStampedInput(input: data, timestamp: timestamp))
        } else {
#if DEBUG
            print("Not recording currently")
#endif
        }
    }
    
    // MARK: Functions to save and fetch macros
    // A button will stop the recording, and there will be a popup asking user to save the macro with a name
    // Returns false if there already exists a macro with the specified name (macros must have unique names)
    func saveCurrentMacro(as macroName: String) -> Bool {
        if macrosByName[macroName] != nil { // A macro with this name already exists
            return false
        }

        macrosByName[macroName] = currentMacro // Save the new macro
        return true
    }
    
    // Fetches all the names of the macros into an array of Strings for display
    func getMacroNames() -> [String] {
        return [String] (macrosByName.keys)
    }
    
    // MARK: Functions to check macro existence and execute macros
    // Checks if there is a macro associated with the specified button
    // May also execute the macro
    private func hasMacro(for buttonInput: ButtonInput, willExecute: Bool) -> Bool {
        if let macro = macrosByButton[buttonInput] { // Check if macro exists
            if willExecute {
                executeMacro(macro: macro) // Actually execute the macro
            }
            return true
            
        }
        return false // tell the caller to send a regular button input to the server instead
    }
    
    // Takes a macro (known to exist) and executes it
    private func executeMacro(macro: [TimeStampedInput]) {
#if DEBUG
            print("TBD Executing Macro")
#endif
    }
    
    // MARK: Functions to filter inputs through macro
    func handleButtonPressThroughMacro(buttonInput: ButtonInput, sendButtonFunc: () -> ()) {
        // check if the button has a macro, if it does then execute it
        if !hasMacro(for: buttonInput, willExecute: true) {
            // if button is not assigned a macro, then send over the button input normally
            sendButtonFunc()
        }
    }
    func handleButtonReleaseThroughMacro(buttonInput: ButtonInput, releaseButtonFunc: () -> ()) {
        // check if the button has a macro
        if !hasMacro(for: buttonInput, willExecute: false) {
            releaseButtonFunc()
        }
    }
    
}
