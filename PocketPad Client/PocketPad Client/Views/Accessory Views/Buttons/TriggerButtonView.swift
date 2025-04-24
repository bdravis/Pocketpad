//
//  TriggerButtonView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//
//  Edited by Benjamin Dravis on 4/13/25
//

import SwiftUI

struct TriggerButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @ObservedObject private var turboManager = TurboManager.shared
    
    var config: TriggerConfig
    var isInMacroEditor: Bool = false
    
    var body: some View {
        Button(action: {
            // Button presses/releases are registered in LongPress gesture
        }) {
            Text(config.input.rawValue)
        }
        .buttonStyle(TriggerButtonStyle(side: config.side, style: config.style, isTurboEnabled: turboManager.isTurboEnabled(config.input)))
        .onLongPressGesture(minimumDuration: 0.15, maximumDistance: 50, pressing: { isPressing in
            if isPressing {
                handleButtonPress()
            } else {
                handleButtonRelease()
            }
        }, perform: {})
    }
    
    // MARK: Functions to handle trigger inputs
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
        print("SEND TRIGGER PRESS")
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
        print("SEND TRIGGER RELEASE")
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
//    ControllerView(layout: .init(
//        name: "Trigger Debug",
//        landscapeButtons: [
//            TriggerConfig(
//                position: CGPoint(x: 100, y: 200),
//                scale: 1.5,
//                inputId: 4,
//                input: "LT",
//                side: .left
//            ),
//            TriggerConfig(
//                position: CGPoint(x: 200, y: 200),
//                scale: 1.5,
//                inputId: 4,
//                input: "RT",
//                side: .right
//            )
//        ],
//        portraitButtons: [
//            TriggerConfig(
//                position: CGPoint(x: 100, y: 200),
//                scale: 1.5,
//                inputId: 4,
//                input: "LT",
//                side: .left
//            ),
//            TriggerConfig(
//                position: CGPoint(x: 200, y: 200),
//                scale: 1.5,
//                inputId: 4,
//                input: "RT",
//                side: .right
//            )
//        ]
//    ))
//}
