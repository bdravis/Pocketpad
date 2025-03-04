//
//  SettingsMenuView.swift
//  PocketPad
//
//  Created by Bautista Tedin on 2/21/25.
//

import SwiftUI

// MARK: - Layout Constants
private let minMenuWidth: CGFloat = 320
private let minMenuHeight: CGFloat = 500
private let maxWidthFraction: CGFloat = 0.9
private let maxHeightFraction: CGFloat = 0.9

struct SettingsMenuView: View {
    // MARK: - Bound Properties
    @Binding var isShowingSettings: Bool
    
    @AppStorage("splitDPad") var splitDPad: Bool = false
    @AppStorage("selectedController") var selectedController: ControllerType = .Xbox
    @AppStorage("controllerColor") var controllerColor: Color = .blue
    @AppStorage("controllerName") var controllerName: String = "Controller"
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let menuWidth = min(
                max(minMenuWidth, geometry.size.width * 0.5),
                geometry.size.width * maxWidthFraction
            )
            let menuHeight = min(
                max(minMenuHeight, geometry.size.height * 0.5),
                geometry.size.height * maxHeightFraction
            )
            
            ZStack {
                // Background with blur effect and rounded corners
                RoundedRectangle(cornerRadius: 15)
                    .fill(.regularMaterial)
                    .frame(width: menuWidth, height: menuHeight)
                    .shadow(color: Color(.label).opacity(0.25), radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                
                // Menu Content
                VStack(spacing: 0) {
                    headerView
                    Divider()
                        .padding(.bottom, 6)
                    ScrollView {
                        settingsContent
                            .padding(.bottom, 20)
                    }
                    Spacer()
                }
                .frame(width: menuWidth, height: menuHeight)
            }
            // Center the menu on the screen
            .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
        }
    }
    
    // MARK: - Header with Close Button
    private var headerView: some View {
        HStack {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 16)
            Spacer()
            Button {
                isShowingSettings = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Main Settings Content
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Controller Type Picker
            HStack {
                Text("Controller Type")
                    .foregroundColor(.primary)
                Spacer()
                Picker("Controller Type", selection: $selectedController) {
                    ForEach(ControllerType.allCases, id: \.self) { type in
                        Label(type.rawValue, image: type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedController, initial: false) {
                    // update the controller layout
                    do {
                        try LayoutManager.shared.setCurrentLayout(to: selectedController.rawValue)
                    } catch {
                        print(error.localizedDescription)
                        // TODO: alert user of error
                    }
                }
            }
            .padding(.horizontal, 16)
            //Picker for D-PAD (Split (True) vs Conjoined (False))
            if LayoutManager.shared.hasDPad {
                HStack {
                    Text("D-PAD")
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("D-PAD", selection: $splitDPad) {
                        Text("Conjoined").tag(false)
                        Text("Split").tag(true)
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal, 16)
            }
            
            // Controller Color Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Controller Color")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    ColorPicker("", selection: $controllerColor, supportsOpacity: false)
                        .labelsHidden()
                        .padding(.trailing, 16)

                }
                .padding(.horizontal, 16)
            }
            HStack {
                            Text("Controller Name")
                                .foregroundColor(.primary)
                            Spacer()
                            TextField("Enter controller name", text: $controllerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsMenuView(
        isShowingSettings: .constant(true)
    )
}

