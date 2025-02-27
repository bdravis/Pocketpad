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
    
    var body: some View {
        ZStack(alignment: .center) {
            // Background path
            Plus(thickness: DPAD_THICKNESS)
                .fill(Color(uiColor: .secondarySystemFill))
                .stroke(.black, style: StrokeStyle(lineWidth: 3, lineCap: .square, lineJoin: .bevel))
            
            // Center Circle
            Circle()
                .stroke(.black, style: StrokeStyle(lineWidth: 1.5))
                .frame(width: DPAD_THICKNESS - 8, height: DPAD_THICKNESS - 8)
            
            // Horizontal directional arrows
            HStack {
                DirectionalArrow(rotation: -90, input: config.inputs[.left], direction: .left, config: config) // left arrow
                Spacer()
                DirectionalArrow(rotation: 90, input: config.inputs[.right], direction: .right, config: config) // right arrow
            }
            .frame(maxHeight: DPAD_THICKNESS)
            
            // Vertical directional arrows
            VStack {
                DirectionalArrow(rotation: 0, input: config.inputs[.up], direction: .up, config: config) // up arrow
                Spacer()
                DirectionalArrow(rotation: 180, input: config.inputs[.down], direction: .down, config: config) // down arrow
            }
            .frame(maxWidth: DPAD_THICKNESS)
        }
    }
}

// Style for the directional arrow on the D-Pad
struct DirectionalArrow: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    let rotation: Double
    let input: String? // input used for the button action
    let direction: DPadDirection
    let config: DPadConfig // need to know id of config to identify the unique dpad
    
    var body: some View {
        Button(action: {
            // TODO: Button action
            if let service = bluetoothManager.selectedService {
                if let char = bluetoothManager.discoveredCharacteristics.first(where: { $0.uuid == INPUT_CHARACTERISTIC }) {
                    // Create an instance of InputFormat
                    let directional_input = InputFormat(type: ButtonType.dpad.rawValue, inputValue: direction.rawValue, id: config.id)
                    let encoder = JSONEncoder()
                    do {
                        let data = try encoder.encode(directional_input)
                        service.peripheral?.writeValue(data, for: char, type: .withoutResponse)
                    } catch {
                        print("Error encoding directional input")
                    }
                }
            }
        }) {
            Triangle()
                .rotation(.degrees(rotation))
                .aspectRatio(1.0, contentMode: .fit)
                .padding(4)
        }
        .buttonStyle(DPadButtonStyle())
    }
}
