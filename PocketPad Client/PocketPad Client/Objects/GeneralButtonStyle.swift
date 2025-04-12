//
//  GeneralButtonStyle.swift
//  PocketPad Client
//
//  Created by lemin on 4/11/25.
//

import SwiftUICore

struct ColorConfig: ConfigType {
    var color: Color?
    var pressedColor: Color?
    
    var foregroundColor: Color?
    var foregroundPressedColor: Color?
    
    var strokeColor: Color?
}

// settings to configure the general button style
struct GeneralButtonStyle: ConfigType {
    var borderThickness: CGFloat
    var lightModeColors: ColorConfig
    var darkModeColors: ColorConfig
    
    init(
        color: Color? = nil, pressedColor: Color? = nil,
        borderThickness: CGFloat = 3, strokeColor: Color? = nil,
        foregroundColor: Color? = nil, foregroundPressedColor: Color? = nil
    ) {
        self.borderThickness = borderThickness
        // dark and light mode are the same
        let colConf: ColorConfig = .init(color: color, pressedColor: pressedColor, foregroundColor: foregroundColor, foregroundPressedColor: foregroundPressedColor, strokeColor: strokeColor)
        self.lightModeColors = colConf
        self.darkModeColors = colConf
    }
    
    init(lightModeColors: ColorConfig, darkModeColors: ColorConfig, borderThickness: CGFloat = 3) {
        self.lightModeColors = lightModeColors
        self.darkModeColors = darkModeColors
        self.borderThickness = borderThickness
    }
}
