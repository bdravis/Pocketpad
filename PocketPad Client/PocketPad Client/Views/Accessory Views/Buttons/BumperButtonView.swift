//
//  BumperButtonView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//
//  Edited by Benjamin Dravis on 4/13/25
//

import SwiftUI

struct BumperButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var turboManager = TurboManager.shared
    
    var config: BumperConfig
    var isInMacroEditor: Bool = false
    
    var body: some View {
        Button(action: {
            // Button presses/releases are registered in LongPress gesture
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
        .applyButtonStyle(config.style, isTurboEnabled: turboManager.isTurboEnabled(config.input))
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50, pressing: { isPressing in
            if isPressing {
                handleButtonPress()
            }
            else {
                handleButtonRelease()
            }
        }, perform: {})
                
    }
    
    // MARK: Functions to handle bumper inputs
    private func handleButtonPress() {
        turboManager.handleButtonPressThroughTurbo(
            input: config.input,
            isTurboButton: false,
            sendButtonPressFunc: sendButtonPress,
            sendButtonRelaseFunc: sendButtonRelease,
            isInMacroEditor: isInMacroEditor
        )
    }
    
    private func handleButtonRelease() {
        turboManager.handleButtonReleaseThroughTurbo(
            input: config.input,
            isTurboButton: false,
            sendButtonReleaseFunc: sendButtonRelease
        )
    }
            
    private func sendButtonPress() {
#if DEBUG
        print("SEND BUMPER PRESS")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
                
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }
            
    private func sendButtonRelease() {
#if DEBUG
        print("SEND BUMPER RELEASE")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue
                
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }
}

//
//#Preview {
//    ControllerView(layout: .init(name: "Bumper Debug", landscapeButtons: [BumperConfig(position: CGPoint(x: 100, y: 200), scale: 2, inputId: 4, input: "LB")], portraitButtons: [BumperConfig(position: CGPoint(x: 100, y: 200), scale: 2, inputId: 4, input: "LB")]))
//}
