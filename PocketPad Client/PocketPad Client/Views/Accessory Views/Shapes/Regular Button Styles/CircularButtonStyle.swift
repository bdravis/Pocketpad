//
//  CircularButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct CircularButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var style: RegularButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .fontWeight(.bold)
            .background(
                configuration.isPressed ? (
                    colorScheme == .dark ? style.properties.darkModeColors.pressedColor : style.properties.lightModeColors.pressedColor
                ) ?? Color(uiColor: .secondaryLabel)
                : (
                    colorScheme == .dark ? style.properties.darkModeColors.color : style.properties.lightModeColors.color
                ) ?? Color(uiColor: .secondarySystemFill)
            )
            .foregroundStyle(
                configuration.isPressed ? (
                    colorScheme == .dark ? style.properties.darkModeColors.foregroundPressedColor : style.properties.lightModeColors.foregroundPressedColor
                ) ?? Color(uiColor: .systemBackground)
                : (
                    colorScheme == .dark ? style.properties.darkModeColors.foregroundColor : style.properties.lightModeColors.foregroundColor
                ) ?? Color(uiColor: .label)
            )
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFill()
            .lineLimit(1)
            .contentShape(Circle())
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color(uiColor: .label), lineWidth: style.properties.borderThickness)
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
//            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
