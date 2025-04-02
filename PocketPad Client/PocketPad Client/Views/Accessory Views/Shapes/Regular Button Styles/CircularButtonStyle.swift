//
//  CircularButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct CircularButtonStyle: ButtonStyle {
    var style: RegularButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .fontWeight(.bold)
            .background(
                configuration.isPressed ? style.properties.pressedColor ?? Color(uiColor: .secondaryLabel)
                : style.properties.color ?? Color(uiColor: .secondarySystemFill)
            )
            .foregroundStyle(
                configuration.isPressed ? style.properties.foregroundPressedColor ?? Color(uiColor: .systemBackground)
                : style.properties.foregroundColor ?? Color(uiColor: .label)
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
