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
                .fill(.gray)
                .stroke(.black, style: StrokeStyle(lineWidth: 3, lineCap: .square, lineJoin: .bevel))
            
            // Horizontal directional arrows
            HStack {
                DirectionalArrow(rotation: -90, input: config.inputs[.left]) // left arrow
                Spacer()
                DirectionalArrow(rotation: 90, input: config.inputs[.right]) // right arrow
            }
            .frame(maxHeight: DPAD_THICKNESS)
            
            // Vertical directional arrows
            VStack {
                DirectionalArrow(rotation: 0, input: config.inputs[.up]) // up arrow
                Spacer()
                DirectionalArrow(rotation: 180, input: config.inputs[.down]) // down arrow
            }
            .frame(maxWidth: DPAD_THICKNESS)
        }
    }
}

// Style for the directional arrow on the D-Pad
struct DirectionalArrow: View {
    let rotation: Double
    let input: String? // input used for the button action
    
    var body: some View {
        Button(action: {
            // TODO: Button action
        }) {
            Triangle()
                .rotation(.degrees(rotation))
                .stroke(.black)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(4)
        }
    }
}
