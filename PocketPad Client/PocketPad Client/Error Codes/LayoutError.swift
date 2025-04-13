//
//  LayoutError.swift
//  PocketPad Client
//
//  Created by lemin on 4/1/25.
//

import Foundation

enum LayoutError: LocalizedError {
    // Throw when the name already exists
    case duplicate
    
    // Throw in all other cases
    case unexpected(code: Int)
    
    public var errorDescription: String? {
        switch self {
        case .duplicate:
            return "A layout with that name already exists."
        case .unexpected(_):
            return "An unexpected error occurred."
        }
    }
}
