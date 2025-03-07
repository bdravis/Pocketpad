//
//  ControllerView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

// MARK: Debug Button Configuration
let DEBUG_BUTTONS: [ButtonConfig] = [ // Example buttons
    // Diamond of buttons
    RegularButtonConfig(position: CGPoint(x: 300, y: 200), scale: 1.0, inputId: 0, input: "X"),
    RegularButtonConfig(position: CGPoint(x: 240, y: 260), scale: 1.0, inputId: 1, input: "Y"),
    RegularButtonConfig(position: CGPoint(x: 360, y: 260), scale: 1.0, inputId: 2, input: "A"),
    RegularButtonConfig(position: CGPoint(x: 300, y: 320), scale: 1.0, inputId: 3, input: "B"),
    
    RegularButtonConfig(position: CGPoint(x: 100, y: 300), scale: 1.0, inputId: 8, input: "Share", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square.and.arrow.up")), // SF Symbol style test
    RegularButtonConfig(position: CGPoint(x: 260, y: 100), scale: 1.0, inputId: 6, input: "Start", style: .init(shape: .Pill, iconType: .Text, icon: "Start")), // Pill style test
    RegularButtonConfig(position: CGPoint(x: 200, y: 100), scale: 1.0, inputId: 7, input: "Select", style: .init(shape: .Pill, iconType: .Text)), // No text test
    
    JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1.0, inputId: 4, input: "RightJoystick"),
    DPadConfig(
        position: CGPoint(x: 100, y: 0), scale: 1.0, inputId: 5,
        inputs: [
            .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
        ]
    ),
    
    TriggerConfig(position: CGPoint(x: 300, y: 0), scale: 1.0, inputId: 10, input: "RT", side: .right)
]

// MARK: Main Controller View
struct ControllerView: View {
    // TODO: Make a View Model with the buttons
    @State private var orientation = UIDeviceOrientation.unknown
    @State var layout: LayoutConfig
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(orientation.isPortrait ? $layout.portraitButtons : $layout.landscapeButtons, id: \.wrappedValue.id) { btn in
                    ZStack {
                        Group {
                            switch btn.wrappedValue.type {
                                case .regular:
                                    RegularButtonView(config: btn.wrappedValue as! RegularButtonConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                case .joystick:
                                    JoystickButtonView(config: btn.wrappedValue as! JoystickConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                case .dpad:
                                    DPadButtonView(config: btn.wrappedValue as! DPadConfig)
                                case .bumper:
                                    BumperButtonView(config: btn.wrappedValue as! BumperConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                case .trigger:
                                    TriggerButtonView(config: btn.wrappedValue as! TriggerConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                            }
                        }
                        .scaleEffect(btn.scale.wrappedValue)
                        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                        .position(btn.wrappedValue.getScaledPosition(bounds: geometry.frame(in: .local)))
#if DEBUG
                        ButtonInfoView(config: btn.wrappedValue)
                            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                            .scaleEffect(btn.scale.wrappedValue)
                            .position(btn.wrappedValue.getScaledPosition(bounds: geometry.frame(in: .local)))
#endif
                    }
                }
            }
            .onRotate { newOrientation in
                orientation = newOrientation
            }
            .onAppear {
                orientation = UIDevice.current.orientation
            }
        }
        .navigationTitle("Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ControllerView(layout: .init(name: "Debug", landscapeButtons: DEBUG_BUTTONS, portraitButtons: DEBUG_BUTTONS))
}
