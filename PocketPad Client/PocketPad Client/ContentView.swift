//
//  ContentView.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State Variables for Settings
    @State private var isShowingSettings = false
    @State private var isSplitDPad = false
    @State private var selectedController = "Xbox"
    @State private var controllerColor = Color.blue
    @State private var controllerName = ""
    
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(.blue)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 20) {
                    // Title
                    HStack {
                        Text("PocketPad")
                            .font(.largeTitle)
                            .multilineTextAlignment(.leading)
                            .padding()
                        Spacer()
                    }
                    
                    // Bluetooth Connection Status
                    HStack {
                        if let device = bluetoothManager.connectedDevice {
                            if let name = device.name {
                                Text("Connected to '\(name)'")
                                    .foregroundColor(.green)
                                    .bold()
                            } else {
                                Text("Connected")
                                    .foregroundColor(.green)
                                    .bold()
                            }
                        } else {
                            Text("Not connected...")
                                .foregroundColor(.orange)
                                .bold()
                        }
                        Spacer()
                        
                        if bluetoothManager.connectedDevice != nil {
                            Button(action: {
                                bluetoothManager.disconnect()
                            }) {
                                Text("Disconnect")
                                    .font(.system(size: 18))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .background(.red.opacity(0.9))
                            .cornerRadius(25)
                        } else {
                            NavigationLink(destination: BluetoothScannerView()) {
                                Text("Connect")
                                    .font(.system(size: 18))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 2)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            }
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                    
                    // NavigationLink to ControllerView for Debugging
                    HStack {
                        NavigationLink(destination: ControllerView(buttons: DEBUG_BUTTONS)) {
                            Text("Open Debug ControllerView")
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                // Gear Icon for Settings (top-right)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.bouncy) {
                                isShowingSettings = true
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.accentColor)
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle("Controller")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Overlay the SettingsMenuView when isShowingSettings is true
        .overlay(
            ZStack {
                Rectangle()
                    .foregroundStyle(.regularMaterial)
                    .environment(\.colorScheme, .dark) // force dark mode style
                    .opacity(isShowingSettings ? 0.6 : 0.0)
                    .animation(.easeOut, value: isShowingSettings)
                    .ignoresSafeArea()
                    
                if isShowingSettings {
                    SettingsMenuView(
                        isShowingSettings: $isShowingSettings,
                        isSplitDPad: $isSplitDPad,
                        selectedController: $selectedController,
                        controllerColor: $controllerColor,
                        controllerName: $controllerName
                    )
                    .transition(.move(edge: .top))
                }
            }
        )
        // Bluetooth Manager updates (from first version)
        .onChange(of: bluetoothManager.connectedDevice) { device in
            if device != nil {
                bluetoothManager.stopScanning()
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if let service = bluetoothManager.selectedService {
                    if let char = bluetoothManager.discoveredCharacteristics.first(where: { $0.uuid == LATENCY_CHARACTERISTIC }) {
                        let now = Int(Date().timeIntervalSinceReferenceDate * 1000) % 100000
                        service.peripheral?.writeValue(String(now).data(using: .utf8)!, for: char, type: .withoutResponse)
                    }
                    if let char = bluetoothManager.discoveredCharacteristics.first(where: { $0.uuid == PLAYER_ID_CHARACTERISTIC }) {
                        service.peripheral?.writeValue(String(0).data(using: .utf8)!, for: char, type: .withoutResponse)
                    }
                }
            }
        }
        // Overlay the SettingsMenuView when isShowingSettings is true.
        .overlay(
            Group {
                if isShowingSettings {
                    SettingsMenuView(
                        isShowingSettings: $isShowingSettings,
                        isSplitDPad: $isSplitDPad,
                        selectedController: $selectedController,
                        controllerColor: $controllerColor,
                        controllerName: $controllerName
                    )
                    .transition(.move(edge: .top))
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

