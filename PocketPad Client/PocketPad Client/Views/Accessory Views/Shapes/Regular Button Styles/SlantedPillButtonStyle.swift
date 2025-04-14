//
//  SlantedPillButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 4/1/25.
//

import SwiftUI

struct SlantedPillButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var style: RegularButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE * 0.6) // make it  L O N G
            .fontWeight(.regular)
            .clipShape(CurvedCapsule())
            .background(
                CurvedCapsule()
                    .foregroundStyle(
                        configuration.isPressed ? (
                            colorScheme == .dark ? style.properties.darkModeColors.pressedColor
                            : style.properties.lightModeColors.pressedColor
                        ) ?? DefaultColors.regular.pressedColor
                        : (
                            colorScheme == .dark ? style.properties.darkModeColors.color
                            : style.properties.lightModeColors.color
                        ) ?? DefaultColors.regular.color
                    )
                    .offset(y: DEFAULT_BUTTON_SIZE * 0.04)
            )
            .foregroundStyle(
                configuration.isPressed ? (
                    colorScheme == .dark ? style.properties.darkModeColors.foregroundPressedColor
                    : style.properties.lightModeColors.foregroundPressedColor
                ) ?? DefaultColors.regular.foregroundPressedColor
                : (
                    colorScheme == .dark ? style.properties.darkModeColors.foregroundColor
                    : style.properties.lightModeColors.foregroundColor
                ) ?? DefaultColors.regular.foregroundColor
            )
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFit()
            .lineLimit(1)
            .overlay(
                CurvedCapsule()
                    .stroke((
                        colorScheme == .dark ? style.properties.darkModeColors.strokeColor
                        : style.properties.lightModeColors.strokeColor
                    ) ?? DefaultColors.regular.strokeColor, lineWidth: style.properties.borderThickness)
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
                    .offset(y: DEFAULT_BUTTON_SIZE * 0.04)
            )
    }
}

#Preview {
    Button(action: {}) {
        Text("X")
    }
    .buttonStyle(SlantedPillButtonStyle(style: .init(shape: .SlantedPill, iconType: .Text)))
    .padding()
}
