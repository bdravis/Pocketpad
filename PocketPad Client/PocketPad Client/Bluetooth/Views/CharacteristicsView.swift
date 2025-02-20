//
//  CharacteristicsView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import SwiftUI
import CoreBluetooth

struct CharacteristicsView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    let service: CBService
    
    var body: some View {
        List(bluetoothManager.discoveredCharacteristics, id: \.uuid) { characteristic in
            CharacteristicRow(characteristic: characteristic)
        }
        .navigationTitle("Characteristics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    if let deviceName = service.peripheral?.name {
                        Text(deviceName)
                            .font(.headline)
                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .onAppear {
            bluetoothManager.selectedService = service
            if let peripheral = service.peripheral {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
}

struct CharacteristicRow: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    let characteristic: CBCharacteristic
    @State private var isExpanded = false
    @State private var inputText = ""
    @State private var isNotifying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                VStack(alignment: .leading) {
                    Text(characteristic.uuid.uuidString)
                        .font(.headline)
                    Text(getPropertiesDescription(characteristic.properties))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Read button
                    if characteristic.properties.contains(.read) {
                        Button("Read Value") {
                            bluetoothManager.readValue(for: characteristic)
                        }
                        .buttonStyle(.bordered)
                        
                        if !bluetoothManager.lastMessage.isEmpty {
                            Text("Value: \(bluetoothManager.lastMessage)")
                                .font(.caption)
                        }
                    }
                    
                    // Notify toggle
                    if characteristic.properties.contains(.notify) {
                        Toggle("Notifications", isOn: Binding(
                            get: { isNotifying },
                            set: { newValue in
                                isNotifying = newValue
                                if newValue {
                                    bluetoothManager.startNotifications(for: characteristic)
                                } else {
                                    bluetoothManager.stopNotifications(for: characteristic)
                                }
                            }
                        ))
                    }
                    
                    // Write section - only show if notifications are enabled
                    if (characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse)),
                       isNotifying {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Enter value to write", text: $inputText)
                                .textFieldStyle(.roundedBorder)
                            
                            HStack {
                                Button("Write") {
                                    bluetoothManager.sendData(inputText, to: characteristic)
                                    inputText = ""
                                }
                                .buttonStyle(.bordered)
                                
                                if !bluetoothManager.writeStatus.isEmpty {
                                    Text(bluetoothManager.writeStatus)
                                        .font(.caption)
                                        .foregroundColor(bluetoothManager.writeStatus.contains("Error") ? .red : .green)
                                }
                            }
                        }
                    }
                }
                .padding(.leading)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            // Initialize the notification state
            isNotifying = characteristic.isNotifying
        }
    }
    
    private func getPropertiesDescription(_ properties: CBCharacteristicProperties) -> String {
        var descriptions: [String] = []
        
        if properties.contains(.read) { descriptions.append("Read") }
        if properties.contains(.write) { descriptions.append("Write") }
        if properties.contains(.writeWithoutResponse) { descriptions.append("Write Without Response") }
        if properties.contains(.notify) { descriptions.append("Notify") }
        if properties.contains(.indicate) { descriptions.append("Indicate") }
        if properties.contains(.authenticatedSignedWrites) { descriptions.append("Authenticated Writes") }
        if properties.contains(.extendedProperties) { descriptions.append("Extended Properties") }
        if properties.contains(.notifyEncryptionRequired) { descriptions.append("Notify Encryption Required") }
        if properties.contains(.indicateEncryptionRequired) { descriptions.append("Indicate Encryption Required") }
        
        return descriptions.joined(separator: ", ")
    }
}

// MARK: - Preview Helpers
struct MockCharacteristic: Identifiable {
    let id = UUID()
    let uuid: String
    let properties: [String]
    let canRead: Bool
    let canWrite: Bool
    let canNotify: Bool
}

#Preview {
    struct PreviewCharacteristicsView: View {
        @State private var mockCharacteristics = [
            MockCharacteristic(
                uuid: "2A19",
                properties: ["Read", "Notify"],
                canRead: true,
                canWrite: false,
                canNotify: true
            ),
            MockCharacteristic(
                uuid: "2A29",
                properties: ["Read", "Write"],
                canRead: true,
                canWrite: true,
                canNotify: false
            ),
            MockCharacteristic(
                uuid: "2A37",
                properties: ["Notify"],
                canRead: false,
                canWrite: false,
                canNotify: true
            )
        ]
        @State private var expandedId: UUID?
        @State private var inputText = ""
        @State private var lastMessage = ""
        @State private var writeStatus = ""
        @State private var isNotifying = false
        
        var body: some View {
            List(mockCharacteristics) { characteristic in
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        if expandedId == characteristic.id {
                            expandedId = nil
                        } else {
                            expandedId = characteristic.id
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text(characteristic.uuid)
                                .font(.headline)
                            Text(characteristic.properties.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if expandedId == characteristic.id {
                        VStack(alignment: .leading, spacing: 12) {
                            if characteristic.canRead {
                                Button("Read Value") {
                                    lastMessage = "Sample Value"
                                }
                                .buttonStyle(.bordered)
                                
                                if !lastMessage.isEmpty {
                                    Text("Value: \(lastMessage)")
                                        .font(.caption)
                                }
                            }
                            
                            if characteristic.canWrite {
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Enter value to write", text: $inputText)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    HStack {
                                        Button("Write") {
                                            writeStatus = "Sent successfully"
                                            inputText = ""
                                        }
                                        .buttonStyle(.bordered)
                                        
                                        if !writeStatus.isEmpty {
                                            Text(writeStatus)
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            
                            if characteristic.canNotify {
                                Toggle("Notifications", isOn: $isNotifying)
                            }
                        }
                        .padding(.leading)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Characteristics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Test Device")
                            .font(.headline)
                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    return NavigationStack {
        PreviewCharacteristicsView()
    }
} 
