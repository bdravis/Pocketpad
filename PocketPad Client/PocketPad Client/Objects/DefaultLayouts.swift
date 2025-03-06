//
//  DefaultLayouts.swift
//  PocketPad Client
//
//  Created by lemin on 3/4/25.
//

import UIKit

class DefaultLayouts {
    // MARK: Switch Configuration
    static let SwitchConfig: LayoutConfig = .init(name: "Switch", landscapeButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 650, y: 150), scale: 0.75, inputId: 0, input: "X"),
        RegularButtonConfig(position: CGPoint(x: 600, y: 200), scale: 0.75, inputId: 1, input: "Y"),
        RegularButtonConfig(position: CGPoint(x: 700, y: 200), scale: 0.75, inputId: 2, input: "A"),
        RegularButtonConfig(position: CGPoint(x: 650, y: 250), scale: 0.75, inputId: 3, input: "B"),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 450, y: 300), scale: 1.5, inputId: 4, input: "RightJoystick"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 250, y: 300), scale: 1.5, inputId: 5,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: CGPoint(x: 70, y: 200), scale: 1.5, inputId: 6, input: "LeftJoystick"),
        
        // Menu
        RegularButtonConfig(position: CGPoint(x: 450, y: 75), scale: 0.6, inputId: 7, input: "Start", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "plus")),
        RegularButtonConfig(position: CGPoint(x: 250, y: 75), scale: 0.6, inputId: 8, input: "Select", style: .init(shape: .Circle, iconType: .Text, icon: "-")),
        
        // Home/Screenshot
        RegularButtonConfig(position: CGPoint(x: 400, y: 140), scale: 0.6, inputId: 9, input: "Home", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "house")),
        RegularButtonConfig(position: CGPoint(x: 300, y: 140), scale: 0.6, inputId: 10, input: "Screenshot", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square"))
    ], portraitButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 300, y: 500), scale: 0.75, inputId: 0, input: "X"),
        RegularButtonConfig(position: CGPoint(x: 250, y: 550), scale: 0.75, inputId: 1, input: "Y"),
        RegularButtonConfig(position: CGPoint(x: 350, y: 550), scale: 0.75, inputId: 2, input: "A"),
        RegularButtonConfig(position: CGPoint(x: 300, y: 600), scale: 0.75, inputId: 3, input: "B"),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 240, y: 680), scale: 1.5, inputId: 4, input: "RightJoystick"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 80, y: 650), scale: 1.5, inputId: 5,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: CGPoint(x: 90, y: 525), scale: 1.5, inputId: 6, input: "LeftJoystick"),
        
        // Start/Select
        RegularButtonConfig(position: CGPoint(x: 240, y: 250), scale: 0.6, inputId: 7, input: "Start", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "plus")),
        RegularButtonConfig(position: CGPoint(x: 160, y: 250), scale: 0.6, inputId: 8, input: "Select", style: .init(shape: .Circle, iconType: .Text, icon: "-")),
        
        // Home/Screenshot
        RegularButtonConfig(position: CGPoint(x: 230, y: 300), scale: 0.6, inputId: 9, input: "Home", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "house")),
        RegularButtonConfig(position: CGPoint(x: 170, y: 300), scale: 0.6, inputId: 10, input: "Screenshot", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square"))
    ])
    
    // MARK: Xbox Configuration
    static let XboxConfig: LayoutConfig = .init(name: "Xbox", landscapeButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 650, y: 150), scale: 0.75, inputId: 0, input: "Y"),
        RegularButtonConfig(position: CGPoint(x: 600, y: 200), scale: 0.75, inputId: 1, input: "X"),
        RegularButtonConfig(position: CGPoint(x: 700, y: 200), scale: 0.75, inputId: 2, input: "B"),
        RegularButtonConfig(position: CGPoint(x: 650, y: 250), scale: 0.75, inputId: 3, input: "A"),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 450, y: 300), scale: 1.5, inputId: 4, input: "RightJoystick"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 250, y: 300), scale: 1.5, inputId: 5,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: CGPoint(x: 70, y: 200), scale: 1.5, inputId: 6, input: "LeftJoystick"),
        
        // Menu
        RegularButtonConfig(position: CGPoint(x: 400, y: 75), scale: 0.6, inputId: 7, input: "Menu", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: CGPoint(x: 300, y: 75), scale: 0.6, inputId: 8, input: "Window", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "macwindow.on.rectangle")),
        
        // Share
        RegularButtonConfig(position: CGPoint(x: 350, y: 120), scale: 0.6, inputId: 9, input: "Share", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square.and.arrow.up"))
    ], portraitButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 300, y: 500), scale: 0.75, inputId: 0, input: "Y"),
        RegularButtonConfig(position: CGPoint(x: 250, y: 550), scale: 0.75, inputId: 1, input: "X"),
        RegularButtonConfig(position: CGPoint(x: 350, y: 550), scale: 0.75, inputId: 2, input: "B"),
        RegularButtonConfig(position: CGPoint(x: 300, y: 600), scale: 0.75, inputId: 3, input: "A"),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 240, y: 680), scale: 1.5, inputId: 4, input: "RightJoystick"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 100, y: 680), scale: 1.5, inputId: 5,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: CGPoint(x: 70, y: 525), scale: 1.5, inputId: 6, input: "LeftJoystick"),
        
        // Menu
        RegularButtonConfig(position: CGPoint(x: 240, y: 250), scale: 0.6, inputId: 7, input: "Menu", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: CGPoint(x: 160, y: 250), scale: 0.6, inputId: 8, input: "Window", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "macwindow.on.rectangle")),
        
        // Share
        RegularButtonConfig(position: CGPoint(x: 200, y: 300), scale: 0.6, inputId: 9, input: "Share", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square.and.arrow.up"))
    ])
    
    // MARK: PlayStation Config
    static let PlayStationConfig: LayoutConfig = .init(name: "PlayStation", landscapeButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 650, y: 150), scale: 0.75, inputId: 0, input: "Triangle", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "triangle")),
        RegularButtonConfig(position: CGPoint(x: 600, y: 200), scale: 0.75, inputId: 1, input: "Square", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square")),
        RegularButtonConfig(position: CGPoint(x: 700, y: 200), scale: 0.75, inputId: 2, input: "Circle", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "circle")),
        RegularButtonConfig(position: CGPoint(x: 650, y: 250), scale: 0.75, inputId: 3, input: "X", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "xmark")),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 450, y: 300), scale: 1.5, inputId: 4, input: "RightJoystick"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 70, y: 200), scale: 1.5, inputId: 5,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: CGPoint(x: 250, y: 300), scale: 1.5, inputId: 6, input: "LeftJoystick"),
        
        // Menu
        RegularButtonConfig(position: CGPoint(x: 470, y: 75), scale: 0.6, inputId: 7, input: "Menu", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: CGPoint(x: 230, y: 75), scale: 0.6, inputId: 8, input: "Window", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "light.max"))
    ], portraitButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 300, y: 500), scale: 0.75, inputId: 0, input: "Triangle", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "triangle")),
        RegularButtonConfig(position: CGPoint(x: 250, y: 550), scale: 0.75, inputId: 1, input: "Square", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square")),
        RegularButtonConfig(position: CGPoint(x: 350, y: 550), scale: 0.75, inputId: 2, input: "Circle", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "circle")),
        RegularButtonConfig(position: CGPoint(x: 300, y: 600), scale: 0.75, inputId: 3, input: "X", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "xmark")),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 260, y: 680), scale: 1.5, inputId: 4, input: "RightJoystick"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 70, y: 525), scale: 1.5, inputId: 5,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Left Joystick
        JoystickConfig(position: CGPoint(x: 150, y: 680), scale: 1.5, inputId: 6, input: "LeftJoystick"),
        
        // Menu
        RegularButtonConfig(position: CGPoint(x: 240, y: 250), scale: 0.6, inputId: 7, input: "Menu", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "line.3.horizontal")),
        RegularButtonConfig(position: CGPoint(x: 160, y: 250), scale: 0.6, inputId: 8, input: "Window", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "light.max"))
    ])
    
    // MARK: Wii Config
    static let WiiConfig: LayoutConfig = .init(name: "Wii", landscapeButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 650, y: 150), scale: 0.75, inputId: 0, input: "1"),
        RegularButtonConfig(position: CGPoint(x: 600, y: 200), scale: 0.75, inputId: 1, input: "2"),
        RegularButtonConfig(position: CGPoint(x: 700, y: 200), scale: 0.75, inputId: 2, input: "A"),
        RegularButtonConfig(position: CGPoint(x: 650, y: 250), scale: 0.75, inputId: 3, input: "B"),
        
        // DPad
        DPadConfig(
            position: CGPoint(x: 125, y: 250), scale: 1.5, inputId: 4,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // Menu
        RegularButtonConfig(position: CGPoint(x: 450, y: 75), scale: 0.6, inputId: 5, input: "Start", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "plus")),
        RegularButtonConfig(position: CGPoint(x: 250, y: 75), scale: 0.6, inputId: 6, input: "Select", style: .init(shape: .Circle, iconType: .Text, icon: "-")),
        
        // Home/Screenshot
        RegularButtonConfig(position: CGPoint(x: 350, y: 140), scale: 0.6, inputId: 7, input: "Home", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "house"))
    ], portraitButtons: [
        // DPad
        DPadConfig(
            position: CGPoint(x: 200, y: 150), scale: 1.75, inputId: 0,
            inputs: [
                .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
            ]
        ),
        
        // A/B
        RegularButtonConfig(position: CGPoint(x: 200, y: 260), scale: 1.5, inputId: 1, input: "A"),
        RegularButtonConfig(position: CGPoint(x: 350, y: 260), scale: 1.0, inputId: 2, input: "B"),
        
        // Pause/Home/Select
        RegularButtonConfig(position: CGPoint(x: 150, y: 400), scale: 0.6, inputId: 3, input: "Minus", style: .init(shape: .Circle, iconType: .Text, icon: "-")),
        RegularButtonConfig(position: CGPoint(x: 200, y: 400), scale: 0.6, inputId: 4, input: "Home", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "house")),
        RegularButtonConfig(position: CGPoint(x: 250, y: 400), scale: 0.6, inputId: 5, input: "Plus", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "plus")),
        
        // 1/2
        RegularButtonConfig(position: CGPoint(x: 200, y: 575), scale: 0.75, inputId: 6, input: "1"),
        RegularButtonConfig(position: CGPoint(x: 200, y: 650), scale: 0.75, inputId: 7, input: "2")
    ])
    
    // MARK: DPad-less Test
    static let DPadlessTest: LayoutConfig = .init(name: "DPad-less Test", landscapeButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 650, y: 150), scale: 0.75, inputId: 0, input: "X"),
        RegularButtonConfig(position: CGPoint(x: 600, y: 200), scale: 0.75, inputId: 1, input: "Y"),
        RegularButtonConfig(position: CGPoint(x: 700, y: 200), scale: 0.75, inputId: 2, input: "A"),
        RegularButtonConfig(position: CGPoint(x: 650, y: 250), scale: 0.75, inputId: 3, input: "B"),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 450, y: 300), scale: 1.5, inputId: 4, input: "RightJoystick")
    ], portraitButtons: [
        // Diamond of buttons
        RegularButtonConfig(position: CGPoint(x: 300, y: 500), scale: 0.75, inputId: 0, input: "X"),
        RegularButtonConfig(position: CGPoint(x: 250, y: 550), scale: 0.75, inputId: 1, input: "Y"),
        RegularButtonConfig(position: CGPoint(x: 350, y: 550), scale: 0.75, inputId: 2, input: "A"),
        RegularButtonConfig(position: CGPoint(x: 300, y: 600), scale: 0.75, inputId: 3, input: "B"),
        
        // Right Joystick
        JoystickConfig(position: CGPoint(x: 240, y: 680), scale: 1.5, inputId: 4, input: "RightJoystick")
    ])
    
    
    static func getLayout(for name: ControllerType) -> LayoutConfig {
        switch name {
        case .Xbox:
            return XboxConfig
        case .PlayStation:
            return PlayStationConfig
        case .Wii:
            return WiiConfig
        case .Switch:
            return SwitchConfig
        case .DPadless:
            return DPadlessTest
        }
    }
}
