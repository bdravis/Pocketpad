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
    
    // Regular Button styling
    @Published var shape: RegularButtonShape = .Circle
    @Published var iconType: RegularButtonIconType = .Text
    @Published var icon: String = ""
    @Published var hasIcon: Bool = true
    
    // Style properties
    @Published var bgColor: Color = .white
    @Published var bgPressedColor: Color = .black
    @Published var fgColor: Color = .black
    @Published var fgPressedColor: Color = .white
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
            
            self.bgColor = btn.style.properties.color ?? Color(uiColor: .secondarySystemFill)
            self.bgPressedColor = btn.style.properties.pressedColor ?? Color(uiColor: .secondaryLabel)
            self.fgColor = btn.style.properties.foregroundColor ?? Color(uiColor: .label)
            self.fgPressedColor = btn.style.properties.foregroundPressedColor ?? Color(uiColor: .systemBackground)
            self.stroke = btn.style.properties.borderThickness
        }
    }
    
    func clear() {
        self.isEmpty = true
    }
    
    private func getGeneralStyle() -> GeneralButtonStyle {
        return GeneralButtonStyle(color: self.bgColor, pressedColor: self.bgPressedColor, borderThickness: self.stroke, foregroundColor: self.fgColor, foregroundPressedColor: self.fgPressedColor)
    }
    
    func applyToButton(_ button: inout ButtonConfig) {
        button.position.scaledPos = self.scaledPos
        button.position.offset = self.offset
        button.scale = self.scale
        button.rotation = self.rotation
        
        if button.type == .regular {
            // set the regular button style
            button.updateStyle(to: RegularButtonStyle(shape: self.shape, iconType: self.iconType, icon: self.hasIcon ? self.icon : nil, properties: getGeneralStyle()))
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
            return JoystickConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, input: .RightJoystick)
        case .dpad:
            return DPadConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, inputs: [:])
        case .bumper:
            return BumperConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, input: .LB)
        case .trigger:
            return TriggerConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, input: .LT, side: .left)
        }
    }
}
