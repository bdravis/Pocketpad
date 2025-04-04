//
//  TurboManager.swift
//  PocketPad Client
//
//  Created by Jack Fang on 3/30/25.
//

import Foundation
import Combine

class TurboManager : ObservableObject {
    static let shared = TurboManager()
    
    @Published var turboActive: Bool = false // true iff turbo button is behind held
    @Published var turboRate: Double = 10.0 // number of presses per second
    let MAX_TURBO_RATE: Double = 30.0 // maximum turbo rate in number of presses per second (Value 30.0 used for UI tests)
    
    private var turboEnabledButtons: Set<ButtonInput> = [] // List of all turbo enabled buttons, regardless of whether they are held
    private var turboTimers: [ButtonInput: Timer] = [:]  // A turbo enabled button has a timer iff it is being held
    // Having no held buttons implies that turboTimers is empty
    
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
    
    // Turbo mode is activated iff the turbo button is being held
    func activateTurboMode() {
        turboActive = true
    }
    func deactivateTurboMode() {
        turboActive = false
    }
    
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
    func isTurboEnabled(_ input: ButtonInput) -> Bool {
        return turboEnabledButtons.contains(input)
    }
    
    // Precondition: turbo mode is not activated
    // Precondition: button is turbo-enabled
    // Precondition: button is being held down
    // When the button is being held down, perform the turbo repetitive action using timers
    // This function involves sending data repeatedly
    func startTurboForButton(_ input: ButtonInput, playerId: UInt8, inputId: UInt8, buttonType: UInt8) {
        // close existing timers for this button
        stopTurboForButton(input)
        
        var isPressed = false // temp variable to store the state of the button
        // value is false so that the first toggle will make the first event send be 'press'
        
        turboTimers[input] = Timer.scheduledTimer(withTimeInterval: 0.5 / turboRate, repeats: true) { [weak self] _ in
            // Prevent retain cycles
            // Unwraps self after capturing it weakly
            guard let self else { return }
            
            // Toggle event
            let ui8_event: UInt8 = isPressed ? ButtonEvent.pressed.rawValue : ButtonEvent.released.rawValue
            isPressed.toggle()
            
            // Send data
#if DEBUG
            print(#"TURBO-ENABLED REGULAR BUTTON \#(isPressed ? "PRESS" : "RELEASE")"#)
#endif
            let data = Data([playerId, inputId, buttonType, ui8_event])
            BluetoothManager.shared.sendInput(data)
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
    
}
