//
//  RegularButtonConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

struct RegularButtonConfig: ButtonConfig, ConfigType {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    var inputId: UInt8
    
    var input: String // the button it is bound to
    var style: RegularButtonStyle // style configuration of the button
    var turbo: Bool // whether or not this is the turbo button
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat, inputId: UInt8,
        input: String, style: RegularButtonStyle? = nil, turbo: Bool = false, isTurboButton: Bool = false
    ) {
        self.type = .regular
        
        self.position = position
        self.scale = scale
        
        self.inputId = inputId
        
        self.input = input
        self.turbo = turbo
        self.isTurboButton = isTurboButton;
        
        if let style = style {
            self.style = style
        } else {
            // create a default style configuration
            self.style = .init(shape: .Circle, iconType: .Text, icon: input)
        }
    }
}
