//
//  DPadButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

let DPAD_THICKNESS = DEFAULT_BUTTON_SIZE * 0.35 // thickness is 35% of the default button size

struct DPadButtonView: View {
    var config: DPadConfig
    @AppStorage("splitDPad") var split: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            if !split {
                // Background path
                Plus(thickness: DPAD_THICKNESS)
                    .fill(Color(uiColor: .secondarySystemFill))
                    .stroke(.black, style: StrokeStyle(lineWidth: 3, lineCap: .square, lineJoin: .bevel))
                
                // Center Circle
                Circle()
                    .stroke(.black, style: StrokeStyle(lineWidth: 1.5))
                    .frame(width: DPAD_THICKNESS - 8, height: DPAD_THICKNESS - 8)
            }
            
            // Horizontal directional arrows
            HStack {
                DirectionalArrow(split: split, rotation: -90, input: config.inputs[.left], direction: .left, config: config) // left arrow
                Spacer()
                DirectionalArrow(split: split, rotation: 90, input: config.inputs[.right], direction: .right, config: config) // right arrow
            }
            .frame(maxHeight: DPAD_THICKNESS)
            
            // Vertical directional arrows
            VStack {
                DirectionalArrow(split: split, rotation: 0, input: config.inputs[.up], direction: .up, config: config) // up arrow
                Spacer()
                DirectionalArrow(split: split, rotation: 180, input: config.inputs[.down], direction: .down, config: config) // down arrow
            }
            .frame(maxWidth: DPAD_THICKNESS)
        }
    }
}

// Style for the directional arrow on the D-Pad
struct DirectionalArrow: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    var split: Bool
    
    let rotation: Double
    let input: String? // input used for the button action
    let direction: DPadDirection
    let config: DPadConfig // need to know id of config to identify the unique dpad
    
    var body: some View {
        Button(action: {
            // TODO: Button action
            if let service = bluetoothManager.selectedService {
                if let char = bluetoothManager.discoveredCharacteristics.first(where: { $0.uuid == INPUT_CHARACTERISTIC }) {
                    let ui8_playerId: UInt8 = 0 // Assuming one player
                    let ui8_controllerId: UInt8 = 0 // Set constant for now
                    let ui8_inputId : UInt8 = config.inputId
                    let ui8_buttonType : UInt8 = config.type.rawValue
                    let ui8_dpadDirection : UInt8 = direction.rawValue
                    
                    print(ui8_playerId)
                    print(ui8_controllerId)
                    print(ui8_inputId)
                    print(ui8_buttonType)
                    print(ui8_dpadDirection)
                    let data = Data([ui8_playerId, ui8_controllerId, ui8_inputId, ui8_buttonType, ui8_dpadDirection])
                    service.peripheral?.writeValue(data, for: char, type: .withoutResponse)
                }
            }
        }) {
            Triangle()
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineJoin: .round))
                .background(
                    Triangle()
                        .opacity(split ? 1.0 : 0.0)
                )
                .padding(.horizontal, split ? 2 : 4)
                .padding(.bottom, 4)
                .padding(.top, split ? 0 : 4)
                .rotationEffect(.degrees(rotation))
                .aspectRatio(1.0, contentMode: .fit)
        }
        .buttonStyle(DPadButtonStyle(split: split))
    }
}
