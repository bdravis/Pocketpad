//
//  RegularButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import Foundation
import SwiftUICore

// encapsulating button shape
enum RegularButtonShape: String, ConfigType, CaseIterable {
    case Circle = "Circle"
    case Pill = "Pill"
    case SlantedPill = "Slanted Pill"
}

// the type of icon to display
enum RegularButtonIconType: String, ConfigType, CaseIterable {
    case Text = "Text"
    case SFSymbol = "SF Symbol"
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
