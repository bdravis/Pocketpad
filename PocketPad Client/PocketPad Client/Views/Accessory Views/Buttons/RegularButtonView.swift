//
//  RegularButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct RegularButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    var config: RegularButtonConfig
    
    @State private var isHolding: Bool = false
    
    // gesture logic that contains the actions for when the button is held
    var buttonHold: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isHolding {
                    // Initial action
                    
                    isHolding = true
                }
                
                // Action while held
                if let service = bluetoothManager.selectedService {
                    let ui8_playerId: UInt8 = 0 // Assuming one player
                    let ui8_inputId : UInt8 = config.inputId
                    let ui8_buttonType : UInt8 = config.type.rawValue
                    
                    // send data continuously
                    let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType])
                    bluetoothManager.sendInput(data)
                }
                
            }
            .onEnded { _ in
                // Action when released
                
                isHolding = false
            }
    }
    
    var body: some View {
        Button(action: {
            // The action for holding is located in the label closure in the gesture modifier
        }) {
            Group {
                if let icon = config.style.icon {
                    switch config.style.iconType {
                    case .Text:
                        Text(icon)
                    case .SFSymbol:
                        ZStack {
                            Image(systemName: icon)
                                .resizable()
                                .scaledToFit() // make sure it does not stretch
                        }
                    }
                } else {
                    Text("") // empty textbox
                }
            }
            .gesture(buttonHold) // apply gesture logic
            
//            if let icon = config.style.icon {
//                switch config.style.iconType {
//                case .Text:
//                    Text(icon)
//                case .SFSymbol:
//                    ZStack {
//                        Image(systemName: icon)
//                            .resizable()
//                            .scaledToFit() // make sure it does not stretch
//                    }
//                }
//            } else {
//                Text("") // empty textbox
//            }
        }
        .applyButtonStyle(shape: config.style.shape)
    }
}
