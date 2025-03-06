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
    case Switch = 3
    case DPadless = 4
    
    var stringValue: String {
        switch self {
        case .Xbox:
            return "Xbox"
        case .PlayStation:
            return "PlayStation"
        case .Wii:
            return "Wii"
        case .Switch:
            return "Switch"
        case .DPadless:
            return "DPad-less Test"
        }
    }
}
