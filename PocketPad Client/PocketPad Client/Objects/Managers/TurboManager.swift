//
//  TurboManager.swift
//  PocketPad Client
//
//  Created by Jack Fang on 3/30/25.
//

import Foundation
import Combine

class TurboManager : ObservableObject {
    // MARK: Variables
    static let shared = TurboManager()
    private var macroManager = MacroManager.shared
    
    private var turboActive: Bool = false // true iff turbo button is behind held
    @Published var turboRate: Double = 10.0 // number of presses per second
    
    private var turboEnabledButtons: Set<ButtonInput> = [] // List of all turbo enabled buttons, regardless of whether they are held
    private var turboTimers: [ButtonInput: Timer] = [:]  // A turbo enabled button has a timer iff it is being held
    // Having no held buttons implies that turboTimers is empty
    
    
    // MARK: Initialization function
    init() {
        // Save the turbo rate to user defaults
        self.turboRate = UserDefaults.standard.double(forKey: "turboRate")
        if self.turboRate <= 0.0 {
            self.turboRate = 10.0 // Default is 10 presses a second
        }
    }
    
    func setTurboRate(_ newTurboRate: Double) {
        turboRate = newTurboRate
        UserDefaults.standard.set(newTurboRate, forKey: "turboRate")
    }
    
    // MARK: Functions to activate and deactivate turbo mode
    // Turbo mode is activated iff the turbo button is being held
    func activateTurboMode() {
        turboActive = true
    }
    func deactivateTurboMode() {
        turboActive = false
    }
    
    // MARK: Functions regarding the turbo status of a button
    // Precondition: turbo mode is activated (turbo button is being held)
    // Precondition: a given button is pressed
    // Given a button, this function enables or disables its turbo state
    func toggleTurboForButton(_ input: ButtonInput) {
        if turboEnabledButtons.contains(input) {
#if DEBUG
                    print("BUTTON IS NOW TURBO-DISABLED")
#endif
            turboEnabledButtons.remove(input)
            stopTurboForButton(input) // as a defensive measure
        } else {
#if DEBUG
                    print("BUTTON IS NOW TURBO-ENABLED")
#endif
            turboEnabledButtons.insert(input)
        }
    }
    
    // Given a button, check it is turbo-enabled {
    private func isTurboEnabled(_ input: ButtonInput) -> Bool {
        return turboEnabledButtons.contains(input)
    }
    
    // MARK: Functions to start and stop turbo functionality
    // Precondition: turbo mode is not activated
    // Precondition: button is turbo-enabled
    // Precondition: button is being held down
    // When the button is being held down, perform the turbo repetitive action using timers
    // This function involves sending data repeatedly
    // Works for every type of button
    private func startTurboForButton(_ input: ButtonInput, buttonPressHandler: @escaping () -> (), buttonReleaseHandler: @escaping () -> ()) {
        // close existing timers for this button
        stopTurboForButton(input)
        
        var isPressed = true // temp variable to store the state of the button
        // value is false so that the first toggle will make the first event send be 'press'
        
        turboTimers[input] = Timer.scheduledTimer(withTimeInterval: 0.5 / turboRate, repeats: true) { [weak self] _ in
            // Prevent retain cycles
            // Unwraps self after capturing it weakly
            guard let self else { return }
            
            // Send data
            if isPressed {
                buttonPressHandler()
            } else {
                buttonReleaseHandler()
            }
            
            // Toggle button state
            isPressed.toggle()
        }
    }
    
    // Often called when a turbo-enabled button is released
    // Destroys the timer object for a button and removes it from the dict turboTimers
    func stopTurboForButton(_ input: ButtonInput) {
        // destroy the timer objects
        turboTimers[input]?.invalidate()
        turboTimers.removeValue(forKey: input)
    }
    
    // First stops the timers for all turbo-enabled buttons that are held
    // Then disables turbo mode for all turbo-enabled buttons
    func stopAllTurbo() {
        for timer in turboTimers.values {
            timer.invalidate()
        }
        turboTimers.removeAll()
        turboEnabledButtons.removeAll()
    }
    
    // MARK: Functions to filter inputs through turbo
    func handleButtonPressThroughTurbo(config: ButtonConfig, sendButtonFunc: () -> (), releaseButtonFunc: () -> ()) {
        if config.turbo { // if this button is the turbo button itself
            activateTurboMode()
        } else if turboActive { // turbo button is being held and then another button is pressed
            toggleTurboForButton(config.input)
        } else if isTurboEnabled(config.input) { // while turbo is not being held, a turbo-enabled button is held
            startTurboForButton( // start firing inputs
                config.input,
                buttonPressHandler: handleRegularButtonPress,
                buttonReleaseHandler: handleRegularButtonRelease
            )
        } else { // turbo button is not being held, button is not turbo-enabled
            // this case is a simple button press/hold
            handleRegularButtonPress()
        }
    }
    
    func handleButtonReleaseThroughTurbo(config: ButtonConfig, releaseButtonFunc: () -> ()) {
       
    }
    
}
