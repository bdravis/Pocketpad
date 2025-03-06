//
//  TriggerConfig.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//

import UIKit

enum TriggerSide: UInt8, ConfigType {
    case right = 0
    case left = 1
}

struct TriggerConfig: ButtonConfig, ConfigType {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    var inputId: UInt8
    
    var side: TriggerSide // 0 for left, 1
    
    var input: String // the button it is bound to
    var turbo: Bool // whether or not it is a turbo tap
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat, inputId: UInt8,
        input: String, turbo: Bool = false,
        side: TriggerSide
    ) {
        self.type = .trigger
        
        self.position = position
        self.scale = scale
        
        self.inputId = inputId
        
        self.input = input
        self.turbo = turbo
        
        self.side = side
    }
}
