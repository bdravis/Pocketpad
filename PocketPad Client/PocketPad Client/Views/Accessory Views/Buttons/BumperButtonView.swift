//
//  BumperButtonView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//

import SwiftUI

struct BumperButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    var config: BumperConfig
    
    var body: some View {
        Button(action: {
            // 
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
        .pressAction(onPress: {
#if DEBUG
            print("PRESS BUMPER")
#endif
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = LayoutManager.shared.player_id
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
                bluetoothManager.sendInput(data)
            }
        }, onRelease: {
#if DEBUG
            print("RELEASE BUMPER")
#endif
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = LayoutManager.shared.player_id
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_event : UInt8 = ButtonEvent.released.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
                bluetoothManager.sendInput(data)
            }
        })
    }
}

//
//#Preview {
//    ControllerView(layout: .init(name: "Bumper Debug", landscapeButtons: [BumperConfig(position: CGPoint(x: 100, y: 200), scale: 2, inputId: 4, input: "LB")], portraitButtons: [BumperConfig(position: CGPoint(x: 100, y: 200), scale: 2, inputId: 4, input: "LB")]))
//}
