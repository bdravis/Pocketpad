//
//  MacroManager.swift
//  PocketPad Client
//
//  Created by Jack Fang on 4/18/25.
//

import Foundation

class MacroManager : ObservableObject {
    static let shared = MacroManager()
    
    // captured inputs
    var currentInputsReceived: [Data] = []
    
    // captures every controller input into an array called inputsReceived
    func sendInput(_ data: Data) {
        currentInputsReceived.append(data)
        print(currentInputsReceived)
    }
    
    func saveMacro() {
        currentInputsReceived = []
    }
}
