//
//  DPadButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

let DPAD_THICKNESS = DEFAULT_BUTTON_SIZE * 0.35 // thickness is 35% of the default button size

struct DPadButtonView: View {
    var config: DPadConfig
    @AppStorage("splitDPad") var split: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            if !split {
                // Background path
                Plus(thickness: DPAD_THICKNESS)
                    .fill(config.style.color ?? Color(uiColor: .secondarySystemFill))
                    .stroke(.black, style: StrokeStyle(lineWidth: config.style.borderThickness, lineCap: .square, lineJoin: .bevel))
                
                // Center Circle
                Circle()
                    .stroke(.black, style: StrokeStyle(lineWidth: 1.5))
                    .frame(width: DPAD_THICKNESS - 8, height: DPAD_THICKNESS - 8)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("DPadConjoined")
            }
            
            // Horizontal directional arrows
            HStack {
                DirectionalArrow(split: split, rotation: -90, input: .DPadLeft, direction: .left, config: config) // left arrow
                Spacer()
                DirectionalArrow(split: split, rotation: 90, input: .DPadRight, direction: .right, config: config) // right arrow
                    .accessibilityIdentifier("DPadButton")
            }
            .frame(maxHeight: DPAD_THICKNESS)
            .accessibilityAddTraits(.isButton)
            
            // Vertical directional arrows
            VStack {
                DirectionalArrow(split: split, rotation: 0, input: .DPadUp, direction: .up, config: config) // up arrow
                Spacer()
                DirectionalArrow(split: split, rotation: 180, input: .DPadDown, direction: .down, config: config) // down arrow
            }
            .frame(maxWidth: DPAD_THICKNESS)
        }
    }
}

// Style for the directional arrow on the D-Pad
struct DirectionalArrow: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var turboManager = TurboManager.shared
    
    var split: Bool
    
    let rotation: Double
    let input: ButtonInput // input used for the button action
    let direction: DPadDirection
    let config: DPadConfig // need to know id of config to identify the unique dpad
    
    var body: some View {
        Button(action: {
            //
        }) {
            Triangle()
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
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
        .pressAction(onPress: {
            if turboManager.turboActive { // turbo button is being held and then another button is pressed
                turboManager.toggleTurboForButton(input)
            } else if turboManager.isTurboEnabled(input) { // while turbo is not being held, a turbo-enabled button is held
                turboManager.startTurboForDPad(
                    input,
                    playerId: LayoutManager.shared.player_id, // Assuming one player
                    inputId: config.inputId,
                    buttonType: config.type.rawValue,
                    dpadDirection: direction.rawValue
                )
            } else {
                send_dpad_press()
            }
        }, onRelease: {
            if !turboManager.turboActive { // if turbo button is not being held
                // note: for the case of turbo button being held, do nothing to avoid duplicate toggling of turbo for a button
                
                // if turbo button is not being held:
                send_dpad_release()
                if (turboManager.isTurboEnabled(input)) { // the released button is a turbo-enabled button
                    turboManager.stopTurboForButton(input)
                }
            }
        })
    }
    private func send_dpad_press() {
#if DEBUG
        print("TURBO-DISABLED DPad PRESS")
#endif
        if let service = bluetoothManager.selectedService {
            let ui8_playerId: UInt8 = LayoutManager.shared.player_id
            let ui8_inputId : UInt8 = config.inputId
            let ui8_buttonType : UInt8 = config.type.rawValue
            let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
            
            let ui8_dpadDirection : UInt8 = direction.rawValue
            
            let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_dpadDirection])
            bluetoothManager.sendInput(data)
        }
    }
    private func send_dpad_release() {
#if DEBUG
        print("SAFETY DPad RELEASE")
#endif
        if let service = bluetoothManager.selectedService {
            let ui8_playerId: UInt8 = LayoutManager.shared.player_id
            let ui8_inputId : UInt8 = config.inputId
            let ui8_buttonType : UInt8 = config.type.rawValue
            let ui8_event : UInt8 = ButtonEvent.released.rawValue
            
            let ui8_dpadDirection : UInt8 = direction.rawValue
            
            let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_dpadDirection])
            bluetoothManager.sendInput(data)
        }
    }
}
