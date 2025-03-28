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
    
    var body: some View {
        List {
            Section {
                VStack {
                    // MARK: X Scale
                    HStack {
                        Text("X Scale")
                        Spacer()
                        Text("\(layoutManager.currentController.buttons[buttonId].position.scaledPos.x)")
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $layoutManager.currentController.buttons[buttonId].position.scaledPos.x, in: 0...1, step: 0.01) {
                        Text("X")
                    } minimumValueLabel: {
                        Text("0.0")
                    } maximumValueLabel: {
                        Text("1.0")
                    }
                }
                // MARK: Y Scale
                VStack {
                    HStack {
                        Text("Y Scale")
                        Spacer()
                        Text("\(layoutManager.currentController.buttons[buttonId].position.scaledPos.y)")
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $layoutManager.currentController.buttons[buttonId].position.scaledPos.y, in: 0...1, step: 0.01) {
                        Text("Y")
                    } minimumValueLabel: {
                        Text("0.0")
                    } maximumValueLabel: {
                        Text("1.0")
                    }
                }
            } header: {
                Text("Position")
            }
            
            Section {
                VStack {
                    // MARK: Scale
                    HStack {
                        Text("Scale")
                        Spacer()
                        Text("\(layoutManager.currentController.buttons[buttonId].scale * 100)%")
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $layoutManager.currentController.buttons[buttonId].scale, in: 0.25...4.0, step: 0.05) {
                        Text("Scale")
                    } minimumValueLabel: {
                        Text("25%")
                    } maximumValueLabel: {
                        Text("400%")
                    }
                }
                VStack {
                    // MARK: Rotation
                    HStack {
                        Text("Rotation")
                        Spacer()
                        Text("\(layoutManager.currentController.buttons[buttonId].rotation)º")
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $layoutManager.currentController.buttons[buttonId].rotation, in: 0.0...360.0, step: 1.0) {
                        Text("Rotation")
                    } minimumValueLabel: {
                        Text("0º")
                    } maximumValueLabel: {
                        Text("360º")
                    }
                }
            }
        }
    }
}
