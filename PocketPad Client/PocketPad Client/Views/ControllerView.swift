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
    RegularButtonConfig(position: CGPoint(x: 300, y: 200), scale: 1.0, input_id: 0, input: "X"),
    RegularButtonConfig(position: CGPoint(x: 240, y: 260), scale: 1.0, input_id: 1, input: "Y"),
    RegularButtonConfig(position: CGPoint(x: 360, y: 260), scale: 1.0, input_id: 2, input: "A"),
    RegularButtonConfig(position: CGPoint(x: 300, y: 320), scale: 1.0, input_id: 3, input: "B"),
    
    JoystickConfig(position: CGPoint(x: 0, y: 400), scale: 1.0, input_id: 4, input: "RightJoystick"),
    DPadConfig(
        position: CGPoint(x: 100, y: 0), scale: 1.0, input_id: 5,
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
                ForEach($buttons, id: \.id) { btn in
                    GeneralButtonView(config: btn.wrappedValue)
                        .position(btn.wrappedValue.getScaledPosition(bounds: geometry.frame(in: .local)))
                        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                        .scaleEffect(btn.scale.wrappedValue)
#if DEBUG
                    ButtonInfoView(config: btn.wrappedValue)
                        .position(btn.wrappedValue.getScaledPosition(bounds: geometry.frame(in: .local)))
                        .scaleEffect(btn.scale.wrappedValue)
#endif
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
