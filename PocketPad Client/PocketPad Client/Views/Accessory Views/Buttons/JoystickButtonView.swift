//
//  JoystickButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

let STICK_SIZE: CGFloat = DEFAULT_BUTTON_SIZE / 3

struct JoystickButtonView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    var config: JoystickConfig

    @State private var offset: CGSize = .zero
    @State private var hapticTriggered: Bool = false
    
    private var STICK_SIZE: CGFloat {
        return DEFAULT_BUTTON_SIZE / 3
    }
    
    private var deadzoneRadius: Double {
//        return (DEFAULT_BUTTON_SIZE / 2) * 0.4 // hardcoded 40% deadzone for testing
        
        return (DEFAULT_BUTTON_SIZE / 2) * config.deadzone
        
    }

    var joyDrag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let dx = value.translation.width
                let dy = value.translation.height
                let dist = sqrt(dx * dx + dy * dy)
                let angle = atan2(dy, dx)

                let clampedDistance = min(dist, DEFAULT_BUTTON_SIZE / 2)
                
//#if DEBUG
//                    print("Joystick moved distance: \(clampedDistance)")
//#endif
                
                offset = CGSize(
                    width: cos(angle) * clampedDistance,
                    height: sin(angle) * clampedDistance
                )
            
//#if DEBUG
//                print("Joystick moved: \(offset)") // Debugging output
//                print("deadzone value is \(config.deadzone)")
//#endif
                
                if (clampedDistance >= deadzoneRadius) {
#if DEBUG
                    print("SENDING, OUTSIDE DEADZONE)")
                    if !hapticTriggered && dist > 5 {
                        if UserDefaults.standard.bool(forKey: "hapticsEnabled") {
                            HapticsManager.playHaptic()
                        }
                      hapticTriggered = true
                    }
#endif
                    if let service = bluetoothManager.selectedService {
                        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
                        let ui8_inputId : UInt8 = config.inputId
                        let ui8_buttonType : UInt8 = config.type.rawValue
                        let ui8_event : UInt8 = ButtonEvent.pressed.rawValue
                        
                        var degrees = angle * 180 / .pi
                        while degrees < 0 {
                            degrees += 360
                        }
                        while degrees > 360 {
                            degrees -= 360
                        }
                        let ui8_angle: UInt8
                        if degrees.isNaN || degrees.isInfinite {
                            ui8_angle = 0
                        } else {
                            ui8_angle = UInt8(Int((degrees * 256 / 360)) & 255)
                        }
                        // Convert to degrees in range of 255
                        
                        let normalizedMagnitude = (clampedDistance - deadzoneRadius) / (DEFAULT_BUTTON_SIZE / 2 - deadzoneRadius) * 100
//#if DEBUG
//                    print("Normalized magnitude: \(normalizedMagnitude)")
//#endif
                        let ui8_magnitude: UInt8
                        if normalizedMagnitude.isNaN || normalizedMagnitude.isInfinite {
                            ui8_magnitude = 0
                        } else {
                            ui8_magnitude = UInt8(min(max(normalizedMagnitude, 0), 255))
                        }
                        
                        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_angle, ui8_magnitude])
                        bluetoothManager.sendInput(data)
                    }
                } else {
#if DEBUG
                    print("NOT SENDING, WITHIN DEADZONE)")
#endif
                }
            }
            .onEnded { _ in
                if let service = bluetoothManager.selectedService {
                    let ui8_playerId: UInt8 = LayoutManager.shared.player_id
                    let ui8_inputId : UInt8 = config.inputId
                    let ui8_buttonType : UInt8 = config.type.rawValue
                    let ui8_event : UInt8 = ButtonEvent.released.rawValue
                    
                    let ui8_angle : UInt8 = UInt8(0) // Convert to degrees
                    let ui8_magnitude : UInt8 = UInt8(0) // Convert to percentage
                    
                    let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_angle, ui8_magnitude])
                    bluetoothManager.sendInput(data)
                }
                
                if UserDefaults.standard.bool(forKey: "hapticsEnabled") {
                    HapticsManager.playHaptic()
                }
                
                withAnimation(.easeOut(duration: 0.15)) {
                    offset = .zero // Reset to center when released
                }
                hapticTriggered = false
            }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(config.style.color ?? Color(uiColor: .secondarySystemFill))
                .strokeBorder(Color(uiColor: .secondaryLabel), lineWidth: config.style.borderThickness)
                .contentShape(Rectangle())
            
            // Circle indicating deadzone
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 2 * deadzoneRadius, height: 2 * deadzoneRadius)

            Circle()
                .foregroundStyle(config.style.foregroundColor ?? Color(uiColor: .darkGray))
                .frame(width: STICK_SIZE, height: STICK_SIZE)
                .offset(offset)
                .highPriorityGesture(joyDrag)
            
        }
    }
}
//
//#Preview {
//    ControllerView(layout: .init(name: "Joystick Debug", landscapeButtons: [JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1, inputId: 4, input: "RightJoystick")], portraitButtons: [JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1, inputId: 4, input: "RightJoystick")]))
//}
