//
//  PillButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import SwiftUI

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(9)
            .fontWeight(.regular)
            .background(Color(uiColor: configuration.isPressed ? .secondaryLabel : .secondarySystemFill))
            .foregroundStyle(Color(uiColor: configuration.isPressed ? .systemBackground : .label))
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFill()
            .lineLimit(1)
            .frame(height: DEFAULT_BUTTON_SIZE * 0.35) // make it  L O N G
            .contentShape(Capsule())
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(uiColor: .label), lineWidth: 3)
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
            .scaleEffect(1.2)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
