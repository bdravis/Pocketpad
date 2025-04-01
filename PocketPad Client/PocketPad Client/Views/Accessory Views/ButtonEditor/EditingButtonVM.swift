//
//  EditingButtonVM.swift
//  PocketPad Client
//
//  Created by lemin on 3/31/25.
//

import SwiftUI

class EditingButtonVM: ObservableObject {
    @Published var isEmpty: Bool
    
    @Published var scaledPos: CGPoint = CGPointZero
    @Published var offset: CGPoint = CGPointZero
    @Published var scale: CGFloat = 0.0
    @Published var rotation: Double = 0.0
    
    @Published var inputId: UInt8 = 0
    @Published var type: ButtonType = .regular
    
    init() {
        self.isEmpty = true
    }
    
    func setButton(to config: ButtonConfig) {
        self.isEmpty = false
        
        self.scaledPos = config.position.scaledPos
        self.offset = config.position.offset
        self.scale = config.scale
        self.rotation = config.rotation
        
        self.inputId = config.inputId
        self.type = config.type
    }
    
    func clear() {
        self.isEmpty = true
    }
    
    func applyToButton(_ button: inout ButtonConfig) {
        button.position.scaledPos = self.scaledPos
        button.position.offset = self.offset
        button.scale = self.scale
        button.rotation = self.rotation
    }
    
    func asButtonConfig() -> ButtonConfig {
        switch self.type {
        case .regular:
            return RegularButtonConfig(position: .init(scaledPos: self.scaledPos, offset: self.offset), scale: self.scale, rotation: rotation, inputId: self.inputId, input: .A)
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
