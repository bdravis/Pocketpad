//
//  RegularButtonConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

struct RegularButtonConfig: ButtonConfig, ConfigType {
    mutating func updateStyle<T>(to newStyle: T) {
        if let newStyle = newStyle as? RegularButtonStyle {
            self.style = newStyle
        }
    }
    
    mutating func updateValue<T>(name: String, to newValue: T) {
        return
    }
    
    // Protocol Properties
    var position: ButtonPosition
    var scale: CGFloat
    var rotation: Double
    var type: ButtonType
    var inputId: UInt8
    
    var input: ButtonInput // the button it is bound to
    var style: RegularButtonStyle // style configuration of the button
    var turbo: Bool // whether or not this is the turbo button
    
    // Object Initializer
    init(
        type: ButtonType = .regular,
        position: ButtonPosition, scale: CGFloat, rotation: Double = 0.0, inputId: UInt8,
        input: ButtonInput, style: RegularButtonStyle? = nil, turbo: Bool = false
    ) {
        self.type = type
        
        self.position = position
        self.scale = scale
        self.rotation = rotation
        
        self.inputId = inputId
        
        self.input = input
        self.turbo = input == .Turbo
        
        if let style = style {
            self.style = style
        } else {
            // create a default style configuration
            self.style = .init(shape: (type == .bumper ? .Pill : .Circle), iconType: .Text, icon: input.rawValue)
        }
    }
}
