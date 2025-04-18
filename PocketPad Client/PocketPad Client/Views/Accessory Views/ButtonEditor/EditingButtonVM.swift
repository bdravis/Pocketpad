//
//  EditingButtonVM.swift
//  PocketPad Client
//
//  Created by lemin on 3/31/25.
//

import SwiftUI

class EditingButtonVM: ObservableObject {
    @Published var isEmpty: Bool
    
    // General Protocol values
    @Published var scaledPos: CGPoint = CGPointZero
    @Published var offset: CGPoint = CGPointZero
    @Published var overriding: Bool = false
    @Published var defaultIsPortrait: Bool = false
    @Published var overrideScaledPos: CGPoint = CGPointZero
    @Published var overrideOffset: CGPoint = CGPointZero
    
    @Published var scale: CGFloat = 0.0
    @Published var rotation: Double = 0.0
    
    @Published var inputId: UInt8 = 0
    @Published var type: ButtonType = .regular
    
    @Published var input: ButtonInput = .A
    @Published var triggerSide: TriggerSide = .left
    
    // Regular Button styling
    @Published var shape: RegularButtonShape = .Circle
    @Published var iconType: RegularButtonIconType = .Text
    @Published var icon: String = ""
    @Published var hasIcon: Bool = true
    
    // Style properties
    /* Light Mode */
    @Published var bgColorL: Color = .white
    @Published var bgPressedColorL: Color = .black
    @Published var fgColorL: Color = .black
    @Published var fgPressedColorL: Color = .white
    @Published var strokeColorL: Color = .black
    /* Dark Mode */
    @Published var bgColorD: Color = .black
    @Published var bgPressedColorD: Color = .white
    @Published var fgColorD: Color = .white
    @Published var fgPressedColorD: Color = .black
    @Published var strokeColorD: Color = .white
    
    @Published var stroke: CGFloat = 3
    
    init() {
        self.isEmpty = true
    }
    
    func setButton(to config: ButtonConfig) {
        self.isEmpty = false
        
        // Set the general protocol values
        self.scaledPos = config.position.scaledPos
        self.offset = config.position.offset
        self.overriding = config.position.defaultIsPortrait != nil
        self.defaultIsPortrait = config.position.defaultIsPortrait ?? false
        self.overrideScaledPos = config.position.overrideScaledPos ?? CGPointZero
        self.overrideOffset = config.position.overrideOffset ?? CGPointZero
        
        self.scale = config.scale
        self.rotation = config.rotation
        
        self.inputId = config.inputId
        self.type = config.type
        
        // Set the regular button style
        if let btn = config as? RegularButtonConfig {
            self.input = btn.input
            self.shape = btn.style.shape
            self.iconType = btn.style.iconType
            self.hasIcon = btn.style.icon != nil
            self.icon = btn.style.icon ?? ""
            
            let defCols = DefaultColors.regular
            
            // set light mode
            self.bgColorL = btn.style.properties.lightModeColors.color ?? defCols.color
            self.bgPressedColorL = btn.style.properties.lightModeColors.pressedColor ?? defCols.pressedColor
            self.fgColorL = btn.style.properties.lightModeColors.foregroundColor ?? defCols.foregroundColor
            self.fgPressedColorL = btn.style.properties.lightModeColors.foregroundPressedColor ?? defCols.foregroundPressedColor
            self.strokeColorL = btn.style.properties.lightModeColors.strokeColor ?? defCols.strokeColor
            
            // set dark mode
            self.bgColorD = btn.style.properties.darkModeColors.color ?? defCols.color
            self.bgPressedColorD = btn.style.properties.darkModeColors.pressedColor ?? defCols.pressedColor
            self.fgColorD = btn.style.properties.darkModeColors.foregroundColor ?? defCols.foregroundColor
            self.fgPressedColorD = btn.style.properties.darkModeColors.foregroundPressedColor ?? defCols.foregroundPressedColor
            self.strokeColorD = btn.style.properties.darkModeColors.strokeColor ?? defCols.strokeColor
            
            self.stroke = btn.style.properties.borderThickness
        } else if let btn = config as? JoystickConfig {
            let defCols = DefaultColors.joystick
            // set light mode
            self.bgColorL = btn.style.lightModeColors.color ?? defCols.color
            self.fgColorL = btn.style.lightModeColors.foregroundColor ?? defCols.foregroundColor
            self.strokeColorL = btn.style.lightModeColors.strokeColor ?? defCols.strokeColor
            
            // set dark mode
            self.bgColorD = btn.style.darkModeColors.color ?? defCols.color
            self.fgColorD = btn.style.darkModeColors.foregroundColor ?? defCols.foregroundColor
            self.strokeColorD = btn.style.darkModeColors.strokeColor ?? defCols.strokeColor
            
            self.stroke = btn.style.borderThickness
        } else if let btn = config as? DPadConfig {
            let defCols = DefaultColors.dpad
            // set light mode
            self.bgColorL = btn.style.lightModeColors.color ?? defCols.color
            self.fgColorL = btn.style.lightModeColors.foregroundColor ?? defCols.foregroundColor
            self.fgPressedColorL = btn.style.lightModeColors.foregroundPressedColor ?? defCols.foregroundPressedColor
            self.strokeColorL = btn.style.lightModeColors.strokeColor ?? defCols.strokeColor
            
            // set dark mode
            self.bgColorD = btn.style.darkModeColors.color ?? defCols.color
            self.fgColorD = btn.style.darkModeColors.foregroundColor ?? defCols.foregroundColor
            self.fgPressedColorD = btn.style.darkModeColors.foregroundPressedColor ?? defCols.foregroundPressedColor
            self.strokeColorD = btn.style.darkModeColors.strokeColor ?? defCols.strokeColor
            
            self.stroke = btn.style.borderThickness
        } else if let btn = config as? TriggerConfig {
            self.input = btn.input
            self.triggerSide = btn.side
            
            let defCols = DefaultColors.trigger
            
            // set light mode
            self.bgColorL = btn.style.lightModeColors.color ?? defCols.color
            self.bgPressedColorL = btn.style.lightModeColors.pressedColor ?? defCols.pressedColor
            self.fgColorL = btn.style.lightModeColors.foregroundColor ?? defCols.foregroundColor
            self.fgPressedColorL = btn.style.lightModeColors.foregroundPressedColor ?? defCols.foregroundPressedColor
            self.strokeColorL = btn.style.lightModeColors.strokeColor ?? defCols.strokeColor
            
            // set dark mode
            self.bgColorD = btn.style.darkModeColors.color ?? defCols.color
            self.bgPressedColorD = btn.style.darkModeColors.pressedColor ?? defCols.pressedColor
            self.fgColorD = btn.style.darkModeColors.foregroundColor ?? defCols.foregroundColor
            self.fgPressedColorD = btn.style.darkModeColors.foregroundPressedColor ?? defCols.foregroundPressedColor
            self.strokeColorD = btn.style.darkModeColors.strokeColor ?? defCols.strokeColor
            
            self.stroke = btn.style.borderThickness
        }
    }
    
    func clear() {
        self.isEmpty = true
    }
    
    private func getGeneralStyle() -> GeneralButtonStyle {
        return GeneralButtonStyle(
            lightModeColors: .init(color: self.bgColorL, pressedColor: self.bgPressedColorL, foregroundColor: self.fgColorL, foregroundPressedColor: self.fgPressedColorL, strokeColor: self.strokeColorL),
            darkModeColors: .init(color: self.bgColorD, pressedColor: self.bgPressedColorD, foregroundColor: self.fgColorD, foregroundPressedColor: self.fgPressedColorD, strokeColor: self.strokeColorD),
            borderThickness: self.stroke
        )
    }
    
    func getPos() -> ButtonPosition {
        return ButtonPosition(
            scaledPos: self.scaledPos, offset: self.offset,
            defaultIsPortrait: self.overriding ? self.defaultIsPortrait : nil,
            overrideScaledPos: self.overriding ? self.overrideScaledPos : nil,
            overrideOffset: self.overriding ? self.overrideOffset : nil
        )
    }
    
    func applyToButton(_ button: inout ButtonConfig) {
        button.position = getPos()
        button.scale = self.scale
        button.rotation = self.rotation
        
        if button.type == .regular || button.type == .bumper {
            // set the regular button style
            button.updateStyle(to: RegularButtonStyle(shape: self.shape, iconType: self.iconType, icon: self.hasIcon ? self.icon : nil, properties: getGeneralStyle()))
        } else if button.type == .joystick || button.type == .dpad {
            // set the general button style
            button.updateStyle(to: getGeneralStyle())
        } else if button.type == .trigger {
            // set the general button style and the trigger side
            button.updateStyle(to: getGeneralStyle())
            button.updateValue(name: "side", to: self.triggerSide)
        }
    }
    
    func asButtonConfig() -> ButtonConfig {
        switch self.type {
        case .regular, .bumper:
            return RegularButtonConfig(type: self.type,
                position: getPos(),
                scale: self.scale, rotation: rotation,
                inputId: self.inputId, input: self.input,
                style: .init(shape: self.shape, iconType: self.iconType, icon: self.hasIcon ? self.icon : nil, properties: getGeneralStyle())
            )
        case .joystick:
            return JoystickConfig(position: getPos(), scale: self.scale, rotation: rotation, style: getGeneralStyle(), inputId: self.inputId, input: .RightJoystick)
        case .dpad:
            return DPadConfig(position: getPos(), scale: self.scale, rotation: rotation, style: getGeneralStyle(), inputId: self.inputId, inputs: [:])
        case .trigger:
            return TriggerConfig(position: getPos(), scale: self.scale, rotation: rotation, style: getGeneralStyle(), inputId: self.inputId, input: self.input, side: self.triggerSide)
        }
    }
}
