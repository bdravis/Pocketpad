//
//  DefaultColors.swift
//  PocketPad Client
//
//  Created by lemin on 4/14/25.
//

import SwiftUICore

struct DefaultColorConfig {
    let color: Color
    let pressedColor: Color
    let foregroundColor: Color
    let foregroundPressedColor: Color
    let strokeColor: Color
    
    init(color: Color = .black, pressedColor: Color = .white, foregroundColor: Color = .white, foregroundPressedColor: Color = .black, strokeColor: Color = .black) {
        self.color = color
        self.pressedColor = pressedColor
        self.foregroundColor = foregroundColor
        self.foregroundPressedColor = foregroundPressedColor
        self.strokeColor = strokeColor
    }
}

class DefaultColors {
    static let regular = DefaultColorConfig(
        color: Color(uiColor: .secondarySystemFill), pressedColor: Color(uiColor: .secondaryLabel),
        foregroundColor: Color(uiColor: .label), foregroundPressedColor: Color(uiColor: .systemBackground),
        strokeColor: Color(uiColor: .label)
    )
    
    static let joystick = DefaultColorConfig(
        color: Color(uiColor: .secondarySystemFill),
        foregroundColor: Color(uiColor: .darkGray),
        strokeColor: Color(uiColor: .secondaryLabel)
    )
    
    static let dpad = DefaultColorConfig(
        color: Color(uiColor: .secondarySystemFill),
        foregroundColor: Color(uiColor: .label), foregroundPressedColor: Color(uiColor: .systemBackground),
        strokeColor: Color(uiColor: .label)
    )
}
