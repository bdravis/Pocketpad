//
//  JoystickButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

let STICK_SIZE = DEFAULT_BUTTON_SIZE / 3

struct JoystickButtonView: View {
    var config: JoystickConfig
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .strokeBorder(.black, style: StrokeStyle(lineWidth: 3))
                .foregroundStyle(Color(uiColor: .secondarySystemFill))
            
            // Stick itself
            Circle()
                .frame(width: STICK_SIZE, height: STICK_SIZE)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }
}
