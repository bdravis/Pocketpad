//
//  JoystickConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

struct JoystickConfig: ButtonConfig, ConfigType {
    mutating func updateStyle<T>(to newStyle: T) {
        if let newStyle = newStyle as? GeneralButtonStyle {
            self.style = newStyle
        }
    }
    
    // Protocol Properties
    var position: ButtonPosition
    var scale: CGFloat
    var rotation: Double
    var style: GeneralButtonStyle
    var type: ButtonType
    var inputId: UInt8
    
    var input: ButtonInput // which joystick button it will correlate to
    var sensitivity: Double // the sensitivity of the controller
    var deadzone: Double // how far it needs to move before it starts accepting inputs (decimal from 0 to 1)
    
    // Object Initializer
    init(
        position: ButtonPosition, scale: CGFloat, rotation: Double = 0.0,
        style: GeneralButtonStyle = .init(),
        inputId: UInt8, input: ButtonInput, sensitivity: Double = 0.0, deadzone: Double = 0.0
    ) {
        self.type = .joystick
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.style = style
        
        self.inputId = inputId
        
        self.input = input
        self.sensitivity = sensitivity
        self.deadzone = deadzone
    }
}
