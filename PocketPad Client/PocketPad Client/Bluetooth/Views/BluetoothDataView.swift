//
//  BluetoothDataView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import SwiftUI
import CoreBluetooth

struct BluetoothDataView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    let device: CBPeripheral
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List(bluetoothManager.discoveredServices, id: \.uuid) { service in
            NavigationLink(destination: CharacteristicsView(service: service)) {
                ServiceRow(service: service)
            }
        }
        .navigationTitle("Services")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(device.name ?? "Unknown Device")
                        .font(.headline)
                    Text("Connected")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    bluetoothManager.disconnect()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ServiceRow: View {
    let service: CBService
    
    var body: some View {
        VStack(alignment: .leading) {
            if let name = getServiceName(service.uuid) {
                Text(name)
                    .font(.headline)
            }
            Text(service.uuid.uuidString)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // Helper function to get readable names for common services
    func getServiceName(_ uuid: CBUUID) -> String? {
        switch uuid.uuidString {
        case "180A": return "Device Information"
        case "180F": return "Battery"
        case "1800": return "Generic Access"
        case "1801": return "Generic Attribute"
        case "180D": return "Heart Rate"
        case "1812": return "Human Interface Device"
        case "1819": return "Location and Navigation"
        default: return nil
        }
    }
}

// MARK: - Preview Helpers
struct MockService: Identifiable {
    let id = UUID()
    let name: String
    let uuid: String
}

#Preview {
    struct PreviewBluetoothDataView: View {
        let mockServices = [
            MockService(name: "Device Information", uuid: "180A"),
            MockService(name: "Battery Service", uuid: "180F"),
            MockService(name: "Heart Rate", uuid: "180D"),
            MockService(name: "Custom Service", uuid: "FFF0")
        ]
        
        var body: some View {
            List(mockServices) { service in
                NavigationLink(destination: Text("Characteristics for \(service.name)")) {
                    VStack(alignment: .leading) {
                        Text(service.name)
                            .font(.headline)
                        Text(service.uuid)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Services")
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
        PreviewBluetoothDataView()
    }
}
