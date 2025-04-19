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
            .background(getBGColor().opacity(configuration.isPressed && !split ? 1.0 : 0.0))
            .foregroundStyle(configuration.isPressed ? getFGPressedColor() : getFGColor())
            .contentShape(Rectangle())
            .clipShape(Rectangle())
    }
    
    /* Color Getter Functions */
    func getBGColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.color
            : style.lightModeColors.color
        ) ?? DefaultColors.dpad.color
    }
    func getFGColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.foregroundColor
            : style.lightModeColors.foregroundColor
        ) ?? DefaultColors.dpad.foregroundColor
    }
    func getFGPressedColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.foregroundPressedColor
            : style.lightModeColors.foregroundPressedColor
        ) ?? DefaultColors.dpad.foregroundPressedColor
    }
}
