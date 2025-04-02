//
//  DPadButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 2/19/25.
//

import SwiftUI

struct DPadButtonStyle: ButtonStyle {
    var style: GeneralButtonStyle
    var split: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background((style.color ?? Color(uiColor: .secondaryLabel)).opacity(configuration.isPressed && !split ? 1.0 : 0.0))
            .foregroundStyle(
                configuration.isPressed ? style.foregroundPressedColor ?? Color(uiColor: .systemBackground)
                : style.foregroundColor ?? Color(uiColor: .label)
            )
            .contentShape(Rectangle())
            .clipShape(Rectangle())
//            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}
