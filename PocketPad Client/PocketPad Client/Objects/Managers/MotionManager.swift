//
//  MotionManager.swift
//  PocketPad Client
//
//  Created by Bautista Tedin Fiorito on 3/15/25.
//

import Foundation
import CoreMotion      // Framework to access motion data
import Combine         // Needed to automatically update SwiftUI views

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var pitch: Double = 0.0   // Pitch will automatically refresh any SwiftUI view observing this manager
    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0

    func startUpdates() {
        // Check if the device supports motion control
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available on this device.")
            return
        }
        
        // Set the update interval to 60 times per second
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        // Start device motion updates on the main thread
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
            if let error = error {
                print("Motion update error: \(error)")
                return
            }
            
            if let data = motionData {  // Parse motion data if received successfully
                let pitchVal = data.attitude.pitch
                let rollVal  = data.attitude.roll
                let yawVal   = data.attitude.yaw
                
                // Update published properties (automatically updates SwiftUI views)
                self?.pitch = pitchVal
                self?.roll  = rollVal
                self?.yaw   = yawVal
                
                // Print the motion data for debugging
                print(String(format: "Motion updated → Pitch: %.2f, Roll: %.2f, Yaw: %.2f",
                             pitchVal, rollVal, yawVal))
                
                // Send the motion data to the server
                BluetoothManager.shared.sendMotionData(
                    playerId: LayoutManager.shared.player_id,
                    pitch: Float(pitchVal),
                    roll:  Float(rollVal),
                    yaw:   Float(yawVal)
                )
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
