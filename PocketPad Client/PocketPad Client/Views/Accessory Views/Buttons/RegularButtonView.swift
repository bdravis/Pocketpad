//
//  RegularButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct RegularButtonView: View {
    var config: RegularButtonConfig
    
    var body: some View {
        Button(action: {
            // TODO: Button action
        }) {
            Text(config.input)
        }
        .buttonStyle(CircularButtonStyle()) // TODO: Fix the hitbox being a square
    }
}
