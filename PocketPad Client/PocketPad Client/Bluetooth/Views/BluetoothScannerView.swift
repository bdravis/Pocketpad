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
    @State private var showingDeviceView = false

    var body: some View {
        NavigationStack {
            List(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                DeviceRow(device: device, selectedDevice: $selectedDevice, showingDeviceView: $showingDeviceView)
            }
            .navigationTitle("Available Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(bluetoothManager.isScanning ? "Stop" : "Scan") {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showingDeviceView) {
                if let device = selectedDevice {
                    BluetoothDataView(device: device)
                }
            }
        }
    }
}

// MARK: - Device Row
struct DeviceRow: View {
    let device: CBPeripheral
    @Binding var selectedDevice: CBPeripheral?
    @Binding var showingDeviceView: Bool
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
                showingDeviceView = true
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isScanning ? "Stop" : "Scan") {
                            isScanning.toggle()
                        }
                    }
                }
            }
        }
    }
    
    return PreviewBluetoothScannerView()
}
