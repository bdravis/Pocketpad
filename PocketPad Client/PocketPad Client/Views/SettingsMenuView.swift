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
    @Binding var isSplitDPad: Bool
    @Binding var selectedController: String
    @Binding var controllerColor: Color
    @Binding var controllerName: String
    
    // MARK: - Local State for Color Grid Toggle
    @State private var showColorGrid: Bool = false
    
    // MARK: - Controller Types
    private let controllerTypes = ["Xbox", "PlayStation", "GameCube", "Switch"]
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            // adaptive menu size based on the available space.
            let menuWidth = min(
                max(minMenuWidth, geometry.size.width * 0.5),
                geometry.size.width * maxWidthFraction
            )
            let menuHeight = min(
                max(minMenuHeight, geometry.size.height * 0.5),
                geometry.size.height * maxHeightFraction
            )
            
            ZStack {
                // Background with blur effect and rounded corners.
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
            // Center the menu on the screen.
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
                withAnimation(.bouncy) {
                    isShowingSettings = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Main Settings Content
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Controller Settings Title
            Text("Controller Settings")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 20)
                .padding(.horizontal, 16)
            
            // Toggle for D-Pad Layout
            Toggle("Split vs Conjoined D-Pad", isOn: $isSplitDPad)
                .padding(.horizontal, 16)
            
            // Controller Type Picker
            Text("Controller Type")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            HStack {
                Spacer()
                Picker("Controller Type", selection: $selectedController) {
                    ForEach(controllerTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 16)
            }
            
            // Controller Color Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Controller Color")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                HStack {
                    // Show the current color as a circle.
                    Circle()
                        .fill(controllerColor)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle().stroke(Color(.separator), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    // Button to open/close the color grid.
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
                
                // Display the color grid if the user tapped "Change Color"
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
                                        showColorGrid = false // Hide the grid after selection
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Controller Name Section
            Text("Controller Name")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            TextField("Enter controller name", text: $controllerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsMenuView(
        isShowingSettings: .constant(true),
        isSplitDPad: .constant(false),
        selectedController: .constant("Xbox"),
        controllerColor: .constant(.blue),
        controllerName: .constant("")
    )
}

