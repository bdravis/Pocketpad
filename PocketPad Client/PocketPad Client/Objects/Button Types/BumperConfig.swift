//
//  BumperConfig.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//

import UIKit

struct BumperConfig: ButtonConfig, ConfigType {
    // Protocol Properties
    var position: ButtonPosition
    var scale: CGFloat
    var rotation: Double
    var type: ButtonType
    var inputId: UInt8
    
    var input: String // the button it is bound to
    var style: RegularButtonStyle // style configuration of the button
    var turbo: Bool // whether or not it is a turbo tap
    
    // Object Initializer
    init(
        position: ButtonPosition, scale: CGFloat, rotation: Double = 0.0, inputId: UInt8,
        input: String, style: RegularButtonStyle? = nil, turbo: Bool = false
    ) {
        self.type = .bumper
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
        
        self.inputId = inputId
        
        self.input = input
        self.turbo = turbo
        
        if let style = style {
            self.style = style
        } else {
            // create a default style configuration
            self.style = .init(shape: .Pill, iconType: .Text, icon: input)
        }
    }
}
