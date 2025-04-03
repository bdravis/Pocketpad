//
//  ControllerType.swift
//  PocketPad Client
//
//  Created by lemin on 2/26/25.
//

enum ControllerType: UInt8, CaseIterable {
    case Xbox = 0
    case PlayStation = 1
    case Wii = 2
    case GameCube = 5
    case Switch = 3
    case DPadless = 4
    case Turbo = 6
    
    var stringValue: String {
        switch self {
        case .Xbox:
            return "Xbox"
        case .PlayStation:
            return "PlayStation"
        case .GameCube:
            return "GameCube"
        case .Wii:
            return "Wii"
        case .Switch:
            return "Switch"
        case .DPadless:
            return "DPad-less Test"
        case .Turbo:
            return "Turbo"
        }
        
    }
    
    init?(stringValue: String) {
        switch stringValue {
        case "Xbox":
            self = .Xbox
        case "PlayStation":
            self = .PlayStation
        case "GameCube":
            self = .GameCube
        case "Wii":
            self = .Wii
        case "Switch":
            self = .Switch
        case "DPad-less Test":
            self = .DPadless
        case "Turbo":
            self = .Turbo
        default:
            return nil
        }
    }
}
