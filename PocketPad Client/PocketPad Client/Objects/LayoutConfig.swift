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
    var portraitButtons: [ButtonConfig] // the list of portait orientation buttons
    
    private enum CodingKeys: String, CodingKey { // the keys in which the items are stored in the file
        case name, landscapeButtons, portraitButtons
    }
    
    init(from decoder: Decoder) throws {
        // TODO: decode to struct using coding keys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        landscapeButtons = []
        portraitButtons = []
    }
    
    func encode(to encoder: any Encoder) throws {
        // TODO: Encode to file
    }
}
