//
//  ContentView.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                BluetoothScannerView()
                
                if bluetoothManager.connectedDevice == nil && bluetoothManager.isConnecting == false {
                    BluetoothStatusView()
                        .padding(.top, 8)
                }
            }
        }
        .onChange(of: bluetoothManager.connectedDevice) { device in
            if device != nil {
                bluetoothManager.stopScanning()
            }
        }
    }
}

#Preview {
    ContentView()
}
