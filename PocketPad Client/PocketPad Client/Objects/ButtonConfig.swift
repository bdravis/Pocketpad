//
//  ButtonConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import UIKit

// Enum for the type of button it is
enum ButtonType: Codable {
    case regular
    case joystick
    case dpad
}

// Protocol for configuration of the buttons for the layout
protocol ButtonConfig: Codable {
    var position: CGPoint { get set } // position of btn on screen
    var scale: CGFloat { get set } // % scale of the button (1.0 = 100% scale)
    
    var type: ButtonType { get set } // what type of button it is
}

// MARK: Button Data Objects
struct RegularButtonData: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    
    // TODO: Decide whether input will be a string or an int correlating to button id
    var input: String // the button it is bound to
    var turbo: Bool // whether or not it is a turbo tap
}

struct JoystickData: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    
    var input: String // which joystick button it will correlate to
    var sensitivity: Double // the sensitivity of the controller
    var deadzone: Double // how far it needs to move before it starts accepting inputs
}

struct DPadData: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    
    var inputs: [String] // what the buttons of the dpad are
}
