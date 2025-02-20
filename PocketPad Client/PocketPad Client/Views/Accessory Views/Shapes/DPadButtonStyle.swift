//
//  DPadButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 2/19/25.
//

import SwiftUI

struct DPadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color(uiColor: .secondaryLabel).opacity(configuration.isPressed ? 1.0 : 0.0))
            .foregroundStyle(Color(uiColor: configuration.isPressed ? .systemBackground : .label))
            .contentShape(Rectangle())
            .clipShape(Rectangle())
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
