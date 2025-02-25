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
                DirectionalArrow(rotation: -90, input: config.inputs[.left], direction: .left) // left arrow
                Spacer()
                DirectionalArrow(rotation: 90, input: config.inputs[.right], direction: .right) // right arrow
            }
            .frame(maxHeight: DPAD_THICKNESS)
            
            // Vertical directional arrows
            VStack {
                DirectionalArrow(rotation: 0, input: config.inputs[.up], direction: .up) // up arrow
                Spacer()
                DirectionalArrow(rotation: 180, input: config.inputs[.down], direction: .down) // down arrow
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
    
    var body: some View {
        Button(action: {
            // TODO: Button action
            if let service = bluetoothManager.selectedService {
                if let char = bluetoothManager.discoveredCharacteristics.first(where: { $0.uuid == POCKETPAD_CHARACTERISTIC }) {
                    let encoder = JSONEncoder()
                    do {
                        let data = try encoder.encode(direction)
                        service.peripheral?.writeValue(data, for: char, type: .withResponse)
                    } catch {
                        print("Encoding error: DPad input")
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
