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
            
            // set light mode
            self.bgColorL = btn.style.properties.lightModeColors.color ?? Color(uiColor: .secondarySystemFill)
            self.bgPressedColorL = btn.style.properties.lightModeColors.pressedColor ?? Color(uiColor: .secondaryLabel)
            self.fgColorL = btn.style.properties.lightModeColors.foregroundColor ?? Color(uiColor: .label)
            self.fgPressedColorL = btn.style.properties.lightModeColors.foregroundPressedColor ?? Color(uiColor: .systemBackground)
            
            // set dark mode
            self.bgColorD = btn.style.properties.darkModeColors.color ?? Color(uiColor: .secondarySystemFill)
            self.bgPressedColorD = btn.style.properties.darkModeColors.pressedColor ?? Color(uiColor: .secondaryLabel)
            self.fgColorD = btn.style.properties.darkModeColors.foregroundColor ?? Color(uiColor: .label)
            self.fgPressedColorD = btn.style.properties.darkModeColors.foregroundPressedColor ?? Color(uiColor: .systemBackground)
            
            self.stroke = btn.style.properties.borderThickness
        } else if let btn = config as? JoystickConfig {
            // set light mode
            self.bgColorL = btn.style.lightModeColors.color ?? Color(uiColor: .secondarySystemFill)
            self.fgColorL = btn.style.lightModeColors.foregroundColor ?? Color(uiColor: .darkGray)
            
            // set dark mode
            self.bgColorD = btn.style.darkModeColors.color ?? Color(uiColor: .secondarySystemFill)
            self.fgColorD = btn.style.darkModeColors.foregroundColor ?? Color(uiColor: .darkGray)
            
            self.stroke = btn.style.borderThickness
        } else if let btn = config as? DPadConfig {
            // set light mode
            self.bgColorL = btn.style.lightModeColors.color ?? Color(uiColor: .secondarySystemFill)
            self.fgColorL = btn.style.lightModeColors.foregroundColor ?? Color(uiColor: .label)
            self.fgPressedColorL = btn.style.lightModeColors.foregroundPressedColor ?? Color(uiColor: .systemBackground)
            
            // set dark mode
            self.bgColorD = btn.style.darkModeColors.color ?? Color(uiColor: .secondarySystemFill)
            self.fgColorD = btn.style.darkModeColors.foregroundColor ?? Color(uiColor: .label)
            self.fgPressedColorD = btn.style.darkModeColors.foregroundPressedColor ?? Color(uiColor: .systemBackground)
            
            self.stroke = btn.style.borderThickness
        } else if let btn = config as? BumperConfig {
            self.input = btn.input
        } else if let btn = config as? TriggerConfig {
            self.input = btn.input
            self.triggerSide = btn.side
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
    
    func applyToButton(_ button: inout ButtonConfig) {
        button.position.scaledPos = self.scaledPos
        button.position.offset = self.offset
        button.scale = self.scale
        button.rotation = self.rotation
        
        if button.type == .regular {
            // set the regular button style
            button.updateStyle(to: RegularButtonStyle(shape: self.shape, iconType: self.iconType, icon: self.hasIcon ? self.icon : nil, properties: getGeneralStyle()))
        } else if button.type == .joystick || button.type == .dpad {
            // set the general button style
            button.updateStyle(to: getGeneralStyle())
        }
    }
    
    func asButtonConfig() -> ButtonConfig {
        switch self.type {
        case .regular:
            return RegularButtonConfig(
                position: .init(scaledPos: self.scaledPos, offset: self.offset),
                scale: self.scale, rotation: rotation,
                inputId: self.inputId, input: self.input,
                style: .init(shape: self.shape, iconType: self.iconType, icon: self.hasIcon ? self.icon : nil, properties: getGeneralStyle())
            )
        case .joystick:
            return JoystickConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, style: getGeneralStyle(), inputId: self.inputId, input: .RightJoystick)
        case .dpad:
            return DPadConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, style: getGeneralStyle(), inputId: self.inputId, inputs: [:])
        case .bumper:
            return BumperConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, input: self.input)
        case .trigger:
            return TriggerConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, input: self.input, side: self.triggerSide)
        }
    }
}
