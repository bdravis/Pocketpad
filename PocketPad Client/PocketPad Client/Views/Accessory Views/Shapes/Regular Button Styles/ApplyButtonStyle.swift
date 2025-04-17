//
//  ApplyButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import SwiftUI

struct ApplyButtonStyle: ViewModifier {
    var style: RegularButtonStyle
    var isTurboEnabled: Bool
    
    func body(content: Content) -> some View {
        switch style.shape { // TODO: Fix the hitbox being a square/larger than it is supposed to be
        case .Circle:
            content
                .buttonStyle(CircularButtonStyle(style: style, isTurboEnabled: isTurboEnabled))
        case .Pill:
            content
                .buttonStyle(PillButtonStyle(style: style, isTurboEnabled: isTurboEnabled))
        case .SlantedPill:
            content
                .buttonStyle(SlantedPillButtonStyle(style: style, isTurboEnabled: isTurboEnabled))
        }
    }
}

extension View {
    func applyButtonStyle(_ style: RegularButtonStyle, isTurboEnabled: Bool) -> some View {
        self.modifier(ApplyButtonStyle(style: style, isTurboEnabled: isTurboEnabled))
    }
}
