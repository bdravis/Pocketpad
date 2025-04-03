//
//  DPadConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

// Directional input format
enum DPadDirection: UInt8, ConfigType {
    case up = 0
    case down = 1
    case left = 2
    case right = 3
}

struct DPadConfig: ButtonConfig, ConfigType {
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
    
    var inputs: [DPadDirection: ButtonInput] // what the buttons of the dpad are
    
    // Object Initializer
    init(
        position: ButtonPosition, scale: CGFloat, rotation: Double = 0.0,
        style: GeneralButtonStyle = .init(),
        inputId: UInt8, inputs: [DPadDirection: ButtonInput]
    ) {
        self.type = .dpad
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.style = style
        
        self.inputId = inputId
        
        self.inputs = inputs
    }
}
