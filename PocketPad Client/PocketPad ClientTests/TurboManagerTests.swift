//
//  TurboManagerTests.swift
//  PocketPad Client
//
//  Created by Jack Fang on 4/4/25.
//

import XCTest
import Combine
@testable import PocketPad_Client

final class TurboManagerTests: XCTestCase {
    var turboManager: TurboManager! // Implicitly unwrapped optional due to timeframe of initialization of class
    var mockBluetoothManager: MockBluetoothManager!
    var cancellables: Set<AnyCancellable> = [] // Standard practice to handle subscriptions, if any
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Fresh objects
        mockBluetoothManager = MockBluetoothManager()
        turboManager = TurboManager(bluetoothManager: mockBluetoothManager) // injection

        turboManager.setTurboRate(20.0) // For consistency
        turboManager.deactivateTurboMode()
        cancellables = [] // Set to empty array to reset
    }

    override func tearDownWithError() throws {
        turboManager = nil
        mockBluetoothManager = nil
        cancellables = []
        try super.tearDownWithError()
    }

    // MARK: - Test Cases
    
    // Basic test for activating and deactivating turbo mode
    func testActivateAndDeactivateTurboMode() {
        XCTAssertFalse(turboManager.turboActive) // Turbo mode should start out as not active
        
        turboManager.activateTurboMode() // Simulates holding down the turbo button
        XCTAssertTrue(turboManager.turboActive) // Should now be active
        
        turboManager.deactivateTurboMode() // Simulates releaeasing the turbo button
        XCTAssertFalse(turboManager.turboActive) // Should now not be active
    }
    
    func testToggleTurbo_EnablesButton() {
        let buttonInput = ButtonInput.A // Arbitrary button input
        XCTAssertFalse(turboManager.isTurboEnabled(buttonInput)) // Button should start out not being turbo-enabled
                      
        turboManager.activateTurboMode() // Simulates holding down turbo button
        mockBluetoothManager.sendInputCalled = false
        turboManager.toggleTurboForButton(buttonInput) // Simulates pressing a button while turbo mode is active
        
        XCTAssertTrue(turboManager.isTurboEnabled(buttonInput)) //  Button should now be turbo-enabled
        XCTAssertFalse(mockBluetoothManager.sendInputCalled) // There should be no input sending when toggling
        
        turboManager.deactivateTurboMode() // Release turbo button
        XCTAssertTrue(turboManager.isTurboEnabled(buttonInput)) // The turbo-enabled button should remain turbo-enabled
    }

    func testToggleTurbo_DisablesButton() {
        // Setup from testToggleTurbo_EnablesButton
        let buttonInput = ButtonInput.A // Arbitrary button input
        turboManager.activateTurboMode() // Simulates holding down turbo button
        turboManager.toggleTurboForButton(buttonInput) // Simulates pressing a button while turbo mode is active
        
        XCTAssertTrue(turboManager.isTurboEnabled(buttonInput)) // Precondition: Button is turbo-enabled
        
        mockBluetoothManager.sendInputCalled = false
        turboManager.toggleTurboForButton(buttonInput) // Toggle again to disable
        XCTAssertFalse(turboManager.isTurboEnabled(buttonInput)) // The button should no longer be turbo-enabled
        XCTAssertFalse(mockBluetoothManager.sendInputCalled) // There should be no input sending when toggling
    }
}
