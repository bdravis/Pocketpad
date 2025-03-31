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
        .applyButtonStyle(shape: config.style.shape)
        .pressAction(onPress: {
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = 0 // Assuming one player
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
                print("PRESS REGULAR BUTTON")
                bluetoothManager.sendInput(data)
            }
        }, onRelease: {
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = 0 // Assuming one player
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                let ui8_event : UInt8 = ButtonEvent.released.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
                print("RELEASE REGULAR BUTTON")
                bluetoothManager.sendInput(data)
            }
        })
    }
}
