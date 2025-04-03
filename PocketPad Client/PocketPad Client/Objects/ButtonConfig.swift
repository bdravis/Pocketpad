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
enum ButtonType: UInt8, ConfigType, CaseIterable {
    case regular = 0
    case joystick = 1
    case dpad = 2
    case bumper = 3
    case trigger = 4
}

// Enum for button event (pressed or released)
enum ButtonEvent: UInt8, ConfigType {
    case pressed = 0
    case released = 1
}

// Position information for a button, including side override
struct ButtonPosition: ConfigType {
    var scaledPos: CGPoint // scaled position of btn on screen (0.0 to 1.0 multiplied by screen size)
    var offset: CGPoint = CGPointZero // the exact offset of btn from position as the center point
    
    // Override information (for the opposite orientation)
    var defaultIsPortrait: Bool? // whether or not the default position is for portrait, keep nil if not overriding
    var overrideScaledPos: CGPoint? // the overridden scaled position for the opposite orientation
    var overrideOffset: CGPoint? // the overriden offset for the opposite orientation
}

// Protocol for configuration of the buttons for the layout
protocol ButtonConfig: Codable {
    var id: UUID { get }
    var position: ButtonPosition { get set } // scaled position of btn on screen (0.0 to 1.0 multiplied by screen size)
    var scale: CGFloat { get set } // % scale of the button (1.0 = 100% scale)
    var rotation: Double { get set } // rotation of the button in degrees
    
    var type: ButtonType { get set } // what type of button it is
    
    var inputId: UInt8 { get set } // id for buttons when sending input
    
    mutating func updateStyle<T>(to newStyle: T)
}

extension ButtonConfig {
    var id: UUID {      // conform to identifiable
        return UUID()
    }
    
    // TODO: Fix later for position
//    mutating func getScaledPosition(bounds: CGRect? = nil) -> CGPoint {
//        // Position the button so that it is not clipped by the edge of the screen
//        let scaledSize = (DEFAULT_BUTTON_SIZE * self.scale) / 2
//        var fixedPos = self.position
//        
//        if let frame = bounds {
//            // prevent from going off the right/bottom of the screen if bounds are supplied
//            if fixedPos.x + scaledSize > frame.maxX {
//                fixedPos.x = frame.maxX - scaledSize
//            }
//            if fixedPos.y + scaledSize > frame.maxY {
//                fixedPos.y = frame.maxY - scaledSize
//            }
//            
//            // prevent from going off the left/top of the screen if bounds are supplied
//            if fixedPos.x - scaledSize < frame.minX {
//                fixedPos.x = frame.minX + scaledSize
//            }
//            if fixedPos.y - scaledSize < frame.minY {
//                fixedPos.y = frame.minY + scaledSize
//            }
//        } else {
//            // prevent from going off the left/top of the screen without provided bounds (position 0)
//            if fixedPos.x - scaledSize < 0.0 {
//                fixedPos.x = scaledSize
//            }
//            if fixedPos.y - scaledSize < 0.0 {
//                fixedPos.y = scaledSize
//            }
//        }
//        
//        return fixedPos
//    }
}

// a bad button type config for testing encoding errors
struct BadButtonTypeConfig: ButtonConfig, ConfigType {
    mutating func updateStyle<T>(to newStyle: T) {
        return
    }
    
    // Protocol Properties
    var position: ButtonPosition
    var scale: CGFloat
    var rotation: Double
    var type: ButtonType
    var inputId: UInt8
}
