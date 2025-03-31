//
//  PillButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import SwiftUI

struct PillButtonStyle: ButtonStyle {
    var style: RegularButtonStyle
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE * 0.5) // make it  L O N G
            .fontWeight(.regular)
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
            .scaledToFit()
            .lineLimit(1)
            .contentShape(Capsule())
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(uiColor: .label), lineWidth: style.properties.borderThickness)
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
//            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    Button(action: {}) {
        Text("Button")
    }
    .buttonStyle(PillButtonStyle(style: .init(shape: .Pill, iconType: .Text)))
    .padding()
}
