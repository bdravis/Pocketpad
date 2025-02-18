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

// Configuration of the buttons for the layout
struct ButtonConfig: Codable {
    var position: CGPoint // position of btn on screen
    var scale: CGFloat // % scale of the button (1.0 = 100% scale)
    
    var type: ButtonType // what type of button it is
    var data: ButtonData
}

// Enum to be able to store multiple controller types in the same ButtonConfig struct
enum ButtonData: Codable {
    case regular(RegularButtonData)
    case joystick(JoystickData)
    case dpad(DPadData)
}

// MARK: Button Data Objects
struct RegularButtonData: Codable {
    // TODO: Decide whether input will be a string or an int correlating to button id
    var input: String // the button it is bound to
    var turbo: Bool // whether or not it is a turbo tap
}

struct JoystickData: Codable {
    var input: String // which joystick button it will correlate to
    var sensitivity: Double // the sensitivity of the controller
    var deadzone: Double // how far it needs to move before it starts accepting inputs
}

struct DPadData: Codable {
    var inputs: [String] // what the buttons of the dpad are
}
