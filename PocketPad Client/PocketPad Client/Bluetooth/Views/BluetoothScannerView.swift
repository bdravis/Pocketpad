//
//  BluetoothScannerView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import CoreBluetooth
import SwiftUI

// MARK: - Scanner View
struct BluetoothScannerView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @State private var selectedDevice: CBPeripheral?

    var body: some View {
        NavigationStack {
            List(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                DeviceRow(device: device, selectedDevice: $selectedDevice)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Available Devices")
        }
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onDisappear {
            bluetoothManager.stopScanning()
        }
    }
}

// MARK: - Device Row
struct DeviceRow: View {
    let device: CBPeripheral
    @Binding var selectedDevice: CBPeripheral?
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        Button(action: {
            selectedDevice = device
            bluetoothManager.connect(to: device)
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(device.name ?? "Unknown Device")
                        .font(.headline)
                    Text(device.identifier.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if bluetoothManager.isConnecting && selectedDevice == device {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .onChange(of: bluetoothManager.connectedDevice) { newDevice in
            if newDevice == device {
                bluetoothManager.stopScanning()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewBluetoothScannerView: View {
        @State private var isScanning = false
        @State private var selectedDevice: MockDevice?
        
        struct MockDevice: Identifiable {
            let id = UUID()
            let name: String
        }
        
        let devices = [
            MockDevice(name: "Sample Device 1"),
            MockDevice(name: "Sample Device 2"),
            MockDevice(name: "Sample Device 3")
        ]
        
        var body: some View {
            NavigationStack {
                List(devices) { device in
                    Button(action: { selectedDevice = device }) {
                        VStack(alignment: .leading) {
                            Text(device.name)
                                .font(.headline)
                            Text(device.id.uuidString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Available Devices")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    return PreviewBluetoothScannerView()
}
