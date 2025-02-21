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
                Color(.blue)
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("PocketPad")
                            .font(.largeTitle)
                            .multilineTextAlignment(.leading)
                            .padding()
                        
                        Spacer()
                    }
                    
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
                    .padding()
                    
                    Spacer()
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
