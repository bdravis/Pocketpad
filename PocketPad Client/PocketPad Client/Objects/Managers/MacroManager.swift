//
//  MacroManager.swift
//  PocketPad Client
//
//  Created by Jack Fang on 4/18/25.
//

import Foundation
import SwiftUI

class MacroManager : ObservableObject {
    // MARK: Variables
    static let shared = MacroManager()
    @Published var isRecording: Bool = false // True if 'Record' Button has been pressed
    
    // Variables to allow capturing of user inputs for macros
    private struct TimeStampedInput {
        var input: Data
        var timestamp: Date
    }
    private var currentMacro : [TimeStampedInput] = [] // An array of captured inputs during the current macro recording
    
    // A macro is essentially an array of timestamped inputs (TimeStampedInput)
    @Published private var macrosByName: [String : [TimeStampedInput]] = [:] // Device database of macros (id: name), persistent across controllers
    @Published private var macroNamesByButton: [ButtonInput : String] = [:] // Macro-assigned buttons for current controller (not persistent)
    
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
    
    // While recording is on, capture every controller input into a temporary array
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
    
    // MARK: Functions for saving, fetching, and deleting macros
    
    // Save the current macro with a specified name
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
    
    // Deletes the macro with the specified name from the current device
    // Buttons already assigned to this macro will still have this macro
    func deleteMacro(named macroName: String) {
        macrosByName[macroName] = nil
    }
    
    // Deletes the macro-to-button assignments on the current controller
    func clearMacrosForController() {
        macroNamesByButton = [:]
    }
    
    // MARK: Functions to assign/unassign macros to buttons
    
    // If the button has a macro already, this will override it with the new macro
    func assignMacro(named macroName: String, to buttonInput: ButtonInput) {
        macroNamesByButton[buttonInput] = macroName
    }
    
    func unassignMacro(from buttonInput: ButtonInput) {
        macroNamesByButton[buttonInput] = nil
    }
    
    // Returns the name (optional) of the macro associated with the specified button
    // Returns nil if no macro has been assigned
    func getNameOfMacro(for buttonInput: ButtonInput) -> String? {
        return macroNamesByButton[buttonInput]
    }
    
    // MARK: Functions to check macro existence and execute macros
    
    // Checks if there is a macro associated with the specified button
    // May also execute the macro
    // Returns false if there is no macro associated with the specified button, or if error occurs
    private func hasMacro(for buttonInput: ButtonInput, willExecute: Bool, isInMacroEditor: Bool = false) -> Bool {
        if let macroName = macroNamesByButton[buttonInput] { // Check if macro exists
            if willExecute {
                // Actually execute the macro
                if macrosByName[macroName] == nil { // Error checking to not crash the app, theoretically should never be true
#if DEBUG
                    print("Macro \(macroName) not found. This error should not have occured.")
#endif
                    return false
                }
                Task {
                    await executeMacro(macro: macrosByName[macroName]!, isInMacroEditor: isInMacroEditor)
                }
            }
            return true
        }
        return false // Tell the caller to send a normal button input instead
    }
    
    // Takes a macro (known to exist) and executes it
    private func executeMacro(macro: [TimeStampedInput], isInMacroEditor: Bool) async {
#if DEBUG
        print("Executing Macro")
#endif
        if macro.isEmpty {
            return
        }
        
        let macro = macro.sorted { $0.timestamp < $1.timestamp }
        
        // Evaluate first input
        Task { sendControllerInput(macro[0].input, isInMacroEditor: isInMacroEditor) }
        
        let numInputs: Int = macro.count
        for i in 0..<(numInputs - 1) {
            let currentTSInput: TimeStampedInput = macro[i]
            let nextTSInput: TimeStampedInput = macro[i + 1]
            let timeToNextInput: TimeInterval = max(0, nextTSInput.timestamp.timeIntervalSince(currentTSInput.timestamp))
            
            do {
                try await Task.sleep(for: .seconds(timeToNextInput)) // wait until the next timestamp
                Task { sendControllerInput(nextTSInput.input, isInMacroEditor: isInMacroEditor) } // evaluate this next input
            } catch {
#if DEBUG
                print("Task interrupted")
#endif
                return
            }
        }
    }
    
    // MARK: Functions to filter inputs through macro
    // These controller inputs have already been filtered through turbo
    // Now the client must determine whether to execute it as a macro or send the input normally
    
    func handleButtonPressThroughMacro(buttonInput: ButtonInput, sendButtonPressFunc: () -> (), isInMacroEditor: Bool) {
        // Check if the button has a macro, if it does then execute it
        if !hasMacro(for: buttonInput, willExecute: true, isInMacroEditor: isInMacroEditor) {
            // If button is not assigned a macro, then send over the button input normally
            sendButtonPressFunc()
        }
    }
    
    func handleButtonReleaseThroughMacro(buttonInput: ButtonInput, sendButtonReleaseFunc: () -> ()) {
        // Check if the button has a macro
        if !hasMacro(for: buttonInput, willExecute: false) {
            // If button is not assigned a macro, then send over the button input normally
            sendButtonReleaseFunc()
        }
    }
    
}
