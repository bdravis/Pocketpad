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
        }
    }
    
    // Conform wrapper struct to Encodable
    func encode(to encoder: Encoder) throws {
        let container = encoder.container(keyedBy: CodingKeys.self)
        // TBD
    }
}
