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
    
    @Published var turboActive: Bool = false;
    @Published var turboRate: Double { // Number of presses per second
        didSet { // this is a property observer
            UserDefaults.standard.set(turboRate, forKey: "turboRate")
            updateActiveTimers() // make the timers use this new turbo rate
        }
    }
    
    private var turboTimers: [String: Timer] = [:] // dict mapping inputs to timers
    
    init() {
        self.turboRate = UserDefaults.standard.double(forKey: "turboRate")
        if self.turboRate <= 0.0 {
            self.turboRate = 10.0 // Default is 10 presses a second
        }
    }
    
    // Functions for activating and deactivating turbo mode
    func activateTurboMode() {
        turboActive = true;
    }
    func deactivateTurboMode() {
        turboActive = false;
    }
    
    // Function to toggle turbo for a button given the button config
    func toggleTurbo(for button : inout RegularButtonConfig) {
        // turbo button itself cannot have turbo
        if (button.isTurboButton) {
            return;
        }
        
        button.turbo = !button.turbo
        if (!button.turbo) {
            stopTurbo(buttonInput: button.input)
        }
    }
    
    // Send the button inputs repeatedly using timers
    func startTurbo(buttonInput: String, inputId: UInt8, buttonType: UInt8, playerId: UInt8 = 0) {
        // close existing timers for this button
        stopTurbo(buttonInput: buttonInput)
        
        // Use timer system to toggle press and release of button
        var isPressed = true // temp variable to store the state of the button
        turboTimers[buttonInput] = Timer.scheduledTimer(withTimeInterval: 0.5 * turboRate, repeats: true) { [weak self] _ in
            // prevent retain cycles, but then unwrap self after capturing it weakly
            guard let self else { return }
            
            // toggle event
            let ui8_event: UInt8 = isPressed ? ButtonEvent.pressed.rawValue : ButtonEvent.released.rawValue
            // prepare data to send
            let data = Data([playerId, inputId, buttonType, ui8_event])
            // send data
            BluetoothManager.shared.sendInput(data)
            
            // actually toggle the state of the button
            isPressed.toggle()
        }
    }
    
    func stopTurbo(buttonInput: String) {
        turboTimers[buttonInput]?.invalidate()
        turboTimers[buttonInput] = nil
    }
    
    func stopAllTurbo() {
        for buttonInput in turboTimers.keys {
            turboTimers[buttonInput]?.invalidate()
            turboTimers[buttonInput] = nil
        }
        turboTimers.removeAll()
    }
    
    private func updateActiveTimers() {
        let activeTimers = Array(turboTimers.keys)
        for input in activeTimers {
            turboTimers[input]?.invalidate()
            turboTimers[input] = nil
        }
    }
    
}
