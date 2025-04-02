//
//  TriggerButtonView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//

import SwiftUI

struct TriggerButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    var config: TriggerConfig
    
    var body: some View {
        Button(action: {
            //
        }) {
            Text(config.input.rawValue)
        }
        .buttonStyle(TriggerButtonStyle(side: config.side))
        .pressAction(onPress: {
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = LayoutManager.shared.player_id
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
                print("PRESS TRIGGER")
                bluetoothManager.sendInput(data)
            }
        }, onRelease: {
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = LayoutManager.shared.player_id
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_event : UInt8 = ButtonEvent.released.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
                print("RELEASE TRIGGER")
                bluetoothManager.sendInput(data)
            }
        })
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
