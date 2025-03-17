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
    // Protocol Properties
    var position: ButtonPosition
    var scale: CGFloat
    var rotation: Double
    var type: ButtonType
    var inputId: UInt8
    
    var inputs: [DPadDirection: String] // what the buttons of the dpad are
    
    // Object Initializer
    init(
        position: ButtonPosition, scale: CGFloat, rotation: Double, inputId: UInt8,
        inputs: [DPadDirection: String]
    ) {
        self.type = .dpad
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
        
        self.inputId = inputId
        
        self.inputs = inputs
    }
}
