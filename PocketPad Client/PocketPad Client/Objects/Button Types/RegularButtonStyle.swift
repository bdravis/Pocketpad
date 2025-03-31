//
//  RegularButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import Foundation
import SwiftUICore

// encapsulating button shape
enum RegularButtonShape: ConfigType {
    case Circle
    case Pill
}

// the type of icon to display
enum RegularButtonIconType: ConfigType {
    case Text
    case SFSymbol
}

// settings to configure how the button looks
struct RegularButtonStyle: ConfigType {
    var shape: RegularButtonShape // the shape of the button on the view
    var iconType: RegularButtonIconType // what type of icon to show on top of that button
    var icon: String? // icon to show, either text, systemName, or resource name. If nil, then there will be no icon
    
    var properties: GeneralButtonStyle
    
    init(shape: RegularButtonShape, iconType: RegularButtonIconType, icon: String? = nil, properties: GeneralButtonStyle = .init()) {
        self.shape = shape
        self.iconType = iconType
        self.icon = icon
        self.properties = properties
    }
}

// settings to configure the general button style
struct GeneralButtonStyle: ConfigType {
    var color: Color?
    var pressedColor: Color?
    var borderThickness: CGFloat
    var foregroundColor: Color?
    var foregroundPressedColor: Color?
    
    init(
        color: Color? = nil, pressedColor: Color? = nil,
        borderThickness: CGFloat = 3,
        foregroundColor: Color? = nil, foregroundPressedColor: Color? = nil
    ) {
        self.color = color
        self.pressedColor = pressedColor
        self.borderThickness = borderThickness
        self.foregroundColor = foregroundColor
        self.foregroundPressedColor = foregroundPressedColor
    }
}
