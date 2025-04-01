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
                    
                    // MARK: Icon Colors
                    ColorPicker("Icon Color", selection: $button.fgColor)
                    ColorPicker("Pressed Icon Color", selection: $button.fgPressedColor)
                    
                    // MARK: Background Colors
                    ColorPicker("Background Color", selection: $button.bgColor)
                    ColorPicker("Pressed Background Color", selection: $button.bgPressedColor)
                    
                    // MARK: Stroke
                    EditorSlider(title: "Stroke Thickness", value: $button.stroke, min: 0, max: 15, step: 1, inputWidth: 40, keyboardType: .numberPad, formatter: NumberFormatter())
                } header: {
                    Text("Style")
                }
            }
//            } else if button.type == .joystick || button.type == .dpad {
//                Section {
//                    // MARK: Icon Colors
//                    ColorPicker("\(button.type == .joystick ? "Thumbstick" : "Icon") Color", selection: $fgColor)
//                        .onChange(of: fgColor) {
//                            var newStyle = ((button as? JoystickConfig)?.style ?? (button as! DPadConfig).style)
//                            newStyle.foregroundColor = fgColor
//                            button.updateStyle(to: newStyle)
//                        }
//                    if button.type == .dpad {
//                        ColorPicker("Pressed Icon Color", selection: $fgPressedColor)
//                            .onChange(of: fgPressedColor) {
//                                var newStyle = ((button as? JoystickConfig)?.style ?? (button as! DPadConfig).style)
//                                newStyle.foregroundPressedColor = fgPressedColor
//                                button.updateStyle(to: newStyle)
//                            }
//                    }
//                    
//                    // MARK: Background Colors
//                    ColorPicker("Background Color", selection: $bgColor)
//                        .onChange(of: bgColor) {
//                            var newStyle = ((button as? JoystickConfig)?.style ?? (button as! DPadConfig).style)
//                            newStyle.color = bgColor
//                            button.updateStyle(to: newStyle)
//                        }
//                    if button.type == .dpad {
//                        ColorPicker("Pressed Background Color", selection: $bgPressedColor)
//                            .onChange(of: bgPressedColor) {
//                                var newStyle = ((button as? JoystickConfig)?.style ?? (button as! DPadConfig).style)
//                                newStyle.pressedColor = bgPressedColor
//                                button.updateStyle(to: newStyle)
//                            }
//                    }
//                    
//                    // MARK: Stroke
//                    EditorSlider(title: "Stroke Thickness", value: $stroke, min: 0, max: 15, step: 1, inputWidth: 40, keyboardType: .numberPad, formatter: NumberFormatter())
//                        .onChange(of: stroke) {
//                            var newStyle = (button as! RegularButtonConfig).style
//                            newStyle.properties.borderThickness = stroke
//                            button.updateStyle(to: newStyle)
//                        }
//                } header: {
//                    Text("Style")
//                }
//            }
//        }
//        .onAppear {
//            if button.type == .regular {
//                bgColor = (button as! RegularButtonConfig).style.properties.color ?? Color(uiColor: .secondarySystemFill)
//            }
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
