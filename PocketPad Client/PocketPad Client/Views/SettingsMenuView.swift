//
//  SettingsMenuView.swift
//  PocketPad
//
//  Created by Bautista Tedin on 2/21/25.
//

import SwiftUI

// MARK: - Example Colors for the Grid
private let availableColors: [Color] = [
    .red, .blue, .green, .orange,
    .yellow, .purple, .pink, .gray
]

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
    @AppStorage("controllerName") var controllerName: String = "Enter controller name"
    
    // MARK: - Local State for Color Grid Toggle
    @State private var showColorGrid: Bool = false
    
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
        .padding(.vertical, 16)
    }
    
    // MARK: - Main Settings Content
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Controller Type Picker
            HStack {
                Text("Controller Type")
                    .foregroundColor(.primary)
                Spacer()
                Picker("Controller Type", selection: $selectedController) {
                    ForEach(ControllerType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal, 16)
            //Picker for D-PAD (Split (True) vs Conjoined (False))
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
            
            // Controller Color Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Controller Color")
                        .foregroundColor(.primary)
                    Spacer()
                    Circle()
                        .fill(controllerColor)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle().stroke(Color(.separator), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showColorGrid.toggle()
                        }
                    }) {
                        Text("Change Color")
                    }
                    .padding(.trailing, 16)
                }
                .padding(.horizontal, 16)
                
                if showColorGrid {
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(availableColors, id: \.self) { color in
                            Rectangle()
                                .fill(color)
                                .frame(height: 44)
                                .cornerRadius(8)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .opacity(controllerColor == color ? 1 : 0)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        controllerColor = color
                                        showColorGrid = false
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
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

