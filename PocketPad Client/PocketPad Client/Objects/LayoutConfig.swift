//
//  LayoutConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/21/25.
//

typealias ConfigType = Codable & Equatable

// The configuration of the layout to be saved and loaded from the file
struct LayoutConfig: ConfigType {
    var name: String // name of the config to show in settings
    var buttons: [ButtonConfig] // the list of the buttons
    
    private enum CodingKeys: String, CodingKey { // the keys in which the items are stored in the file
        case name, wrappedButtons
    }
    
    init(name: String, buttons: [ButtonConfig]) {
        self.name = name;
        self.buttons = buttons;
    }
    
    // Wrappers are used because protocols (i.e. ButtonConfig) cannot conform to Codable
    // Wrappers allow the encoding and decoding of multiple types that comform to the protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // decode name
        name = try container.decode(String.self, forKey: .name)
        
        // decode buttons
        let wrappedButtons = try container.decode([ButtonConfigWrapper].self, forKey: .wrappedButtons)
        buttons = wrappedButtons.map({ $0.buttonConfig })
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // encode name
        try container.encode(name, forKey: .name)
        
        // encode buttons
        let wrappedButtons = buttons.map(ButtonConfigWrapper.init)
        try container.encode(wrappedButtons, forKey: .wrappedButtons)
    }
    
    // conform to equatable
    static func == (lhs: LayoutConfig, rhs: LayoutConfig) -> Bool {
        if lhs.name != rhs.name {
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
            } else if let lhsBtn = lhs.buttons[i] as? BumperConfig, let rhsBtn = rhs.buttons[i] as? BumperConfig {
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
