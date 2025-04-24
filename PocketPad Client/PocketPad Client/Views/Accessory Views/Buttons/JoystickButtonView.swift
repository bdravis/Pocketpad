//
//  JoystickButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//
//  Edited by Benjamin Dravis on 4/13/25
//

import SwiftUI

let STICK_SIZE: CGFloat = DEFAULT_BUTTON_SIZE / 3

struct JoystickButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @ObservedObject private var turboManager = TurboManager.shared
    @AppStorage("joystickSensitivity") private var joystickSensitivity: Double = 1.0
    
    var config: JoystickConfig
    var isInMacroEditor: Bool = false
    
    @State private var offset: CGSize = .zero
    @State private var hapticTriggered: Bool = false
    @State private var isSendingPress: Bool = false
    
    private var STICK_SIZE: CGFloat { return DEFAULT_BUTTON_SIZE / 3 }
    
    private var deadzoneRadius: Double { return (DEFAULT_BUTTON_SIZE / 2) * config.deadzone }
    
    @State private var last_send_time: Date? = nil
    @State private var last_sent_angle: UInt8 = 0
    @State private var last_sent_magnitude: UInt8 = 0
    
    let minimum_time_interval: TimeInterval = 0.05
    let minimum_angle_threshold: UInt8 = 2
    let minimum_magnitude_threshold: UInt8 = 5
    
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
                    isSendingPress = true
#if DEBUG
                    print("OUTSIDE DEADZONE")
                    if !hapticTriggered && dist > 5 {
                        if UserDefaults.standard.bool(forKey: "hapticsEnabled") {
                            HapticsManager.playHaptic()
                        }
                      hapticTriggered = true
                    }
#endif
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
                    // Apply sensitivity multiplier
                    let adjustedMagnitude = normalizedMagnitude * joystickSensitivity
//#if DEBUG
//                    print("Normalized magnitude: \(normalizedMagnitude)")
//#endif
                    let ui8_magnitude: UInt8
                    if adjustedMagnitude.isNaN || adjustedMagnitude.isInfinite {
                        ui8_magnitude = 0
                    } else {
                        ui8_magnitude = UInt8(min(max(adjustedMagnitude, 0), 255))
                    }
                    
                    // Don't send input information if it's too soon
                    let now = Date()
                    if let last_time = last_send_time, now.timeIntervalSince(last_time) < minimum_time_interval { return }
                    
                    // Don't send if joystick has not moved much from the last position
                    if abs(Int(ui8_angle) - Int(last_sent_angle)) < Int(minimum_angle_threshold) &&
                        abs(Int(ui8_magnitude) - Int(last_sent_magnitude)) < Int(minimum_angle_threshold) {
                        return
                    }
                    
                    last_send_time = now
                    last_sent_angle = ui8_angle
                    last_sent_magnitude = ui8_magnitude
                    
                    let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_angle, ui8_magnitude])
                    
                    func sendButtonPress() { // nested function to use as callback because we need to know angle and magnitude
#if DEBUG
                        print("SEND JOYSTICK PRESS")
#endif
                        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
                    }
                    
                    // Handle the joystick press, e.g. send data
                    turboManager.handleButtonPressThroughTurbo(
                        input: config.input,
                        isTurboButton: false,
                        sendButtonPressFunc: sendButtonPress,
                        sendButtonRelaseFunc: sendButtonRelease,
                        isInMacroEditor: isInMacroEditor
                    )
                } else {
#if DEBUG
                    print("INSIDE DEADZONE")
#endif
                    if isSendingPress {
                        isSendingPress = false
                        handleButtonRelease()
                    }
                }
            }
            .onEnded { _ in
                handleButtonRelease()
                
                if UserDefaults.standard.bool(forKey: "hapticsEnabled") {
                    HapticsManager.playHaptic()
                }
                
                withAnimation(.easeOut(duration: 0.15)) {
                    offset = .zero // Reset to center when released
                }
                hapticTriggered = false
            }
        
    }
    
    // MARK: Helper functions for input sending
    func handleButtonRelease() {
        turboManager.handleButtonReleaseThroughTurbo(input: config.input, isTurboButton: false, sendButtonReleaseFunc: sendButtonRelease)
    }
    
    func sendButtonRelease() {
#if DEBUG
        print("SEND JOYSTICK RELEASE")
#endif
        let ui8_playerId: UInt8 = LayoutManager.shared.player_id
        let ui8_inputId : UInt8 = config.inputId
        let ui8_buttonType : UInt8 = config.type.rawValue
        let ui8_event : UInt8 = ButtonEvent.released.rawValue
        
        let ui8_angle : UInt8 = UInt8(0) // Convert to degrees
        let ui8_magnitude : UInt8 = UInt8(0) // Convert to percentage
        
        let data = Data([ui8_playerId, ui8_inputId, ui8_buttonType, ui8_event, ui8_angle, ui8_magnitude])
        sendControllerInput(data, isInMacroEditor: isInMacroEditor)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(getBGColor())
                .strokeBorder(getStrokeColor(), lineWidth: config.style.borderThickness)
                .contentShape(Rectangle())
            
            // Circle indicating deadzone
            Circle()
                .fill(Color.blue.opacity(0.5))
                .frame(width: 2 * deadzoneRadius, height: 2 * deadzoneRadius)

            Circle()
                .foregroundStyle(getFGColor())
                .frame(width: STICK_SIZE, height: STICK_SIZE)
                .offset(offset)
                .highPriorityGesture(joyDrag)
            
        }
    }
    
    /* Color Getter Functions */
    func getBGColor() -> Color {
        return (
            colorScheme == .dark ? config.style.darkModeColors.color
            : config.style.lightModeColors.color
        ) ?? DefaultColors.joystick.color
    }
    func getFGColor() -> Color {
        return (
            colorScheme == .dark ? config.style.darkModeColors.foregroundColor
            : config.style.lightModeColors.foregroundColor
        ) ?? DefaultColors.joystick.foregroundColor
    }
    func getStrokeColor() -> Color {
        return (
            colorScheme == .dark ? config.style.darkModeColors.strokeColor
            : config.style.lightModeColors.strokeColor
        ) ?? DefaultColors.joystick.strokeColor
    }
}
//
//#Preview {
//    ControllerView(layout: .init(name: "Joystick Debug", landscapeButtons: [JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1, inputId: 4, input: "RightJoystick")], portraitButtons: [JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1, inputId: 4, input: "RightJoystick")]))
//}
