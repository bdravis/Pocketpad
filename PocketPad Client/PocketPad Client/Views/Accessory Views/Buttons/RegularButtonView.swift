//
//  RegularButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct RegularButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    var config: RegularButtonConfig
    
    var body: some View {
        Button(action: {
            if let service = bluetoothManager.selectedService {
                let ui8_playerId: UInt8 = 0 // Assuming one player
                let ui8_inputId : UInt8 = config.inputId
                let ui8_buttonType : UInt8 = config.type.rawValue
                
                let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType])
                bluetoothManager.sendInput(data)
                
            }
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
    }
}
