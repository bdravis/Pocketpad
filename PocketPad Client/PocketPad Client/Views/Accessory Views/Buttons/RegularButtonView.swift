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

    var config: RegularButtonConfig
    var isInMacroEditor: Bool = false
    
    var body: some View {
        Button(action: {
            // Button presses/releases are registered in LongPress gesture
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
            if isPressing {
                handleButtonPress()
            } else {
                handleButtonRelease()
            }
        }, perform: {})
    }
    
    // MARK: Functions to handle regular button inputs
    private func handleButtonPress() {
        turboManager.handleButtonPressThroughTurbo(
            input: config.input,
            isTurboButton: config.turbo,
            sendButtonPressFunc: sendButtonPress,
            sendButtonRelaseFunc: sendButtonRelease,
            isInMacroEditor: isInMacroEditor
        )
    }
    
    private func handleButtonRelease() {
        turboManager.handleButtonReleaseThroughTurbo(
            input: config.input,
            isTurboButton: config.turbo,
            sendButtonReleaseFunc: sendButtonRelease
        )
    }
    
    // Send button press
    private func sendButtonPress() {
#if DEBUG
        print("SEND REGULAR BUTTON PRESS")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue;
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }
    
    // Send button release
    private func sendButtonRelease() {
#if DEBUG
        print("SEND REGULAR BUTTON RELEASE")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue;

        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }
    
    
}
