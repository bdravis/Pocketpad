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
    @StateObject private var turboManager = TurboManager.shared
    var config: TriggerConfig
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            Text(config.input.rawValue)
        }
        .buttonStyle(TriggerButtonStyle(side: config.side, isTurboEnabled: turboManager.isTurboEnabled(config.input)))
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50, pressing: { isPressing in
            if isPressing {
                if turboManager.turboActive { // turbo button is being held and then another button is pressed
                    turboManager.toggleTurboForButton(config.input)
                } else if turboManager.isTurboEnabled(config.input) { // while turbo is not being held, a turbo-enabled button is held
                    turboManager.startTurboForButton(
                        config.input,
                        buttonPressHandler: sendTriggerPress,
                        buttonReleaseHandler: sendTriggerRelease
                    )
                } else { // turbo button is not being held, button is not turbo-enabled
                    // this case is a simple button press/hold
                    send_trigger_press()
                }
            }
            else {
                if !turboManager.turboActive { // if turbo button is not being held
                    // note: for the case of turbo button being held, do nothing to avoid duplicate toggling of turbo for a button
                    
                    // if turbo button is not being held:
                    send_trigger_release()
                    if (turboManager.isTurboEnabled(config.input)) { // the released button is a turbo-enabled button
                        turboManager.stopTurboForButton(config.input)
                    }
                }
            }
        }, perform: {})
    }
    
    private func handleTap() {
#if DEBUG
        print("Trigger Tapped")
#endif
        send_trigger_press()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            send_trigger_release()
        }
    }
    
    private func send_trigger_press() {
        if let service = bluetoothManager.selectedService {
            let ui8_playerId: UInt8 = LayoutManager.shared.player_id
            let ui8_inputId : UInt8 = config.inputId
            let ui8_buttonType : UInt8 = config.type.rawValue
            let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
            
            let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
            print("PRESS TRIGGER")
            bluetoothManager.sendInput(data)
        }
    }
    
    private func send_trigger_release() {
        if let service = bluetoothManager.selectedService {
            let ui8_playerId: UInt8 = LayoutManager.shared.player_id
            let ui8_inputId : UInt8 = config.inputId
            let ui8_buttonType : UInt8 = config.type.rawValue
            let ui8_event : UInt8 = ButtonEvent.released.rawValue
            
            let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
            print("RELEASE TRIGGER")
            bluetoothManager.sendInput(data)
        }
    }
    
    // send button press
    private func sendTriggerPress() {
#if DEBUG
        print("TRIGGER PRESS")
#endif
        sendTriggerInput(buttonEvent: .pressed)
    }
    
    // send button release
    private func sendTriggerRelease() {
#if DEBUG
        print("TRIGGER RELEASE")
#endif
        sendTriggerInput(buttonEvent: .released)
    }
    
    func sendTriggerInput(buttonEvent: ButtonEvent) {
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = buttonEvent.rawValue;
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
        bluetoothManager.sendInput(data);
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
