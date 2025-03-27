//
//  TriggerConfig.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//

import UIKit

enum TriggerSide: UInt8, ConfigType, CaseIterable {
    case left = 0
    case middle = 1
    case right = 2
}

struct TriggerConfig: ButtonConfig, ConfigType {
    // Protocol Properties
    var position: ButtonPosition
    var scale: CGFloat
    var rotation: Double
    var type: ButtonType
    var inputId: UInt8
    
    var side: TriggerSide // 0 for left, 1
    
    var input: ButtonInput // the button it is bound to
    var turbo: Bool // whether or not it is a turbo tap
    
    // Object Initializer
    init(
        position: ButtonPosition, scale: CGFloat, rotation: Double = 0.0, inputId: UInt8,
        input: ButtonInput, turbo: Bool = false,
        side: TriggerSide
    ) {
        self.type = .trigger
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
        
        self.inputId = inputId
        
        self.input = input
        self.turbo = turbo
        
        self.side = side
    }
}
