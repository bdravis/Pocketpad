//
//  BluetoothStatusView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import CoreBluetooth
import SwiftUI

// MARK: - Status View
struct BluetoothStatusView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        HStack {
            Text("Bluetooth: ")
            switch bluetoothManager.bluetoothState {
            case .poweredOn:
                Text("On").foregroundColor(.green)
            case .poweredOff:
                Text("Off").foregroundColor(.red)
            case .unauthorized:
                Text("Unauthorized").foregroundColor(.red)
            case .unsupported:
                Text("Unsupported").foregroundColor(.red)
            default:
                Text("Unknown").foregroundColor(.orange)
            }
        }
    }
}

#Preview {
    BluetoothStatusView()
}
