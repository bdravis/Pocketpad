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
    @StateObject private var turboManager = TurboManager.shared
    @StateObject private var macroManager = MacroManager.shared
    @State private var longPressed = false
    
    var split: Bool
    
    let rotation: Double
    let input: ButtonInput // input used for the button action
    let direction: DPadDirection
    let config: DPadConfig // need to know id of config to identify the unique dpad
    var isInMacroEditor: Bool = false
    
    var body: some View {
        Button(action: {
            if !longPressed {
                handleTap()
            }
            longPressed = false
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
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50, pressing: { isPressing in
            if isPressing {
                longPressed = true
                if turboManager.turboActive { // turbo button is being held and then another button is pressed
                    turboManager.toggleTurboForButton(input)
                } else if turboManager.isTurboEnabled(input) { // while turbo is not being held, a turbo-enabled button is held
                    turboManager.startTurboForButton(
                        input,
                        buttonPressHandler: sendDpadPress,
                        buttonReleaseHandler: sendDpadRelease
                    )
                } else {
                    // this case is a simple button press/hold
                    sendDpadPress()
                }
            }
            else {
                if !turboManager.turboActive { // if turbo button is not being held
                    // note: for the case of turbo button being held, do nothing to avoid duplicate toggling of turbo for a button
                    
                    // if turbo button is not being held:
                    sendDpadRelease()
                    if (turboManager.isTurboEnabled(input)) { // the released button is a turbo-enabled button
                        turboManager.stopTurboForButton(input)
                    }
                }
            }
        }, perform: {})
    }
    
    private func handleTap() {
#if DEBUG
        print("DPad Tapped")
#endif
        sendDpadPress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            sendDpadRelease()
        }
    }
    
    private func sendDpadPress() {
#if DEBUG
        print("DPAD PRESS")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
        
        let ui8_dpadDirection : UInt8 = direction.rawValue
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_dpadDirection])
        bluetoothManager.sendInput(data)
    }
    private func sendDpadRelease() {
#if DEBUG
        print("DPAD RELEASE")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue
        
        let ui8_dpadDirection : UInt8 = direction.rawValue
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_dpadDirection])
        bluetoothManager.sendInput(data)
    } 
}
