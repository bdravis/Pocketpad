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
    @Published var turboRate: Double {
        didSet {
            UserDefaults.standard.set(turboRate, forKey: "turboRate")
        }
    }
    
    private var turboEnabledButtons: Set<String> = [] // List of all turbo enabled buttons, regardless of whether they are held
    private var turboTimers: [String: Timer] = [:]  // A turbo enabled button has a timer iff it is being held
    // Having no held buttons implies that turboTimers is empty
    
    init() {
        // Save the turbo rate to user defaults
        self.turboRate = UserDefaults.standard.double(forKey: "turboRate")
        if self.turboRate <= 0.0 {
            self.turboRate = 10.0 // Default is 10 presses a second
        }
    }
    
    // Turbo mode is activated iff the turbo button is being held
    func activateTurboMode() {
        turboActive = true;
    }
    func deactivateTurboMode() {
        turboActive = false;
    }
    
    // Given a button, enable or disable its turbo state
    // Assumes turbo mode is currently activated
    func toggleTurboForButton(_ input: String) {
        if turboEnabledButtons.contains(input) {
            turboEnabledButtons.remove(input)
            stopTurboForButton(input)
        } else {
            turboEnabledButtons.insert(input)
        }
    }
    
    // Given a button, check it is turbo-enabled {
    func isTurboEnabled(_ input: String) -> Bool {
        return turboEnabledButtons.contains(input)
    }
    
    // Assumes turbo enabled button
    // When the button is being held down, perform the turbo repetitive action using timers
    // This function involves sending data repeatedly
    func startTurboForButton(input: String, inputId: UInt8, buttonType: UInt8, playerId: UInt8) {
        // close existing timers for this button
        stopTurboForButton(input)
        
        var isPressed = true // temp variable to store the state of the button
        
        turboTimers[input] = Timer.scheduledTimer(withTimeInterval: 0.5 / turboRate, repeats: true) { [weak self] _ in
            // Prevent retain cycles
            // Unwraps self after capturing it weakly
            guard let self else { return }
            
            // Toggle event
            let ui8_event: UInt8 = isPressed ? ButtonEvent.pressed.rawValue : ButtonEvent.released.rawValue
            
            // Send data
            let data = Data([playerId, inputId, buttonType, ui8_event])
            BluetoothManager.shared.sendInput(data)
            
            isPressed.toggle()
        }
    }
    
    // Destroys timer object for a button and removes it from the dict turboTimers
    func stopTurboForButton(_ input: String) {
        // destroy the timer objects
        turboTimers[input]?.invalidate()
        turboTimers.removeValue(forKey: input)
    }
    
    // stops the turbo timer objects for all buttons
    func stopAllTurbo() {
        for timer in turboTimers.values {
            timer.invalidate()
        }
        turboTimers.removeAll()
    }
    
}
