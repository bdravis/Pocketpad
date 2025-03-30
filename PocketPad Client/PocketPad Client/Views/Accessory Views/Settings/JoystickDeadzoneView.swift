//
//  JoystickDeadzoneView.swift
//  PocketPad Client
//
//  Created by Jack Fang on 3/16/25.
//

import SwiftUI

// MARK: - Layout Constants
private let minMenuWidth: CGFloat = 320
private let minMenuHeight: CGFloat = 500
private let maxWidthFraction: CGFloat = 0.9
private let maxHeightFraction: CGFloat = 0.9

private let circleSize: CGFloat = 200
private let circleStrokeWidth: CGFloat = 2

struct JoystickDeadzoneView: View {
    // MARK: - Bound Properties
    @Binding var isShowingDeadzoneView: Bool
    @Binding var deadzoneValue: Double // Value from 0 to 1
    @Binding var joystickName: String
    
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
                    deadzoneContent
                    Spacer()
                }
                .frame(width: menuWidth, height: menuHeight)
                
            }
            .onChange(of: deadzoneValue) { newValue in
                if joystickName == "Left Joystick" {
                    LayoutManager.shared.updateLeftJoystickDeadzone(newValue)
                } else if joystickName == "Right Joystick" {
                    LayoutManager.shared.updateRightJoystickDeadzone(newValue)
                }
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
            Text("\(joystickName) Deadzone")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 16)
            Spacer()
            Button {
                isShowingDeadzoneView = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }
            .accessibilityIdentifier("DeadzoneCloseButton")
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Deadzone Content
    private var deadzoneContent: some View {
        HStack(alignment: .center, spacing: 20) {
            // Circles to visualize joystick deadzone
            ZStack {
                // Outer circle (joystick area)
                Circle()
                    .stroke(Color.gray, lineWidth: circleStrokeWidth)
                    .frame(width: circleSize, height: circleSize)
                
                // Inner circle (joystick deadzone)
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: circleSize * deadzoneValue, height: circleSize * deadzoneValue)
                
                // Point for center
                Circle()
                    .fill(Color.black)
                    .frame(width: 4, height: 4)
            }
            .padding(.leading, 20)
                
            // Slider Container
            VStack(alignment: .center, spacing: 8) {
                Text("100%")
                    .font(.caption)
                
                GeometryReader { sliderGeometry in
                    // Actual slider object
                    Slider(value: $deadzoneValue, in: 0...1, step: 0.01)
                        .rotationEffect(.degrees(-90))
                        .frame(width: sliderGeometry.size.height, height: sliderGeometry.size.width)
                        .position(x: sliderGeometry.size.width / 2, y: sliderGeometry.size.height / 2)
                        .accessibilityIdentifier("\(joystickName)DeadzoneSlider")

                }
                .aspectRatio(0.2, contentMode: .fit)
                
                Text("0%").font(.caption)
                
                Text("\(Int(deadzoneValue * 100))%")
                    .font(.subheadline)
                    .bold()
                    .padding(.top, 10)
                    .frame(width: 60)
            }
            .padding(.horizontal, 16)
            
        }
        .padding(.vertical, 20)
    }
    
    
}

#Preview {
    JoystickDeadzoneView(
        isShowingDeadzoneView: .constant(true),
        deadzoneValue: .constant(0.0),
        joystickName: .constant("Middle Joystick")
    )
}
