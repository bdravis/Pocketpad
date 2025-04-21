//
//  MacroSettingsView.swift
//  PocketPad Client
//
//  Created by Jack Fang on 4/20/25.
//

import SwiftUI

// MARK: - Layout constants

private let minMenuWidth: CGFloat = 320
private let minMenuHeight: CGFloat = 500
private let maxWidthFraction: CGFloat = 0.9
private let maxHeightFraction: CGFloat = 0.9

struct MacroSettingsView: View {
    // MARK: - Bound properties
    @Binding var isShowingMacroSettings: Bool
    @ObservedObject private var macroManager = MacroManager.shared
    
    // MARK: - Initializer
    init(isShowingMacroSettings: Binding<Bool>) {
        self._isShowingMacroSettings = isShowingMacroSettings
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
                    macroListContent
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
            Text("Macro Settings")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 16)
            Spacer()
            Button {
                isShowingMacroSettings = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }
            .accessibilityIdentifier("MacroSettingsCloseButton")
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Macro Content
    private var macroListContent: some View {
        let macroNames: [String] = macroManager.getMacroNames()
        return List {
            Section {
                ForEach(macroNames, id: \.self) { macroName in // it is guaranteed that every macro has a unique name
                    HStack {
                        Text(macroName)
                        Spacer()
                        Button(action: {
                            macroManager.deleteMacro(named: macroName)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                Text("List of Macros")
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
        }
    }
}

