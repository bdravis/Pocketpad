//
//  DPadButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 2/19/25.
//

import SwiftUI

struct DPadButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var style: GeneralButtonStyle
    var split: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(((
                colorScheme == .dark ? style.darkModeColors.color : style.lightModeColors.color
            ) ?? Color(uiColor: .secondaryLabel)).opacity(configuration.isPressed && !split ? 1.0 : 0.0))
            .foregroundStyle(
                configuration.isPressed ? (
                    colorScheme == .dark ? style.darkModeColors.foregroundPressedColor
                    : style.lightModeColors.foregroundPressedColor
                ) ?? DefaultColors.dpad.foregroundPressedColor
                : (
                    colorScheme == .dark ? style.darkModeColors.foregroundColor
                    : style.lightModeColors.foregroundColor
                ) ?? DefaultColors.dpad.foregroundColor
            )
            .contentShape(Rectangle())
            .clipShape(Rectangle())
    }
}
