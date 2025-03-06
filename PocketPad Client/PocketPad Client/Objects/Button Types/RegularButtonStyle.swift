//
//  RegularButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 3/1/25.
//

import Foundation

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
}
