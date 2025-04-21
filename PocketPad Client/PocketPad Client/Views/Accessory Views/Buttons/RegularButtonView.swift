//
//  RegularButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//
//  Edited by Benjamin Dravis on 4/13/25
//

import SwiftUI

struct RegularButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var turboManager = TurboManager.shared
    @State private var longPressed = false
    
    var config: RegularButtonConfig
    @Binding var showKeyboard: Bool
    
    var body: some View {
        Group {
            Button(action: {
                if config.input != .Keyboard {
                    if !longPressed {
                        handleTap()
                    }
                    longPressed = false
                } else {
                    showKeyboard = true
                }
            }) {
                Group {
                    if let icon = config.style.icon {
                        switch config.style.iconType {
                        case .Text:
                            Text(icon)
                        case .SFSymbol:
                            ZStack {
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit() // make sure it does not stretch
                            }
                        }
                    } else {
                        Text("") // empty textbox
                    }
                }
            }
            .applyButtonStyle(config.style, isTurboEnabled: turboManager.isTurboEnabled(config.input))
            .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50, pressing: { isPressing in
                if config.input != .Keyboard {
                    if isPressing {
                        longPressed = true
                        if config.turbo { // if this button is the turbo button itself
                            turboManager.activateTurboMode()
                        } else if turboManager.turboActive { // turbo button is being held and then another button is pressed
                            turboManager.toggleTurboForButton(config.input)
                        } else if turboManager.isTurboEnabled(config.input) { // while turbo is not being held, a turbo-enabled button is held
                            turboManager.startTurboForButton(
                                config.input,
                                buttonPressHandler: sendRegularButtonPress,
                                buttonReleaseHandler: sendRegularButtonRelease
                            )
                        } else { // turbo button is not being held, button is not turbo-enabled
                            // this case is a simple button press/hold
                            sendRegularButtonPress()
                        }
                    }
                    else {
                        if config.turbo { // if released button is the turbo button itself
                            turboManager.deactivateTurboMode()
                        } else if !turboManager.turboActive { // if turbo button is not being held
                            // note: for the case of turbo button being held, do nothing to avoid duplicate toggling of turbo for a button
                            
                            // if turbo button is not being held:
                            sendRegularButtonRelease()
                            if (turboManager.isTurboEnabled(config.input)) { // the released button is a turbo-enabled button
                                turboManager.stopTurboForButton(config.input)
                            }
                        }
                        
                    }
                }
            }, perform: {})
        }
    }
    
    private func handleTap() {
#if DEBUG
        print("Button Tapped")
#endif
        sendRegularButtonPress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            sendRegularButtonRelease()
        }
    }
    
    // send button press
    private func sendRegularButtonPress() {
#if DEBUG
        print("REGULAR BUTTON PRESS")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue;
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        bluetoothManager.sendInput(data);
    }
    
    // send button release
    private func sendRegularButtonRelease() {
#if DEBUG
        print("REGULAR BUTTON RELEASE")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue;

        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        bluetoothManager.sendInput(data);
    }
}
