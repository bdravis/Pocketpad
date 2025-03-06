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
enum ButtonType: UInt8, ConfigType {
    case regular = 0
    case joystick = 1
    case dpad = 2
}

// Protocol for configuration of the buttons for the layout
protocol ButtonConfig: Codable {
    var id: UUID { get }
    var position: CGPoint { get set } // position of btn on screen
    var scale: CGFloat { get set } // % scale of the button (1.0 = 100% scale)
    
    var type: ButtonType { get set } // what type of button it is
    
    var inputId: UInt8 { get set } // id for buttons when sending input
    
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
