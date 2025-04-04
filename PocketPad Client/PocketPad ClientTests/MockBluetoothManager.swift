//
//  MockBluetoothManager.swift
//  PocketPad Client
//
//  Created by Jack Fang on 4/4/25.
//


import XCTest
import Combine
@testable import PocketPad_Client // Import your app module

// Simulates a bluetooth manager (for testing)
class MockBluetoothManager: BluetoothManaging {
    var sentData: [Data] = []
    var sendInputCalled: Bool = false

    func sendInput(_ data: Data) {
        sendInputCalled = true
        sentData.append(data)
        // Optional: Post notification for expectation fulfillment
        print("Mock BluetoothManager: Intercepted \(data.count) bytes")
        NotificationCenter.default.post(name: .mockBluetoothDidSendInput, object: data)
    }

    func reset() {
        sentData = []
        sendInputCalled = false
    }
}

// Notification name for expectations
extension Notification.Name {
    static let mockBluetoothDidSendInput = Notification.Name("mockBluetoothDidSendInput")
}
