//
//  RegularButtonConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import UIKit

struct RegularButtonConfig: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    
    // TODO: Decide whether input will be a string or an int correlating to button id
    var input: String // the button it is bound to
    var turbo: Bool // whether or not it is a turbo tap
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat,
         input: String, turbo: Bool = false
    ) {
        self.type = .regular
        
        self.position = position
        self.scale = scale
        
        self.input = input
        self.turbo = turbo
    }
}
