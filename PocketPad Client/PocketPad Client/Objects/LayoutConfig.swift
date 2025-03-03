//
//  LayoutConfig.swift
//  PocketPad Client
//
//  Created by lemin on 2/21/25.
//

// The configuration of the layout to be saved and loaded from the file
struct LayoutConfig: Codable {
    var name: String // name of the config to show in settings
    var landscapeButtons: [ButtonConfig] // the list of landscape buttons
    var portraitButtons: [ButtonConfig] // the list of portrait orientation buttons
    
    private enum CodingKeys: String, CodingKey { // the keys in which the items are stored in the file
        case name, wrappedLandscapeButtons, wrappedPortraitButtons
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
}
