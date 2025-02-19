//
//  GeneralButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct GeneralButtonView: View {
    var config: any ButtonConfig
    
    var body: some View {
        // Determine what button to show
        if let regularConfig = config as? RegularButtonConfig {
            RegularButtonView(config: regularConfig)
        } else if let joystickConfig = config as? JoystickConfig {
            JoystickButtonView(config: joystickConfig)
        } else if let dpadConfig = config as? DPadConfig {
            DPadButtonView(config: dpadConfig)
        }
    }
}
