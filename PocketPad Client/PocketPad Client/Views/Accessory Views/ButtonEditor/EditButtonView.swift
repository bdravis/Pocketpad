//
//  EditButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 3/28/25.
//

import SwiftUI

struct EditButtonView: View {
    @ObservedObject var button: EditingButtonVM
    
    @Binding var showSymbolPicker: Bool
    @State private var showDeleteAlert: Bool = false
    
    // Values for if the sections are expanded
    @State private var positionExpanded: Bool = false
    @State private var scaleRotExpanded: Bool = true
    @State private var iconExpanded: Bool = true
    @State private var styleExpanded: Bool = true
    
    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }
    
    var body: some View {
        List {
            Section(isExpanded: $positionExpanded) {
                // MARK: X Scale
                EditorSlider(title: "X Scale", hideSlider: true, value: $button.scaledPos.x, min: 0.0, max: 1.0, step: 0.01, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Y Scale
                EditorSlider(title: "Y Scale", hideSlider: true, value: $button.scaledPos.y, min: 0.0, max: 1.0, step: 0.01, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: X Offset
                EditorSlider(title: "X Offset", value: $button.offset.x, min: -300.0, max: 300.0, step: 0.5, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Y Offset
                EditorSlider(title: "Y Offset", value: $button.offset.y, min: -300.0, max: 300.0, step: 0.5, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
            } header: {
                Text("Position")
            }
            
            Section(isExpanded: $scaleRotExpanded) {
                // MARK: Scale
                EditorSlider(title: "Scale", hideSlider: true, value: $button.scale, min: 0.25, max: 4.0, step: 0.05, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Rotation
                EditorSlider(title: "Rotation", hideSlider: true, value: $button.rotation, units: "º", min: 0.0, max: 360.0, step: 1.0, inputWidth: 40, keyboardType: .numberPad, formatter: numberFormatter)
            } header: {
                Text("Scale and Rotation")
            }
            
            if button.type == .regular {
                Section(isExpanded: $iconExpanded) {
                    // MARK: Shape
                    HStack {
                        Picker("Button Shape", selection: $button.shape) {
                            ForEach(RegularButtonShape.allCases, id: \.self) { shape in
                                Text(shape.rawValue).tag(shape)
                            }
                        }
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("ButtonShapePicker")
                    }
                    
                    // MARK: Icon Configuration
                    Toggle("Has Icon", isOn: $button.hasIcon)
                    if button.hasIcon {
                        HStack {
                            Picker("Icon Type", selection: $button.iconType) {
                                ForEach(RegularButtonIconType.allCases, id: \.self) { iconType in
                                    Text(iconType.rawValue).tag(iconType)
                                }
                            }
                            .pickerStyle(.menu)
                            .accessibilityIdentifier("IconTypePicker")
                        }
                        HStack {
                            Text("Icon")
                            Spacer()
                            switch button.iconType {
                            case .Text:
                                TextField("Icon", text: $button.icon)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                                    .autocorrectionDisabled(true)
                                    .accessibilityIdentifier("Icon")
                            case .SFSymbol:
                                Button(action: {
                                    showSymbolPicker.toggle()
                                }) {
                                    Label(button.icon, systemImage: button.icon)
                                }
                                .accessibilityIdentifier("PickSymbolBtn")
                            }
                        }
                    }
                } header: {
                    Text("Icon")
                }
            }
//            else if button.type == .trigger {
//                Section(isExpanded: $iconExpanded) {
//                    Picker("Side", selection: $button.triggerSide) {
//                        ForEach(TriggerSide.allCases, id: \.self) { side in
//                            Text(side.getName()).tag(side.getName())
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                } header: {
//                    Text("Trigger Properties")
//                }
//            }
            if button.type == .regular || button.type == .joystick || button.type == .dpad {
                Section(isExpanded: $styleExpanded) {
                    // MARK: Icon Colors
                    ColorPicker("\(button.type == .regular ? "Icon" : button.type == .joystick ? "Thumbstick" : "Arrow") Color", selection: $button.fgColor)
                    if button.type != .joystick {
                        ColorPicker("Pressed \(button.type == .regular ? "Icon" : "Arrow") Color", selection: $button.fgPressedColor)
                    }
                    
                    // MARK: Background Colors
                    ColorPicker("Background Color", selection: $button.bgColor)
                    if button.type != .joystick {
                        ColorPicker("Pressed BG Color", selection: $button.bgPressedColor)
                    }
                    
                    // MARK: Stroke
                    EditorSlider(title: "Stroke Thickness", value: $button.stroke, min: 0, max: 15, step: 1, inputWidth: 40, keyboardType: .numberPad, formatter: NumberFormatter())
                } header: {
                    Text("Style")
                }
            }
            
            Section {
                Button(action: {
                    showDeleteAlert.toggle()
                }) {
                    Text("Delete Button")
                }
                .accessibilityIdentifier("DeleteButtonBtn")
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
            }
            .alert("Delete Button", isPresented: $showDeleteAlert, actions: {
                Button("Cancel") {
                    showDeleteAlert = false
                }
                Button("Delete") {
                    LayoutManager.shared.deleteButton(inputId: button.inputId)
                    showDeleteAlert = false
                    button.clear()
                }
                .accessibilityIdentifier("ConfirmDelete")
            }, message: {
                Text("Are you sure you want to delete this button? This cannot be undone.")
            })
        }
        .listStyle(.sidebar)
        .background {
            Color(uiColor: .systemGroupedBackground)
                .accessibilityIdentifier("EditBtnList")
        }
    }
}

struct EditorSlider<V>: View where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
    var title: String
    var hideSlider: Bool = false
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
                    Text("\(Double(value), specifier: "%.2f")\(units)")
                }
                .accessibilityIdentifier("Editor\(title)Btn")
                .alert("Enter Value", isPresented: $enterAlert, actions: {
                    TextField(title, value: $enteringValue, formatter: formatter)
                        .keyboardType(keyboardType)
                        .accessibilityIdentifier("EditorValueField")
                    Button("Cancel") {
                        enterAlert = false
                    }
                    Button("Done") {
                        verifyInputRange(v: &enteringValue)
                        value = enteringValue
                        enterAlert = false
                    }
                    .accessibilityIdentifier("EditorDoneBtn")
                }) {
                    Text("Enter a value for \(title).")
                }
            }
            if !hideSlider {
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
                .accessibilityIdentifier("Slider\(title)")
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
