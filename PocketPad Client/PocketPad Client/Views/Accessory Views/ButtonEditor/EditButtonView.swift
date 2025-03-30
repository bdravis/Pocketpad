//
//  EditButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 3/28/25.
//

import SwiftUI

struct EditButtonView: View {
    @State var buttonId: Int
    @ObservedObject private var layoutManager = LayoutManager.shared
    // TODO: Figure out why it does not continuously update
    
    private var numberFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }
    
    var body: some View {
        List {
            Section {
                // MARK: X Scale
                EditorSlider(title: "X Scale", value: $layoutManager.currentController.buttons[buttonId].position.scaledPos.x, min: 0.0, max: 1.0, step: 0.01, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Y Scale
                EditorSlider(title: "Y Scale", value: $layoutManager.currentController.buttons[buttonId].position.scaledPos.y, min: 0.0, max: 1.0, step: 0.01, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
            } header: {
                Text("Position")
            }
            
            Section {
                // MARK: Scale
                EditorSlider(title: "Scale", value: $layoutManager.currentController.buttons[buttonId].scale, min: 0.25, max: 4.0, step: 0.05, inputWidth: 40, keyboardType: .decimalPad, formatter: numberFormatter)
                // MARK: Rotation
                EditorSlider(title: "Rotation", value: $layoutManager.currentController.buttons[buttonId].rotation, units: "º", min: 0.0, max: 360.0, step: 1.0, inputWidth: 40, keyboardType: .numberPad, formatter: numberFormatter)
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
