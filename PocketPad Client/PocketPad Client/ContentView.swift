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
    @AppStorage("connectionType") private var serverType: Int = 0
    
    @State private var paircode = ""

    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var networkManager = NetworkManager.shared
        
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
                    if serverType == 1 {
                        HStack {
                            Image("logo.bluetooth")
                                .resizable()
                                .frame(width: 20, height: 30)
                                .scaledToFill()
                                .foregroundColor(bluetoothManager.bluetoothState != .poweredOn ? .red : .primary)
                            
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
                    } else {
                        // Network
                        HStack {
                            Image(systemName: "wifi")
                                .resizable()
                                .frame(width: 30, height: 23)
                                .scaledToFill()
                                .foregroundColor(!networkManager.networkState ? .red : .primary)
                            
                            if !networkManager.networkState {
                                Text("WiFi is Off")
                                    .foregroundColor(.red)
                                    .bold()
                            } else if networkManager.isConnected {
                                Text("Connected")
                                    .foregroundColor(.green)
                                    .bold()
                            } else {
                                Text("Not connected...")
                                    .foregroundColor(.orange)
                                    .bold()
                            }
                            Spacer()
                            
                            if networkManager.isConnected {
                                Button(action: {
                                    networkManager.disconnect()
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
                                Button(action: {
                                    networkManager.findServerAndConnect(port: 3000)
                                }) {
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
                                .opacity(networkManager.networkState != true ? 0.5 : 1.0)
                                .disabled(networkManager.networkState != true)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let error = networkManager.connectionError {
                            HStack {
                                Text(error)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                    
                    // NavigationLink to ControllerView for Debugging
                    NavigationLink(destination: ControllerView(isEditor: false, isInMacroEditor: false)) {
                        Text("Open Controller")
                            .font(.system(size: 18))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                    }
                    .background(Color.blue)
                    .cornerRadius(25)
                    .frame(minWidth: 250)
                    .accessibilityIdentifier("OpenControllerView")
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .disabled(bluetoothManager.paircodeNeeded && bluetoothManager.connectedDevice != nil)
                    
                    
                    // TODO: Move to settings page (was greyed out so had to add here)
                    if showModifyBtn {
                        NavigationLink(destination: ControllerView(isEditor: true, isInMacroEditor: false), label: {
                            Text("Modify Controller")
                                .font(.system(size: 18))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        })
                        .background(Color.blue)
                        .cornerRadius(25)
                        .frame(minWidth: 250)
                        .disabled(bluetoothManager.paircodeNeeded && bluetoothManager.connectedDevice != nil)
                        .accessibilityIdentifier("ModifyLayoutView")
                    }
                    
                    // MARK: NavigationLink to macro recorder view
                    NavigationLink(destination: ControllerView(isEditor: false, isInMacroEditor: true)) {
                        Text("Record Macro")
                            .font(.system(size: 18))
                            .padding(.horizontal, 23)
                            .padding(.vertical, 5)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 4)
                            )
                    }
                    .background(Color.blue)
                    .cornerRadius(25)
                    .frame(minWidth: 250)
                    .accessibilityIdentifier("RecordMacroView")
                    .padding(.horizontal)
                    .disabled(bluetoothManager.paircodeNeeded && bluetoothManager.connectedDevice != nil)
                    
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
                            isCustomLayout: $showModifyBtn
                        )
                        .offset(y: isShowingSettings ? 0 : -geometry.size.height)
                        .transition(.move(edge: .top))
                        .animation(.bouncy, value: isShowingSettings)
                    }
                }
            )
        }
        .alert("Pair Code Bluetooth", isPresented: $bluetoothManager.paircodeNeeded) {
            TextField("Pair Code", text: $paircode)
                .keyboardType(.numberPad)
            Button("OK", action: {
                if bluetoothManager.paircode != paircode {
                    bluetoothManager.disconnect()
                    bluetoothManager.connectionError = "Incorrect paircode"
                }
                bluetoothManager.paircodeNeeded = false
                paircode = ""
            })
            .disabled(paircode.isEmpty || paircode.count != 6)
            Button("Cancel", role: .cancel) {
                bluetoothManager.disconnect()
            }
        }
        .alert("Pair Code Network", isPresented: $networkManager.pairing) {
            TextField("Pair Code", text: $paircode)
                .keyboardType(.numberPad)
            Button("OK", action: {
                networkManager.sendPaircode(paircode)
                paircode = ""
            })
            .disabled(paircode.isEmpty || paircode.count != 6)
            Button("Cancel", role: .cancel) {
                networkManager.disconnect()
            }
        }
        // Bluetooth Manager updates (from first version)
        .onChange(of: bluetoothManager.connectedDevice) { device in
            if device != nil {
                bluetoothManager.stopScanning()
            }
        }
//        .onAppear {
//            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                bluetoothManager.pingServer()
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

