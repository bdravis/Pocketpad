//
//  ButtonInput.swift
//  PocketPad Client
//
//  Created by lemin on 3/27/25.
//

import Foundation

// enum for all of the button inputs
enum ButtonInput: String, Codable {
    case A = "A"
    case B = "B"
    case X = "X"
    case Y = "Y"
    case Z = "Z"
    case One = "1"
    case Two = "2"
    
    case Start = "Start"
    case Select = "Select"
    case Home = "Home"
    case Share = "Share"
    
    case RB = "RB"
    case LB = "LB"
    case RT = "RT"
    case LT = "LT"
    
    case RightJoystick = "RightJoystick"
    case LeftJoystick = "LeftJoystick"
    
    case DPadUp = "DPadUp"
    case DPadDown = "DPadDown"
    case DPadRight = "DPadRight"
    case DPadLeft = "DPadLeft"
}

func getButtonInputs(for type: ButtonType) -> [ButtonInput] {
    switch type {
    case .regular:
        return [.A, .B, .X, .Y, .Z, .One, .Two, .Start, .Select, .Home, .Share]
    case .joystick:
        return [.RightJoystick, .LeftJoystick]
    case .dpad:
        return [.DPadUp, .DPadDown, .DPadLeft, .DPadRight]
    case .bumper:
        return [.LB, .RB]
    case .trigger:
        return [.LT, .RT]
    }
}
