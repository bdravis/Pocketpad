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
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = 0 // Assuming one player
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_buttonSide : UInt8 = config.side.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_buttonSide])
                bluetoothManager.sendInput(data)
            }
        }) {
            Text(config.input)
        }
        .buttonStyle(TriggerButtonStyle(side: config.side))
    }
}


#Preview {
    ControllerView(layout: .init(
        name: "Trigger Debug",
        landscapeButtons: [
            TriggerConfig(
                position: CGPoint(x: 100, y: 200),
                scale: 1.5,
                inputId: 4,
                input: "LT",
                side: .left
            ),
            TriggerConfig(
                position: CGPoint(x: 200, y: 200),
                scale: 1.5,
                inputId: 4,
                input: "RT",
                side: .right
            )
        ],
        portraitButtons: [
            TriggerConfig(
                position: CGPoint(x: 100, y: 200),
                scale: 1.5,
                inputId: 4,
                input: "LT",
                side: .left
            ),
            TriggerConfig(
                position: CGPoint(x: 200, y: 200),
                scale: 1.5,
                inputId: 4,
                input: "RT",
                side: .right
            )
        ]
    ))
}
