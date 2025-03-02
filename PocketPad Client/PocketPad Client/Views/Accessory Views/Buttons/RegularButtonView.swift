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
                if let char = bluetoothManager.discoveredCharacteristics.first(where: { $0.uuid == INPUT_CHARACTERISTIC }) {
                    let ui8_playerId: UInt8 = 0 // Assuming one player
                    let ui8_inputId : UInt8 = config.inputId
                    let ui8_buttonType : UInt8 = config.type.rawValue
                    
                    let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType])
                    bluetoothManager.sendInput(data)
                }
            }
        }) {
            Text(config.input)
        }
        .buttonStyle(CircularButtonStyle()) // TODO: Fix the hitbox being a square
    }
}
