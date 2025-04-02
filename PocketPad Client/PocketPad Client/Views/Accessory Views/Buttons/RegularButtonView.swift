//
//  RegularButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct RegularButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var turboManager = TurboManager.shared
    var config: RegularButtonConfig
    
    var body: some View {
        Button(action: {
            // Actions are handled with pressAction modifier
        }) {
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
        .applyButtonStyle(config.style)
        .overlay(
            turboManager.isTurboEnabled(config.input) ?
            Group {
                switch config.style.shape {
                case .Circle:
                    Circle()
                        .stroke(.yellow, lineWidth: 5)
                        .padding(2)
                case .Pill:
                    Capsule()
                        .stroke(.yellow, lineWidth: 5)
                        .padding(2)
                }
            } : nil
        )
        .pressAction(onPress: {
            if config.turbo { // if this button is the turbo button itself
                turboManager.activateTurboMode()
            } else if turboManager.turboActive { // turbo button is being held and then another button is pressed
                turboManager.toggleTurboForButton(config.input)
            } else if turboManager.isTurboEnabled(config.input) { // while turbo is not being held, a turbo-enabled button is held
                turboManager.startTurboForButton(
                    config.input,
                    playerId: LayoutManager.shared.player_id, // Assuming one player
                    inputId: config.inputId,
                    buttonType: config.type.rawValue
                )
            } else { // turbo button is not being held, button is not turbo-enabled
                // this case is a simple button press/hold
                sendButtonPress()
            }
        }, onRelease: {
            if config.turbo { // if released button is the turbo button itself
                turboManager.deactivateTurboMode()
            } else if !turboManager.turboActive { // if turbo button is not being held
                // note: for the case of turbo button being held, do nothing to avoid duplicate toggling of turbo for a button
                
                // if turbo button is not being held:
                sendButtonRelease()
                if (turboManager.isTurboEnabled(config.input)) { // the released button is a turbo-enabled button
                    turboManager.stopTurboForButton(config.input)
                }
            }
        })
    }
    
    // send button press for a non turbo-enabled button
    private func sendButtonPress() {
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id // Assuming one player
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
#if DEBUG
        print("TURBO-DISABLED REGULAR BUTTON PRESS")
#endif
        bluetoothManager.sendInput(data)
    }
    
    // send button release for a non turbo-enabled button
    private func sendButtonRelease() {
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id // Assuming one player
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
#if DEBUG
        print("SAFETY REGULAR BUTTON RELEASE")
#endif
        bluetoothManager.sendInput(data)
    }
}
