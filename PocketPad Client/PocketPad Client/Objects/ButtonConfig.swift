//
//  ButtonConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import UIKit

// MARK: Configuration Constants
let DEFAULT_BUTTON_SIZE: CGFloat = 50.0

// Enum for the type of button it is
enum ButtonType: Codable {
    case regular
    case joystick
    case dpad
}

// Protocol for configuration of the buttons for the layout
protocol ButtonConfig: Codable {
    var id: UUID { get }
    var position: CGPoint { get set } // position of btn on screen
    var scale: CGFloat { get set } // % scale of the button (1.0 = 100% scale)
    
    var type: ButtonType { get set } // what type of button it is
}

extension ButtonConfig {
    var id: UUID {      // conform to identifiable
        return UUID()
    }
    
    mutating func getScaledPosition(bounds: CGRect? = nil) -> CGPoint {
        // Position the button so that it is not clipped by the edge of the screen
        let scaledSize = (DEFAULT_BUTTON_SIZE * self.scale) / 2
        var fixedPos = self.position
        
        if let frame = bounds {
            // prevent from going off the right/bottom of the screen if bounds are supplied
            if fixedPos.x + scaledSize > frame.maxX {
                fixedPos.x = frame.maxX - scaledSize
            }
            if fixedPos.y + scaledSize > frame.maxY {
                fixedPos.y = frame.maxY - scaledSize
            }
            
            // prevent from going off the left/top of the screen if bounds are supplied
            if fixedPos.x - scaledSize < frame.minX {
                fixedPos.x = frame.minX + scaledSize
            }
            if fixedPos.y - scaledSize < frame.minY {
                fixedPos.y = frame.minY + scaledSize
            }
        } else {
            // prevent from going off the left/top of the screen without provided bounds (position 0)
            if fixedPos.x - scaledSize < 0.0 {
                fixedPos.x = scaledSize
            }
            if fixedPos.y - scaledSize < 0.0 {
                fixedPos.y = scaledSize
            }
        }
        
        return fixedPos
    }
}

// MARK: Specific Button Config Objects
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

struct JoystickConfig: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    
    var input: String // which joystick button it will correlate to
    var sensitivity: Double // the sensitivity of the controller
    var deadzone: Double // how far it needs to move before it starts accepting inputs
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat,
        input: String, sensitivity: Double = 0.0, deadzone: Double = 0.0
    ) {
        self.type = .joystick
        
        self.position = position
        self.scale = scale
        
        self.input = input
        self.sensitivity = sensitivity
        self.deadzone = deadzone
    }
}

struct DPadConfig: ButtonConfig {
    // Protocol Properties
    var position: CGPoint
    var scale: CGFloat
    var type: ButtonType
    
    var inputs: [String] // what the buttons of the dpad are
    
    // Object Initializer
    init(
        position: CGPoint, scale: CGFloat,
        inputs: [String]
    ) {
        self.type = .dpad
        
        self.position = position
        self.scale = scale
        
        self.inputs = inputs
    }
}
