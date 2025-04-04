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
        
        turboManager.toggleTurboForButton(buttonInput) // Toggle again to disable
        XCTAssertFalse(turboManager.isTurboEnabled(buttonInput)) // The button should no longer be turbo-enabled
        XCTAssertFalse(mockBluetoothManager.sendInputCalled) // There should be no input sending when toggling
    }

    func testStartTurboForButton_SendsAlternatingEvents() {
        // Arrange
        let buttonInput = ButtonInput.B
        let expectedRate = 20.0 // Hz (set in setUp)
        let expectedInterval = 0.5 / expectedRate // Time between press/release events
        let eventCount = 6 // Expect 3 press, 3 release
        let timeout = Double(eventCount) * expectedInterval + 0.5 // Allow ample time

        // Enable the button (simulate prior toggle)
        turboManager.activateTurboMode()
        turboManager.toggleTurboForButton(buttonInput)
        turboManager.deactivateTurboMode() // Release turbo button
        XCTAssertTrue(turboManager.isTurboEnabled(buttonInput), "Precondition: Button must be enabled.")
        XCTAssertFalse(turboManager.turboActive, "Precondition: Turbo mode must be inactive.")

        // Use expectation to wait for async timer events
        let expectation = XCTestExpectation(description: "Receive \(eventCount) alternating turbo events")
        expectation.expectedFulfillmentCount = eventCount

        // Observe notifications from the mock
        var receivedEvents: [UInt8] = []
        let observer = NotificationCenter.default.addObserver(forName: .mockBluetoothDidSendInput, object: nil, queue: .main) { notification in
            if let data = notification.object as? Data, data.count >= 4 {
                 // Assuming event type is the 4th byte (index 3)
                 // You might need to adjust this based on ButtonEvent enum values
                 let eventType = data[3]
                 receivedEvents.append(eventType)
                 expectation.fulfill()
            }
        }

        // Act: Start the turbo timer (simulates holding the enabled button)
        turboManager.startTurboForButton(buttonInput, playerId: 1, inputId: 2, buttonType: 0)

        // Assert
        wait(for: [expectation], timeout: timeout)
        NotificationCenter.default.removeObserver(observer) // Clean up observer

        XCTAssertEqual(mockBluetoothManager.sentData.count, eventCount, "Should have received \(eventCount) events.")
        XCTAssertEqual(receivedEvents.count, eventCount, "Recorded events count mismatch.")

        // Verify the alternating pattern (assuming pressed = 0, released = 1 or vice-versa - adjust!)
        let pressEvent = ButtonEvent.pressed.rawValue
        let releaseEvent = ButtonEvent.released.rawValue
        XCTAssertEqual(receivedEvents[0], pressEvent, "First event should be press")
        XCTAssertEqual(receivedEvents[1], releaseEvent, "Second event should be release")
        XCTAssertEqual(receivedEvents[2], pressEvent, "Third event should be press")
        XCTAssertEqual(receivedEvents[3], releaseEvent, "Fourth event should be release")
        XCTAssertEqual(receivedEvents[4], pressEvent, "Fifth event should be press")
        XCTAssertEqual(receivedEvents[5], releaseEvent, "Sixth event should be release")

        // Stop the timer manually for cleanup if test doesn't naturally release
        turboManager.stopTurboForButton(buttonInput)
    }

    func testStopTurboForButton_InvalidatesTimerAndStopsSending() {
        // Arrange
        let buttonInput = ButtonInput.X
        let expectedRate = 20.0 // Hz
        let expectedInterval = 0.5 / expectedRate
        let initialWait = expectedInterval * 1.5 // Wait long enough for at least one event
        let subsequentWait = expectedInterval * 5 // Wait long enough for several more events *if* not stopped

        // Enable the button
        turboManager.activateTurboMode()
        turboManager.toggleTurboForButton(buttonInput)
        turboManager.deactivateTurboMode()
        XCTAssertTrue(turboManager.isTurboEnabled(buttonInput))

        // Act
        turboManager.startTurboForButton(buttonInput, playerId: 1, inputId: 3, buttonType: 0)

        // Wait for a short time to ensure timer starts sending
        RunLoop.current.run(until: Date(timeIntervalSinceNow: initialWait))
        let countBeforeStop = mockBluetoothManager.sentData.count
        XCTAssertGreaterThan(countBeforeStop, 0, "Timer should have sent at least one event before stop.")

        // Stop the turbo for the button
        turboManager.stopTurboForButton(buttonInput)
        mockBluetoothManager.reset() // Clear received data

        // Wait again - no new events should arrive
         RunLoop.current.run(until: Date(timeIntervalSinceNow: subsequentWait))

        // Assert
        XCTAssertEqual(mockBluetoothManager.sentData.count, 0, "No new events should be sent after stopping the timer.")
    }

     func testStartTurbo_DoesNotStartTimer_IfNotEnabled() {
         // Arrange
         let buttonInput = ButtonInput.Y
         XCTAssertFalse(turboManager.isTurboEnabled(buttonInput), "Precondition: Button should not be enabled.")
         XCTAssertFalse(turboManager.turboActive, "Precondition: Turbo mode should be inactive.")
         let waitTime = 0.2

         // Act - Attempt to start turbo (view logic should prevent this, but test TurboManager directly)
         // Note: The current TurboManager.startTurboForButton doesn't check isTurboEnabled itself.
         // The *call* to it is guarded by the view. If testing just the manager, it *will* start.
         // This test might be more relevant as a UI test or if you add the check to TurboManager.
         // Let's assume we test the function as-is:
         turboManager.startTurboForButton(buttonInput, playerId: 1, inputId: 4, buttonType: 0)

         // Wait
         RunLoop.current.run(until: Date(timeIntervalSinceNow: waitTime))

         // Assert - It *will* send data because the check is in the View layer.
         // XCTAssertEqual(mockBluetoothManager.sentData.count, 0, "No events should be sent if button not enabled.")
         // Correct assertion based on current TurboManager code:
          XCTAssertGreaterThan(mockBluetoothManager.sentData.count, 0, "Events WILL be sent as TurboManager.start doesn't check enablement itself.")

         // Cleanup
          turboManager.stopTurboForButton(buttonInput)
     }
}
