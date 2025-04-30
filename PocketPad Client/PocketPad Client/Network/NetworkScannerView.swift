//
//  NetworkChooserView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 4/30/25.
//

import SwiftUI
import Network

struct NetworkScannerView : View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var networkManager = NetworkManager.shared
    
    @State private var selectedServer: NWEndpoint?
    
    var body : some View {
        List(networkManager.discoveredServers, id: \.debugDescription) { server in
            NWDeviceRow(server: server, selectedServer: $selectedServer)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Available Servers")
        .onAppear {
            networkManager.browseServers()
        }
        .onDisappear {
            networkManager.stopBrowsing()
        }
        .onChange(of: networkManager.isConnected) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct NWDeviceRow: View {
    let server: NWEndpoint
    @Binding var selectedServer: NWEndpoint?
    @StateObject private var networkManager = NetworkManager.shared
    
    var name: String? {
        if case let NWEndpoint.service(name, _, _, _) = server {
            return name
        }
        return nil
    }
    
    var body: some View {
        Button(action: {
            selectedServer = server
            networkManager.connect(to: server)
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(name ?? "Unknown Server")
                        .font(.headline)
//                    Text(device.identifier.uuidString)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
                }
                
                if networkManager.isConnecting && selectedServer == server {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .onChange(of: networkManager.isConnected) { _ in
            if networkManager.isConnected {
                networkManager.stopBrowsing()
            }
        }
    }
}
