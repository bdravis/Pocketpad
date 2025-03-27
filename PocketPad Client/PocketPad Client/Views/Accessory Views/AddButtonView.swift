//
//  AddButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 3/27/25.
//

import SwiftUI

struct AddButtonView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var layout: LayoutConfig
    @State var buttonType: ButtonType = .regular
    @State var buttonInput: ButtonInput = .A
    @State var triggerSide: TriggerSide = .left
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Type")
                Spacer()
                Picker("Type", selection: $buttonType) {
                    ForEach(ButtonType.allCases, id: \.self) { type in
                        Label(getBtnTypeName(type), systemImage: getBtnTypeIcon(type)).tag(getBtnTypeName(type))
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: buttonType, initial: true) {
                    if buttonType == .dpad {
                        buttonInput = .A
                    } else {
                        buttonInput = getButtonInputs(for: buttonType).first ?? .A
                    }
                }
            }
            .padding(.horizontal, 10)
            if buttonType != .dpad {
                HStack {
                    Text("Input")
                    Spacer()
                    Picker("Input", selection: $buttonInput) {
                        ForEach(getButtonInputs(for: buttonType), id: \.self) { input in
                            Text(input.rawValue).tag(input.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal, 10)
            }
            if buttonType == .trigger {
                HStack {
                    Text("Side")
                    Spacer()
                    Picker("Side", selection: $triggerSide) {
                        ForEach(TriggerSide.allCases, id: \.self) { side in
                            Text(getSideName(side)).tag(getSideName(side))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 10)
            }
            // MARK: Add/Cancel Buttons
            Button(action: {
                let inputId: UInt8 = 0 // TODO: Get a new input id
                switch buttonType {
                case .regular:
                    layout.buttons.append(RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5)), scale: 1.0, inputId: inputId, input: buttonInput))
                case .joystick:
                    layout.buttons.append(JoystickConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5)), scale: 1.0, inputId: inputId, input: buttonInput))
                case .dpad:
                    layout.buttons.append(DPadConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5)), scale: 1.0, inputId: inputId, inputs: [.up: .DPadUp, .right: .DPadRight, .down: .DPadDown, .left: .DPadLeft]))
                case .bumper:
                    layout.buttons.append(BumperConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5)), scale: 1.0, inputId: inputId, input: buttonInput))
                case .trigger:
                    layout.buttons.append(TriggerConfig(position: .init(scaledPos: CGPoint(x: 0.5, y: 0.5)), scale: 1.0, inputId: inputId, input: buttonInput, side: triggerSide))
                }
                dismiss()
            }) {
                Text("Add Button")
            }
            .buttonStyle(.borderedProminent)
            Button(action: {dismiss()}) {
                Text("Cancel")
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.red)
        }
    }
    
    func getBtnTypeName(_ type: ButtonType) -> String {
        switch type {
        case .regular:
            return "Regular"
        case .joystick:
            return "Joystick"
        case .dpad:
            return "DPad"
        case .bumper:
            return "Bumper"
        case .trigger:
            return "Trigger"
        }
    }
    
    func getBtnTypeIcon(_ type: ButtonType) -> String {
        switch type {
        case .regular:
            return "button.programmable"
        case .joystick:
            if buttonInput == .LeftJoystick {
                return "l.joystick"
            } else {
                return "r.joystick"
            }
        case .dpad:
            return "dpad"
        case .bumper:
            return "button.roundedtop.horizontal"
        case .trigger:
            return "button.angledtop.vertical.left"
        }
    }
    
    func getSideName(_ side: TriggerSide) -> String {
        switch side {
        case .left:
            return "Left"
        case .middle:
            return "Middle"
        case .right:
            return "Right"
        }
    }
}
