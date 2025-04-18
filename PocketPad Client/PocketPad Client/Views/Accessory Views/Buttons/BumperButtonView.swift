//
//  BumperButtonView.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//
//  Edited by Benjamin Dravis on 4/13/25
//

import SwiftUI

struct BumperButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @StateObject private var turboManager = TurboManager.shared
    @StateObject private var macroManager = MacroManager.shared
    @State private var longPressed = false
    
    var config: BumperConfig
    var isInMacroEditor: Bool = false
    
    var body: some View {
        Button(action: {
            if !longPressed {
                handleTap()
            }
            longPressed = false
        }) {
            if let icon = config.style.icon {
                switch config.style.iconType {
                case .Text:
                    Text(icon)
                case .SFSymbol:
                    ZStack {
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit() // make sure it does not stretch
                    }
                }
            } else {
                Text("") // empty textbox
            }
        }
        .applyButtonStyle(config.style, isTurboEnabled: turboManager.isTurboEnabled(config.input))
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50, pressing: { isPressing in
            if isPressing {
                longPressed = true
                if turboManager.turboActive { // turbo button is being held and then another button is pressed
                    turboManager.toggleTurboForButton(config.input)
                } else if turboManager.isTurboEnabled(config.input) { // while turbo is not being held, a turbo-enabled button is held
                    turboManager.startTurboForButton(
                        config.input,
                        buttonPressHandler: sendBumperPress,
                        buttonReleaseHandler: sendBumperRelease
                    )
                } else { // turbo button is not being held, button is not turbo-enabled
                    // this case is a simple button press/hold
                    sendBumperPress()
                }
            }
            else {
                if !turboManager.turboActive { // if turbo button is not being held
                    // note: for the case of turbo button being held, do nothing to avoid duplicate toggling of turbo for a button
                                
                    // if turbo button is not being held:
                    sendBumperRelease()
                    if (turboManager.isTurboEnabled(config.input)) { // the released button is a turbo-enabled button
                        turboManager.stopTurboForButton(config.input)
                    }
                }
            }
        }, perform: {})
                
    }
            
    private func handleTap() {
#if DEBUG
        print("Bumper Tapped")
#endif
        sendBumperPress()
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            sendBumperRelease()
        }
    }
            
    private func sendBumperPress() {
#if DEBUG
        print("PRESS BUMPER")
#endif
        if let service = bluetoothManager.selectedService {
            let ui8_playerId: UInt8 = LayoutManager.shared.player_id
            let ui8_inputId : UInt8 = config.inputId
            let ui8_buttonType : UInt8 = config.type.rawValue
            let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
                    
            let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
            bluetoothManager.sendInput(data)
        }
    }
            
    private func sendBumperRelease() {
#if DEBUG
        print("RELEASE BUMPER")
#endif
        if let service = bluetoothManager.selectedService {
            let ui8_playerId: UInt8 = LayoutManager.shared.player_id
            let ui8_inputId : UInt8 = config.inputId
            let ui8_buttonType : UInt8 = config.type.rawValue
            let ui8_event : UInt8 = ButtonEvent.released.rawValue
                    
            let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event])
            bluetoothManager.sendInput(data)
        }
    }
}

//
//#Preview {
//    ControllerView(layout: .init(name: "Bumper Debug", landscapeButtons: [BumperConfig(position: CGPoint(x: 100, y: 200), scale: 2, inputId: 4, input: "LB")], portraitButtons: [BumperConfig(position: CGPoint(x: 100, y: 200), scale: 2, inputId: 4, input: "LB")]))
//}
