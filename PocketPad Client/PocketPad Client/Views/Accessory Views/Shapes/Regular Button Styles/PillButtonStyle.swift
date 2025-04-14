//
//  PillButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import SwiftUI

struct PillButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var style: RegularButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE * 0.5) // make it  L O N G
            .fontWeight(.regular)
            .background(configuration.isPressed ? getBGPressedColor() : getBGColor())
            .foregroundStyle(configuration.isPressed ? getFGPressedColor() : getFGColor())
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFit()
            .lineLimit(1)
            .contentShape(Capsule())
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(getStrokeColor(), lineWidth: style.properties.borderThickness)
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
    }
    
    /* Color Getter Functions */
    func getBGColor() -> Color {
        return (
            colorScheme == .dark ? style.properties.darkModeColors.color
            : style.properties.lightModeColors.color
        ) ?? DefaultColors.regular.color
    }
    func getBGPressedColor() -> Color {
        return (
            colorScheme == .dark ? style.properties.darkModeColors.pressedColor
            : style.properties.lightModeColors.pressedColor
        ) ?? DefaultColors.regular.pressedColor
    }
    func getFGColor() -> Color {
        return (
            colorScheme == .dark ? style.properties.darkModeColors.foregroundColor
            : style.properties.lightModeColors.foregroundColor
        ) ?? DefaultColors.regular.foregroundColor
    }
    func getFGPressedColor() -> Color {
        return (
            colorScheme == .dark ? style.properties.darkModeColors.foregroundPressedColor
            : style.properties.lightModeColors.foregroundPressedColor
        ) ?? DefaultColors.regular.foregroundPressedColor
    }
    func getStrokeColor() -> Color {
        return (
            colorScheme == .dark ? style.properties.darkModeColors.strokeColor
            : style.properties.lightModeColors.strokeColor
        ) ?? DefaultColors.regular.strokeColor
    }
}

#Preview {
    Button(action: {}) {
        Text("Button")
    }
    .buttonStyle(PillButtonStyle(style: .init(shape: .Pill, iconType: .Text)))
    .padding()
}
