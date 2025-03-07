//
//  ButtonConfigWrapper.swift
//  PocketPad Client
//
//  Created by Jack Fang on 3/2/25.
//

// Wrapper struct for button config, used for encoding and decoding
struct ButtonConfigWrapper: Codable {
    let buttonConfig: ButtonConfig
    
    // base property contains info about the type of button config it is
    // payload property contains the button config data itself
    private enum CodingKeys: String, CodingKey {
        case base, payload
    }
    
    // base is represented as an enum, one for each config type
    private enum Base: Int, Codable {
        case dPadConfig
        case joystickConfig
        case regularButtonConfig
        case bumperConfig
        case triggerConfig
    }
    
    init(_ buttonConfig: ButtonConfig) {
        self.buttonConfig = buttonConfig
    }
    
    // Conform wrapper struct to Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        // Use base property to find what type of button config was sent in, then decode the payload data accordingly
        switch base {
            case .dPadConfig:
                self.buttonConfig = try container.decode(DPadConfig.self, forKey: .payload)
            case .joystickConfig:
                self.buttonConfig = try container.decode(JoystickConfig.self, forKey: .payload)
            case .regularButtonConfig:
                self.buttonConfig = try container.decode(RegularButtonConfig.self, forKey: .payload)
            case .bumperConfig:
                self.buttonConfig = try container.decode(BumperConfig.self, forKey: .payload)
            case .triggerConfig:
                self.buttonConfig = try container.decode(TriggerConfig.self, forKey: .payload)
        }
    }
    
    // Conform wrapper struct to Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // This switch statement tries to cast buttonConfig as each different type of config
        switch buttonConfig {
            case let payload as DPadConfig:
                try container.encode(Base.dPadConfig, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as JoystickConfig:
                try container.encode(Base.joystickConfig, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as RegularButtonConfig:
                try container.encode(Base.regularButtonConfig, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as BumperConfig:
                try container.encode(Base.bumperConfig, forKey: .base)
                try container.encode(payload, forKey: .payload)
            case let payload as TriggerConfig:
                try container.encode(Base.triggerConfig, forKey: .base)
                try container.encode(payload, forKey: .payload)
            default:
                break
        }
    }
}
