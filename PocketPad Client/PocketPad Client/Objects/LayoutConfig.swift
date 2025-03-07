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
    var landscapeButtons: [ButtonConfig] // the list of landscape buttons
    var portraitButtons: [ButtonConfig] // the list of portrait orientation buttons
    
    private enum CodingKeys: String, CodingKey { // the keys in which the items are stored in the file
        case name, wrappedLandscapeButtons, wrappedPortraitButtons
    }
    
    init(name: String, landscapeButtons: [ButtonConfig], portraitButtons: [ButtonConfig]) {
        self.name = name;
        self.landscapeButtons = landscapeButtons;
        self.portraitButtons = portraitButtons;
    }
    
    // Wrappers are used because protocols (i.e. ButtonConfig) cannot conform to Codable
    // Wrappers allow the encoding and decoding of multiple types that comform to the protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // decode name
        name = try container.decode(String.self, forKey: .name)
        
        // decode landscape buttons
        let wrappedLandscapeButtons = try container.decode([ButtonConfigWrapper].self, forKey: .wrappedLandscapeButtons)
        landscapeButtons = wrappedLandscapeButtons.map({ $0.buttonConfig })
        
        // decode portrait buttons
        let wrappedPortraitButtons = try container.decode([ButtonConfigWrapper].self, forKey: .wrappedPortraitButtons)
        portraitButtons = wrappedPortraitButtons.map({ $0.buttonConfig })
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // encode name
        try container.encode(name, forKey: .name)
        
        // encode landscape buttons
        let wrappedLandscapeButtons = landscapeButtons.map(ButtonConfigWrapper.init)
        try container.encode(wrappedLandscapeButtons, forKey: .wrappedLandscapeButtons)
        
        // encode portrait buttons
        let wrappedPortraitButtons = portraitButtons.map(ButtonConfigWrapper.init)
        try container.encode(wrappedPortraitButtons, forKey: .wrappedPortraitButtons)
    }
    
    // conform to equatable
    static func == (lhs: LayoutConfig, rhs: LayoutConfig) -> Bool {
        if lhs.name != rhs.name {
            return false
        }
        
        if lhs.landscapeButtons.count != rhs.landscapeButtons.count {
            return false
        } else if lhs.portraitButtons.count != rhs.portraitButtons.count {
            return false
        }
        
        // check landscape
        for i in 0..<lhs.landscapeButtons.count {
            if let lhsBtn = lhs.landscapeButtons[i] as? RegularButtonConfig, let rhsBtn = rhs.landscapeButtons[i] as? RegularButtonConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.landscapeButtons[i] as? DPadConfig, let rhsBtn = rhs.landscapeButtons[i] as? DPadConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.landscapeButtons[i] as? JoystickConfig, let rhsBtn = rhs.landscapeButtons[i] as? JoystickConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.landscapeButtons[i] as? BumperConfig, let rhsBtn = rhs.landscapeButtons[i] as? BumperConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.landscapeButtons[i] as? TriggerConfig, let rhsBtn = rhs.landscapeButtons[i] as? TriggerConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else {
                return false
            }
        }
        
        // check portrait
        for i in 0..<lhs.portraitButtons.count {
            if let lhsBtn = lhs.portraitButtons[i] as? RegularButtonConfig, let rhsBtn = rhs.portraitButtons[i] as? RegularButtonConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.portraitButtons[i] as? DPadConfig, let rhsBtn = rhs.portraitButtons[i] as? DPadConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.portraitButtons[i] as? JoystickConfig, let rhsBtn = rhs.portraitButtons[i] as? JoystickConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.portraitButtons[i] as? BumperConfig, let rhsBtn = rhs.portraitButtons[i] as? BumperConfig {
                if lhsBtn != rhsBtn {
                    return false
                }
            } else if let lhsBtn = lhs.portraitButtons[i] as? TriggerConfig, let rhsBtn = rhs.portraitButtons[i] as? TriggerConfig {
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
