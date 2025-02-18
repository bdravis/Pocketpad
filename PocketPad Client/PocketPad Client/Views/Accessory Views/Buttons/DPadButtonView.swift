//
//  DPadButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct DPadButtonView: View {
    var config: DPadConfig
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.green)
            Text("D-Pad")
        }
    }
}
