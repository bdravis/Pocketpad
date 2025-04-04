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
    @State private var exitAllMenusCallback: (() -> Void)? = nil
    @State private var showModifyBtn = false
    
    @State private var paircode = ""

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
                        if bluetoothManager.bluetoothState != .poweredOn {
                            Text("Bluetooth is Off")
                                .foregroundColor(.red)
                                .bold()
                        } else if let device = bluetoothManager.connectedDevice {
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
                            .opacity(bluetoothManager.bluetoothState != .poweredOn ? 0.5 : 1.0)
                            .disabled(bluetoothManager.bluetoothState != .poweredOn)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = bluetoothManager.connectionError {
                        HStack {
                            Text(error)
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // NavigationLink to ControllerView for Debugging
                    HStack {
                        NavigationLink(destination: ControllerView(isEditor: false)) {
                            Text("Open Debug ControllerView")
                        }
                        .accessibilityIdentifier("OpenControllerView")
                    }
                    .padding(.horizontal)
                    
                    // TODO: Move to settings page (was greyed out so had to add here)
                    if showModifyBtn {
                        NavigationLink(destination: ControllerView(isEditor: true), label: {
                            Text("Modify Layout")
                        })
                        .accessibilityIdentifier("ModifyLayoutView")
                    }
                    
                    Spacer()
                }
                .onAppear {
                    showModifyBtn = !DefaultLayouts.isDefaultLayout(name: LayoutManager.shared.currentController.name)
                }
                
                // Gear Icon for Settings (top-right)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.accentColor)
                                .padding()
                        }
                        .accessibilityIdentifier("SettingsGearButton")
                    }
                    Spacer()
                }
            }
            .navigationTitle("Controller")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Overlay the SettingsMenuView when isShowingSettings is true
        .overlay(
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .foregroundStyle(.black)
                        .opacity(isShowingSettings ? 0.6 : 0.0)
                        .animation(.easeOut, value: isShowingSettings)
                        .ignoresSafeArea()
                        .onTapGesture {
                            exitAllMenusCallback?()
                            isShowingSettings = false
                        }
                    
                    SettingsMenuView(
                        isShowingSettings: $isShowingSettings,
                        exitAllMenusCallback: $exitAllMenusCallback,
                        showModifyBtn: $showModifyBtn
                    )
                        .offset(y: isShowingSettings ? 0 : -geometry.size.height)
                        .transition(.move(edge: .top))
                        .animation(.bouncy, value: isShowingSettings)
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
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                bluetoothManager.pingServer()
            }
        }
        .alert("New Layout", isPresented: $bluetoothManager.paircodeNeeded) {
            TextField("Pair Code", text: $paircode)
                .keyboardType(.numberPad)
            Button("OK", action: {
                if paircode.isEmpty {
                    bluetoothManager.paircodeNeeded = true
                    return
                }
                if paircode.count != 6 {
                    bluetoothManager.paircodeNeeded = true
                    return
                }
                bluetoothManager.sendPaircode(paircode)
            })
            .disabled(paircode.isEmpty || paircode.count != 6)
            Button("Cancel", role: .cancel) {
                bluetoothManager.disconnect()
            }
        } message: {
            Text("Enter the code shown on the GUI")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

