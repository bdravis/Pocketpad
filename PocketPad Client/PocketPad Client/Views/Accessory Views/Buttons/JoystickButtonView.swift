//
//  JoystickButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct JoystickButtonView: View {
    var config: JoystickConfig
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.green)
            Text("Joystick")
        }
    }
}
