//
//  ApplyButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import SwiftUI

struct ApplyButtonStyle: ViewModifier {
    let style: RegularButtonStyle
    
    func body(content: Content) -> some View {
        switch style { // TODO: Fix the hitbox being a square/larger than it is supposed to be
        case .Circle:
            content
                .buttonStyle(CircularButtonStyle())
        case .Pill:
            content
                .buttonStyle(PillButtonStyle())
        }
    }
}

extension View {
    func applyButtonStyle(style: RegularButtonStyle) -> some View {
        self.modifier(ApplyButtonStyle(style: style))
    }
}
