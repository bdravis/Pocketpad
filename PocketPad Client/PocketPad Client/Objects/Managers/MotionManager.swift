//
//  MotionManager.swift
//  PocketPad Client
//
//  Created by Bautista Tedin Fiorito on 3/15/25.
//

import Foundation
import CoreMotion // framework to acces motion data
import Combine // we needed to automaticcly update swifdt ui views

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var pitch: Double = 0.0 // pitch will automatically refresh any swiftuo view observing motion manager

    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { //check if device can do motion control
            print("Device motion is not available on this device.")
            return
        }
        
  
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 //get updates 60 times per second
        
 
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in //tells the motion manager to start sending updates to a closure on the main thread
 
        if let error = error {
            print("Motion update error: \(error)")
            return
        }
            

        if let data = motionData { // If motion data is successfully received, we parse it
            //gets device’s pitch, roll, and yaw, this automatically updates SwiftUI views due to @Published
            let pitchVal = data.attitude.pitch
            let rollVal  = data.attitude.roll
            let yawVal   = data.attitude.yaw
            self?.pitch = pitchVal
            self?.roll  = rollVal
            self?.yaw   = yawVal
            // Print values to the console
            print(String(format: "Motion updated → Pitch: %.2f, Roll: %.2f, Yaw: %.2f",
                         pitchVal, rollVal, yawVal))
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
