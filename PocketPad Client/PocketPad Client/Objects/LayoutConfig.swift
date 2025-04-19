//
//  LayoutConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/21/25.
//

import UIKit

typealias ConfigType = Codable & Equatable

// The configuration of the layout to be saved and loaded from the file
struct LayoutConfig: ConfigType {
    var name: String // name of the config to show in settings
    var rotationLocked: Bool // whether or not the rotation is locked in the controller view
    var lockToOrientation: UIInterfaceOrientationMask // the direction to allow the locked rotations
    var buttons: [ButtonConfig] // the list of the buttons
    
    private enum CodingKeys: String, CodingKey { // the keys in which the items are stored in the file
        case name, rotationLocked, lockToOrientation, wrappedButtons
    }
    
    init(name: String, rotationLocked: Bool = true, lockToOrientation: UIInterfaceOrientationMask = .landscape, buttons: [ButtonConfig]) {
        self.name = name
        self.rotationLocked = rotationLocked
        self.lockToOrientation = lockToOrientation
        self.buttons = buttons
    }
    
    // Wrappers are used because protocols (i.e. ButtonConfig) cannot conform to Codable
    // Wrappers allow the encoding and decoding of multiple types that comform to the protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // decode name
        name = try container.decode(String.self, forKey: .name)
        
        // decode rotation lock
        rotationLocked = (try? container.decode(Bool.self, forKey: .rotationLocked)) ?? true
        
        // decode locked to orientation
        lockToOrientation = UIInterfaceOrientationMask(rawValue: (try? container.decode(UInt.self, forKey: .lockToOrientation)) ?? UIInterfaceOrientationMask.all.rawValue)
        
        // decode buttons
        let wrappedButtons = try container.decode([ButtonConfigWrapper].self, forKey: .wrappedButtons)
        buttons = wrappedButtons.map({ $0.buttonConfig })
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // encode name
        try container.encode(name, forKey: .name)
        
        // encode rotation lock
        try container.encode(rotationLocked, forKey: .rotationLocked)
        
        // encode locked to portrait
        try container.encode(lockToOrientation.rawValue, forKey: .lockToOrientation)
        
        // encode buttons
        let wrappedButtons = buttons.map(ButtonConfigWrapper.init)
        try container.encode(wrappedButtons, forKey: .wrappedButtons)
    }
    
    // conform to equatable
    static func == (lhs: LayoutConfig, rhs: LayoutConfig) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        
        if lhs.rotationLocked != rhs.rotationLocked {
            return false
        }
        if lhs.lockToOrientation != rhs.lockToOrientation {
            return false
        }
        
        if lhs.buttons.count != rhs.buttons.count {
            return false
        }
        
        // check buttons
        for i in 0..<lhs.buttons.count {
            if let lhsBtn = lhs.buttons[i] as? RegularButtonConfig, let rhsBtn = rhs.buttons[i] as? RegularButtonConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.buttons[i] as? DPadConfig, let rhsBtn = rhs.buttons[i] as? DPadConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.buttons[i] as? JoystickConfig, let rhsBtn = rhs.buttons[i] as? JoystickConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.buttons[i] as? TriggerConfig, let rhsBtn = rhs.buttons[i] as? TriggerConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else {
                return false
            }
        }
        
        return true
    }
}
