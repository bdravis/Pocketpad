//
//  GeneralButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

// Controls where the input data gets sent
func sendControllerInput(_ data: Data, isInMacroEditor: Bool) {
    if isInMacroEditor { // send the inputs to the macro recorder
        // may or may not be saved, depending on whether the recorder is currently on
        MacroManager.shared.sendInput(data, timestamp: Date())
    } else if let service = BluetoothManager.shared.selectedService { // send inputs to server over Bluetooth
        BluetoothManager.shared.sendInput(data)
    } else {
#if DEBUG
        print("Input received but not sent anywhere")
#endif
    }
}
