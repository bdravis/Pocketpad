//
//  CircularButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct CircularButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .fontWeight(.bold)
            .background(Color(uiColor: configuration.isPressed ? .secondaryLabel : .secondarySystemFill))
            .foregroundStyle(Color(uiColor: configuration.isPressed ? .systemBackground : .label))
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFill()
            .lineLimit(1)
            .contentShape(Circle())
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color(uiColor: .label), lineWidth: 3)
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
//            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
