//
//  JoystickConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

struct JoystickConfig: ButtonConfig, ConfigType {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    var inputId: UInt8
    
    var input: String // which joystick button it will correlate to
    var sensitivity: Double // the sensitivity of the controller
    var deadzone: Double // how far it needs to move before it starts accepting inputs
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat, inputId: UInt8,
        input: String, sensitivity: Double = 0.0, deadzone: Double = 0.0
    ) {
        self.type = .joystick
        
        self.position = position
        self.scale = scale
        
        self.inputId = inputId
        
        self.input = input
        self.sensitivity = sensitivity
        self.deadzone = deadzone
    }
}
