//
//  ButtonInfoView.swift
//  PocketPad Client
//
//  Created by lemin on 2/19/25.
//

import SwiftUI

let INFO_OVERLAY_SIZE = DEFAULT_BUTTON_SIZE + 6

// this will be the overlay for debugging + will be shown in the layout configurator
struct ButtonInfoView: View {
    @ObservedObject var configVM: EditingButtonVM
    
    var body: some View {
        ZStack {
            // Overlay Rectangle
            Rectangle()
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineJoin: .bevel))
                .frame(width: INFO_OVERLAY_SIZE, height: INFO_OVERLAY_SIZE)
            
            // Position tag
//            HStack {
//                Spacer()
//                Text("(\(Int(config.position.x)), \(Int(config.position.y)))")
//                    .frame(height: 10)
//                    .font(.system(size: 8))
//                    .offset(y: INFO_OVERLAY_SIZE / 2 + 8)
//            }
//            .frame(maxWidth: INFO_OVERLAY_SIZE)
            
            // Scale tag
            HStack {
                Text("\(Int(configVM.scale * 100))%")
                    .frame(height: 10)
                    .font(.system(size: 8))
                    .offset(y: -INFO_OVERLAY_SIZE / 2 - 8)
                Spacer()
            }
            .frame(maxWidth: INFO_OVERLAY_SIZE)
        }
    }
}
