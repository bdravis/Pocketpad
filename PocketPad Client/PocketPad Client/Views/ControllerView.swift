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
    
    JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1.0, inputId: 4, input: "RightJoystick"),
    DPadConfig(
        position: CGPoint(x: 100, y: 0), scale: 1.0, inputId: 5,
        inputs: [
            .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
        ]
    )
]

// MARK: Main Controller View
struct ControllerView: View {
    // TODO: Make a View Model with the buttons
    @State var buttons: [ButtonConfig]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach($buttons, id: \.wrappedValue.id) { btn in
                    ZStack {
                        Group {
                            switch btn.wrappedValue.type {
                                case .regular:
                                    RegularButtonView(config: btn.wrappedValue as! RegularButtonConfig)
                                case .joystick:
                                    JoystickButtonView(config: btn.wrappedValue as! JoystickConfig)
                                case .dpad:
                                    DPadButtonView(config: btn.wrappedValue as! DPadConfig)
                            }
                        }
                        .position(btn.wrappedValue.getScaledPosition(bounds: geometry.frame(in: .local)))
                        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                        .scaleEffect(btn.scale.wrappedValue)
#if DEBUG
                        ButtonInfoView(config: btn.wrappedValue)
                            .position(btn.wrappedValue.getScaledPosition(bounds: geometry.frame(in: .local)))
                            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                            .scaleEffect(btn.scale.wrappedValue)
#endif
                    }
                }
            }
        }
        .navigationTitle("Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ControllerView(buttons: DEBUG_BUTTONS)
}
