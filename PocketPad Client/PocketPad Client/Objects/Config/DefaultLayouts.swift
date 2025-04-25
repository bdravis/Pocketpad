//
//  DefaultLayouts.swift
//  PocketPad Client
//
//  Created by lemin on 3/4/25.
//

import UIKit
import SwiftUI

// TODO: Figure out how to force this to initialize with button.type = .bumper
typealias BumperConfig = RegularButtonConfig //where BumperConfig.type == ButtonType.bumper

class DefaultLayouts {
    // MARK: Switch Configuration
    static let SwitchConfig: LayoutConfig = .init(name: "Switch", buttons: [
        // Diamond of buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 0, input: .X),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 1, input: .Y),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 2, input: .A),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 3, input: .B),
        
        // Right Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.65, y: 0.75)), scale: 2.5, inputId: 4, input: .RightJoystick),
        
        // DPad
        DPadConfig(
            position: .init(scaledPos: CGPoint(x: 0.4, y: 0.8)), scale: 2.25, inputId: 5,
            inputs: [
                .up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.15, y: 0.75)), scale: 2.5, inputId: 6, input: .LeftJoystick),
        
        // Menu
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE * 1.4, y: -DEFAULT_BUTTON_SIZE * 0.5)), scale: 0.8, inputId: 7, input: .Start, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "plus")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: DEFAULT_BUTTON_SIZE * 1.4, y: -DEFAULT_BUTTON_SIZE * 0.5)), scale: 0.8, inputId: 8, input: .Select, style: .init(shape: .Circle, iconType: .Text, icon: "-")),
        
        // Home/Screenshot
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE * 0.7, y: DEFAULT_BUTTON_SIZE * 0.7)), scale: 0.8, inputId: 9, input: .Home, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "house")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: DEFAULT_BUTTON_SIZE * 0.7, y: DEFAULT_BUTTON_SIZE * 0.7)), scale: 0.8, inputId: 10, input: .Share, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square")),
        
        // Bumpers
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1), offset: CGPoint(x: DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 10, input: .LB),
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 11, input: .RB),
        
        // Triggers
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1)), scale: 1.5, inputId: 12, input: .LT, side: .left),
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1)), scale: 1.5, inputId: 13, input: .RT, side: .right),
    ])
    
    // MARK: Xbox Configuration
    static let XboxConfig: LayoutConfig = .init(name: "Xbox", buttons: [
        // Diamond of buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 0, input: .Y),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 1, input: .X),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 2, input: .B),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.7), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 3, input: .A),

        // Right Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.65, y: 0.8)), scale: 2.5, inputId: 4, input: .RightJoystick),

        // DPad
        DPadConfig(
            position: .init(scaledPos: CGPoint(x: 0.4, y: 0.8)), scale: 2.25, inputId: 5,
            inputs: [
                .up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.15, y: 0.75)), scale: 2.5, inputId: 6, input: .LeftJoystick),
        
        // Menu
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE * 0.85, y: 0)), scale: 0.8, inputId: 7, input: .Start, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: DEFAULT_BUTTON_SIZE * 0.85, y: 0)), scale: 0.8, inputId: 8, input: .Select, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "macwindow.on.rectangle")),
        
        // Share
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE * 0.85)), scale: 0.8, inputId: 9, input: .Share, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square.and.arrow.up")),
        
        // Bumpers
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1), offset: CGPoint(x: DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 10, input: .LB),
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 11, input: .RB),
        
        // Triggers
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1)), scale: 1.5, inputId: 12, input: .LT, side: .left),
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1)), scale: 1.5, inputId: 13, input: .RT, side: .right),
    ])
    
    // MARK: PlayStation Config
    static let PlayStationConfig: LayoutConfig = .init(name: "PlayStation", buttons: [
        // Diamond of buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.85, y: 0.7), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 0, input: .Y, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "triangle")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.85, y: 0.7), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 1, input: .X, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.85, y: 0.7), offset: CGPoint(x: DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 2, input: .B, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "circle")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.85, y: 0.7), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 3, input: .A, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "xmark")),
        
        // Right Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.62, y: 0.8)), scale: 2.5, inputId: 4, input: .RightJoystick),
        
        // DPad
        DPadConfig(
            position: .init(scaledPos: CGPoint(x: 0.15, y: 0.65)), scale: 2.25, inputId: 5,
            inputs: [
                .up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.38, y: 0.8)), scale: 2.5, inputId: 6, input: .LeftJoystick),
        
        // Menu
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE * 0.8, y: 0)), scale: 0.8, inputId: 7, input: .Start, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: DEFAULT_BUTTON_SIZE * 0.8, y: 0)), scale: 0.8, inputId: 8, input: .Select, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "light.max")),
        
        // Bumpers
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1), offset: CGPoint(x: DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 10, input: .LB),
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 11, input: .RB),
        
        // Triggers
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1)), scale: 1.5, inputId: 12, input: .LT, side: .left),
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1)), scale: 1.5, inputId: 13, input: .RT, side: .right),
    ])

    // MARK: Wii Config
    static let WiiConfig: LayoutConfig = .init(name: "Wii", lockToOrientation: .all, buttons: [
        // Diamond of buttons
        RegularButtonConfig(position: .init(
            scaledPos: CGPoint(x: 0.5, y: 0.8), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE),
            defaultIsPortrait: true,
            overrideScaledPos: CGPoint(x: 0.5, y: 0.75), overrideOffset: CGPoint(x: -40, y: 0)
        ), scale: 1.0, inputId: 0, input: .One),
        RegularButtonConfig(position: .init(
            scaledPos: CGPoint(x: 0.5, y: 0.8), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE),
            defaultIsPortrait: true,
            overrideScaledPos: CGPoint(x: 0.5, y: 0.75), overrideOffset: CGPoint(x: 40, y: 0)
        ), scale: 1.0, inputId: 1, input: .Two),
        RegularButtonConfig(position: .init(
            scaledPos: CGPoint(x: 0.5, y: 0.35),
            defaultIsPortrait: true,
            overrideScaledPos: CGPoint(x: 0.75, y: 0.7), overrideOffset: CGPointZero
        ), scale: 1.75, inputId: 2, input: .A),
        TriggerConfig(position: .init(
            scaledPos: CGPoint(x: 0.8, y: 0.35),
            defaultIsPortrait: true,
            overrideScaledPos: CGPoint(x: 0.87, y: 0.45), overrideOffset: CGPointZero
        ), scale: 1.75, inputId: 3, input: .B, side: .middle),
        
        // DPad
        DPadConfig(
            position: .init(
                scaledPos: CGPoint(x: 0.5, y: 0.13),
                defaultIsPortrait: true,
                overrideScaledPos: CGPoint(x: 0.15, y: 0.75), overrideOffset: CGPointZero
            ), scale: 2.5, inputId: 4,
            inputs: [
                .up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft
            ]
        ),
        
        // Menu
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE * 1.5, y: 0)), scale: 0.8, inputId: 5, input: .Start, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "plus")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5), offset: CGPoint(x: DEFAULT_BUTTON_SIZE * 1.5, y: 0)), scale: 0.8, inputId: 6, input: .Select, style: .init(shape: .Circle, iconType: .Text, icon: "-")),
        
        // Home/Screenshot
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5)), scale: 0.8, inputId: 7, input: .Home, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "house")),
    ])
    
    // MARK: GameCube Config
    static let GameCubeConfig: LayoutConfig = .init(name: "GameCube", buttons: [
        // Left Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.15, y: 0.45)), scale: 2.5, inputId: 0, input: .LeftJoystick),
        
        // DPad
        DPadConfig(
            position: .init(scaledPos: CGPoint(x: 0.3, y: 0.75)), scale: 2.25, inputId: 1,
            inputs: [
                .up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft
            ]
        ),
        
        // Start
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.3)), scale: 0.8, inputId: 2, input: .Start, style: .init(shape: .Circle, iconType: .Text, icon: "+")),
        
        // Right Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.6, y: 0.8)), scale: 2.5, style: .init(color: Color(hex: "F7CE46"), foregroundColor: Color(hex: "8C8629")), inputId: 3, input: .RightJoystick),
        
        // A and B Buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.35)), scale: 1.5, inputId: 4, input: .A, style: .init(shape: .Circle, iconType: .Text, icon: "A", properties: .init(color: Color(hex: "64C466"), pressedColor: Color(hex: "729C44")))),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.35), offset: CGPoint(x: -68, y: 56.5)), scale: 0.8, inputId: 5, input: .B, style: .init(shape: .Circle, iconType: .Text, icon: "B", properties: .init(color: Color(hex: "EB4D3D"), pressedColor: Color(hex: "781E0E")))),
        
        // X and Y Buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.35), offset: CGPoint(x: -20.5, y: -70)), scale: 1.2, rotation: -12, inputId: 6, input: .Y, style: .init(shape: .SlantedPill, iconType: .Text, icon: "Y")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.35), offset: CGPoint(x: 72.5, y: -9)), scale: 1.2, rotation: 84, inputId: 7, input: .X, style: .init(shape: .SlantedPill, iconType: .Text, icon: "X")),
        
        // Triggers
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.05, y: 0.1)), scale: 1.2, inputId: 8, input: .LT, side: .left),
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.95, y: 0.1)), scale: 1.2, inputId: 9, input: .RT, side: .right),
        
        // Z
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.65, y: 0.05)), scale: 1.2, inputId: 10, input: .Z, style: .init(shape: .Pill, iconType: .Text, icon: "Z", properties: .init(color: Color(hex: "280B72"), pressedColor: Color(hex: "180B4F"))))
    ]) // 24x24   50x50
    
    // MARK: DPad-less Test
    static let DPadlessTest: LayoutConfig = .init(name: "DPad-less Test", buttons: [
        // Diamond of buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 0, input: .X),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 1, input: .Y),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 2, input: .A),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 3, input: .B),
        
        // Right Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.6, y: 0.7)), scale: 1.5, inputId: 4, input: .RightJoystick)
    ])
    
    // MARK: Turbo Test
    static let TurboTest: LayoutConfig = .init(name: "Turbo", buttons: [
        // Diamond of buttons
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 0, input: .Y),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 1, input: .X),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 2, input: .B),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.6), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 3, input: .A),

        // Right Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.6, y: 0.8)), scale: 1.5, inputId: 4, input: .RightJoystick),

        // DPad
        DPadConfig(
            position: .init(scaledPos: CGPoint(x: 0.4, y: 0.8)), scale: 1.5, inputId: 5,
            inputs: [
                .up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.2, y: 0.6)), scale: 1.5, inputId: 6, input: .LeftJoystick),
        
        // Menu
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE * 0.6, y: 0)), scale: 0.6, inputId: 7, input: .Start, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: DEFAULT_BUTTON_SIZE * 0.6, y: 0)), scale: 0.6, inputId: 8, input: .Select, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "macwindow.on.rectangle")),
        
        // Share
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.2), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE * 0.6)), scale: 0.6, inputId: 9, input: .Share, style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square.and.arrow.up")),
        
        // Bumpers
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1), offset: CGPoint(x: DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 10, input: .LB),
        BumperConfig(type: .bumper, position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE / 2, y: DEFAULT_BUTTON_SIZE * 1.5)), scale: 1.5, inputId: 11, input: .RB),
        
        // Triggers
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.1, y: 0.1)), scale: 1.5, inputId: 12, input: .LT, side: .left),
        TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.9, y: 0.1)), scale: 1.5, inputId: 13, input: .RT, side: .right),
        
        // Turbo Button
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.3, y: 0.3), offset: CGPoint(x: 0, y: 0)), scale: 1.5, inputId: 14, input: .Turbo, turbo: true),
    ])
    
    static let MouseKeyboardLayout: LayoutConfig = .init(name: "Mouse & Keyboard", lockToOrientation: .all, buttons: [
        JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.29, y: 0.17)), scale: 3, inputId: 0, input: .Mouse),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.59, y: 0.12)), scale: 1.3, inputId: 1, input: .MouseLeft, style: .init(shape: .Circle, iconType: .Text, icon: "Left")),
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.83, y: 0.23)), scale: 1.3, inputId: 2, input: .MouseRight, style: .init(shape: .Circle, iconType: .Text, icon: "Right")),
        
        RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.2, y: 0.5)), scale: 1, inputId: 3, input: .Keyboard)
    ])
    
    
    static func getLayout(for name: ControllerType) -> LayoutConfig {
        switch name {
        case .Xbox:
            return XboxConfig
        case .PlayStation:
            return PlayStationConfig
        case .Wii:
            return WiiConfig
        case .GameCube:
            return GameCubeConfig
        case .Switch:
            return SwitchConfig
        case .DPadless:
            return DPadlessTest
        case .Turbo:
            return TurboTest
        case .MouseKeyboard:
            return MouseKeyboardLayout
        }
    }
    
    static func isDefaultLayout(name: String) -> Bool {
        return (name == XboxConfig.name || name == PlayStationConfig.name || name == WiiConfig.name || name == SwitchConfig.name || name == DPadlessTest.name || name == GameCubeConfig.name || name == TurboTest.name || name == MouseKeyboardLayout.name)
    }
}

//#Preview {
//    ControllerView(layout: DefaultLayouts.getLayout(for: .Xbox), isEditor: false)
//}
