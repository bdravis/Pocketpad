//
//  DPadButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//
//  Edited by Benjamin Dravis on 4/13/25
//

import SwiftUI

let DPAD_THICKNESS = DEFAULT_BUTTON_SIZE * 0.35 // thickness is 35% of the default button size

struct DPadButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var config: DPadConfig
    var isInMacroEditor: Bool = false
    @AppStorage("splitDPad") var split: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            if !split {
                // Background path
                Plus(thickness: DPAD_THICKNESS)
                    .fill(getBGColor())
                    .stroke(getStrokeColor(), style: StrokeStyle(lineWidth: config.style.borderThickness, lineCap: .square, lineJoin: .bevel))
                
                // Center Circle
                Circle()
                    .stroke(getStrokeColor(), style: StrokeStyle(lineWidth: 1.5))
                    .frame(width: DPAD_THICKNESS - 8, height: DPAD_THICKNESS - 8)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("DPadConjoined")
            }
            
            // Horizontal directional arrows
            HStack {
                DirectionalArrow(split: split, rotation: -90, input: .DPadLeft, direction: .left, config: config, isInMacroEditor: isInMacroEditor) // left arrow
                Spacer()
                DirectionalArrow(split: split, rotation: 90, input: .DPadRight, direction: .right, config: config, isInMacroEditor: isInMacroEditor) // right arrow
                    .accessibilityIdentifier("DPadButton")
            }
            .frame(maxHeight: DPAD_THICKNESS)
            .accessibilityAddTraits(.isButton)
            
            // Vertical directional arrows
            VStack {
                DirectionalArrow(split: split, rotation: 0, input: .DPadUp, direction: .up, config: config, isInMacroEditor: isInMacroEditor) // up arrow
                Spacer()
                DirectionalArrow(split: split, rotation: 180, input: .DPadDown, direction: .down, config: config, isInMacroEditor: isInMacroEditor) // down arrow
            }
            .frame(maxWidth: DPAD_THICKNESS)
        }
    }
    
    /* Color Getter Functions */
    func getBGColor() -> Color {
        return (
            colorScheme == .dark ? config.style.darkModeColors.color
            : config.style.lightModeColors.color
        ) ?? DefaultColors.dpad.color
    }
    func getStrokeColor() -> Color {
        return (
            colorScheme == .dark ? config.style.darkModeColors.strokeColor
            : config.style.lightModeColors.strokeColor
        ) ?? DefaultColors.dpad.strokeColor
    }
}

// Style for the directional arrow on the D-Pad
struct DirectionalArrow: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @ObservedObject private var turboManager = TurboManager.shared
    @State private var longPressed = false
    
    var split: Bool
    
    let rotation: Double
    let input: ButtonInput // input used for the button action
    let direction: DPadDirection
    let config: DPadConfig // need to know id of config to identify the unique dpad
    var isInMacroEditor: Bool = false
    
    var body: some View {
        Button(action: {
            // Button presses/releases are registered in LongPress gesture
        }) {
            Triangle()
                .stroke(
                    turboManager.isTurboEnabled(input) ? Color.yellow : Color.primary,
                    style: StrokeStyle(lineWidth: 1.5, lineJoin: .round)
                )
                .background(
                    Triangle()
                        .opacity(split ? 1.0 : 0.0)
                )
                .padding(.horizontal, split ? 2 : 4)
                .padding(.bottom, 4)
                .padding(.top, split ? 0 : 4)
                .rotationEffect(.degrees(rotation))
                .aspectRatio(1.0, contentMode: .fit)
        }
        .buttonStyle(DPadButtonStyle(style: config.style, split: split))
        .onLongPressGesture(minimumDuration: 0.15, maximumDistance: 50, pressing: { isPressing in
            if isPressing {
                handleButtonPress()
            } else {
                handleButtonRelease()
            }
        }, perform: {})
    }
    
    // MARK: Functions to handle D-pad inputs
    private func handleButtonPress() {
        turboManager.handleButtonPressThroughTurbo(
            input: input,
            isTurboButton: false,
            sendButtonPressFunc: sendButtonPress,
            sendButtonRelaseFunc: sendButtonRelease,
            isInMacroEditor: isInMacroEditor
        )
    }
    
    private func handleButtonRelease() {
        turboManager.handleButtonReleaseThroughTurbo(
            input: input,
            isTurboButton: false,
            sendButtonReleaseFunc: sendButtonRelease
        )
    }
    
    private func sendButtonPress() {
#if DEBUG
        print("SEND DPAD PRESS")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
        
        let ui8_dpadDirection : UInt8 = direction.rawValue
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_dpadDirection])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }
    private func sendButtonRelease() {
#if DEBUG
        print("SEND DPAD RELEASE")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue
        
        let ui8_dpadDirection : UInt8 = direction.rawValue
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_dpadDirection])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }
}
