//
//  TurboSettingsView.swift
//  PocketPad Client
//
//  Created by Jack Fang on 3/31/25.
//

import SwiftUI

// MARK: - Layout constants

private let minMenuWidth: CGFloat = 320
private let minMenuHeight: CGFloat = 500
private let maxWidthFraction: CGFloat = 0.9
private let maxHeightFraction: CGFloat = 0.9

struct TurboSettingsView : View {
    // MARK: - Bound properties
    @Binding var isShowingTurboSettings: Bool
    @ObservedObject private var turboManager = TurboManager.shared
    @State private var tempTurboRate: Double
    
    // MARK: - Initializer
    init(isShowingTurboSettings: Binding<Bool>) {
        self._isShowingTurboSettings = isShowingTurboSettings
        self._tempTurboRate = State(initialValue: TurboManager.shared.turboRate)
    }
    
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
                    turboRateContent
                    Spacer()
                    
                    // Apply Button
                    Button(action: {
                        turboManager.setTurboRate(tempTurboRate)
                        isShowingTurboSettings = false
                    }) {
                        Text("Apply")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .accessibilityIdentifier("ApplyTurboRateButton")
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
            Text("Turbo Settings")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 16)
            Spacer()
            Button {
                isShowingTurboSettings = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }
            .accessibilityIdentifier("TurboSettingsCloseButton")
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Turbo Rate Content
    private var turboRateContent : some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Turbo Repeat Rate")
                .font(.headline)
                .padding(.top, 20)
            
            // Slider to adjust repeat rate
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $tempTurboRate, in: 1...30, step: 1)
                    .accessibilityIdentifier("TurboRateSlider")
                
                Text("30")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Text("\(Int(tempTurboRate)) presses per second")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
        }
        .padding()
    }
}
