//
//  EditButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 3/28/25.
//

import SwiftUI

struct EditButtonView: View {
    @ObservedObject var button: EditingButtonVM
    
    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }
    
    var body: some View {
        List {
            Section {
                // MARK: X Scale
                EditorSlider(title: "X Scale", value: $button.scaledPos.x, min: 0.0, max: 1.0, step: 0.01, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Y Scale
                EditorSlider(title: "Y Scale", value: $button.scaledPos.y, min: 0.0, max: 1.0, step: 0.01, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
            } header: {
                Text("Position")
            }
            
            Section {
                // MARK: Scale
                EditorSlider(title: "Scale", value: $button.scale, min: 0.25, max: 4.0, step: 0.05, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Rotation
                EditorSlider(title: "Rotation", value: $button.rotation, units: "º", min: 0.0, max: 360.0, step: 1.0, inputWidth: 40, keyboardType: .numberPad, formatter: numberFormatter)
            }
            
            if button.type == .regular {
                Section {
                    // MARK: Shape
                    HStack {
                        Text("Button Shape")
                        Spacer()
                        Picker("Shape", selection: $button.shape) {
                            ForEach(RegularButtonShape.allCases, id: \.self) { shape in
                                Text(shape.rawValue).tag(shape)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // MARK: Icon Configuration
                    Toggle("Has Icon", isOn: $button.hasIcon)
                    if button.hasIcon {
                        HStack {
                            Text("Icon Type")
                            Spacer()
                            Picker("Type", selection: $button.iconType) {
                                ForEach(RegularButtonIconType.allCases, id: \.self) { iconType in
                                    Text(iconType.rawValue).tag(iconType)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        HStack {
                            Text("Icon")
                            Spacer()
                            TextField("Icon", text: $button.icon)
                        }
                    }
                } header: {
                    Text("Icon")
                }
            }
            if button.type == .regular || button.type == .joystick || button.type == .dpad {
                Section {
                    // MARK: Icon Colors
                    ColorPicker("\(button.type == .regular ? "Icon" : button.type == .joystick ? "Thumbstick" : "Arrow") Color", selection: $button.fgColor)
                    if button.type != .joystick {
                        ColorPicker("Pressed \(button.type == .regular ? "Icon" : "Arrow") Color", selection: $button.fgPressedColor)
                    }
                    
                    // MARK: Background Colors
                    ColorPicker("Background Color", selection: $button.bgColor)
                    if button.type != .joystick {
                        ColorPicker("Pressed Background Color", selection: $button.bgPressedColor)
                    }
                    
                    // MARK: Stroke
                    EditorSlider(title: "Stroke Thickness", value: $button.stroke, min: 0, max: 15, step: 1, inputWidth: 40, keyboardType: .numberPad, formatter: NumberFormatter())
                } header: {
                    Text("Style")
                }
            }
        }
    }
}

struct EditorSlider<V>: View where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
    var title: String
    @Binding var value: V
    var units: String = ""
    var min: V
    var minLabel: String? = nil
    var max: V
    var maxLabel: String? = nil
    var step: V
    
    var inputWidth: CGFloat
    var keyboardType: UIKeyboardType
    var formatter: Formatter
    
    @State var enterAlert: Bool = false
    @State var enteringValue: V = 0.0
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Button(action: {
                    enteringValue = value
                    enterAlert.toggle()
                }) {
                    Text("\(value)\(units)")
                }
                .alert("Enter Value", isPresented: $enterAlert, actions: {
                    TextField(title, value: $enteringValue, formatter: formatter)
                        .keyboardType(keyboardType)
                    Button("Cancel") {
                        enterAlert = false
                    }
                    Button("Done") {
                        verifyInputRange(v: &enteringValue)
                        value = enteringValue
                        enterAlert = false
                    }
                }) {
                    Text("Enter a value for \(title).")
                }
            }
            Slider(value: $value, in: min...max, step: V.Stride(step)) {
                Text(title)
            } minimumValueLabel: {
                if let minLabel = minLabel {
                    Text(minLabel)
                } else {
                    Text("\(min)\(units)")
                }
            } maximumValueLabel: {
                if let maxLabel = maxLabel {
                    Text(maxLabel)
                } else {
                    Text("\(max)\(units)")
                }
            }
        }
    }
    
    func verifyInputRange(v: inout V) {
        if v < min {
            v = min
        }
        if v > max {
            v = max
        }
    }
}
