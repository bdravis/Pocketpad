//
//  DPadConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

// Directional input format
enum DPadDirection: UInt8, Codable {
    case up = 0
    case down = 1
    case left = 2
    case right = 3
}

struct DPadConfig: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    var input_id: UInt8
    
    var inputs: [DPadDirection: String] // what the buttons of the dpad are
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat, input_id: UInt8,
        inputs: [DPadDirection: String]
    ) {
        self.type = .dpad
        
        self.position = position
        self.scale = scale
        
        self.input_id = input_id
        // TODO: Change input_id to controller id, see ButtonConfig file
        
        self.inputs = inputs
    }
}
