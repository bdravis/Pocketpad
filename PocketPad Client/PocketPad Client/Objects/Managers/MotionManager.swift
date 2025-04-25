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
    @Published var accelerationX: Double = 0.0
    @Published var accelerationY: Double = 0.0
    @Published var accelerationZ: Double = 0.0

    func startUpdates() {
        // Check if the device supports motion control
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available on this device.")
            return
        }
        
        // Set the update interval to 6 times per second
        motionManager.deviceMotionUpdateInterval = 1.0 / 10.0
        
        // Start device motion updates on the main thread
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
            if let error = error {
                print("Motion update error: \(error)")
                return
            }
            
            if let data = motionData {  // Parse motion data if received successfully
                let pitchVal = data.rotationRate.x
                let rollVal  = data.rotationRate.y
                let yawVal   = data.rotationRate.z
                /*
                let pitchVal = data.attitude.pitch
                let rollVal  = data.attitude.yaw
                let yawVal   = data.attitude.roll
                */
                let xVal = data.userAcceleration.x + data.gravity.x
                let yVal = data.userAcceleration.y + data.gravity.y
                let zVal = data.userAcceleration.z + data.gravity.z
                
                // Update published properties (automatically updates SwiftUI views)
                /*
                self?.pitch = pitchVal
                self?.roll  = rollVal
                self?.yaw   = yawVal
                self?.accelerationX = xVal
                self?.accelerationY = yVal
                self?.accelerationZ = zVal
                 */
                
                // Print the motion data for debugging
                print(String(format: "Motion updated → Pitch: %.2f, Roll: %.2f, Yaw: %.2f\nAcceleration -> X: %.2f, Y: %.2f, Z: %.2f",
                             pitchVal, rollVal, yawVal, xVal, yVal, zVal))
                
                // Send the motion data to the server
                BluetoothManager.shared.sendMotionData(
                    playerId: LayoutManager.shared.player_id,
                    pitch: Float(pitchVal),
                    roll:  Float(rollVal),
                    yaw:   Float(yawVal),
                    xAcceleration: Float(xVal),
                    yAcceleration: Float(yVal),
                    zAcceleration: Float(zVal)
                )
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
