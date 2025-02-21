//
//  ContentView.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State Variables for Settings
    @State private var isShowingSettings = false
    @State private var isSplitDPad = false
    @State private var selectedController = "Xbox"
    @State private var controllerColor = Color.blue
    @State private var controllerName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content with existing NavigationLink
                VStack {
                    NavigationLink(destination: ControllerView(buttons: DEBUG_BUTTONS)) {
                        Text("Open Debug ControllerView")
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Gear icon in the top-right corner
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isShowingSettings = true
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.accentColor)
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle("Controller")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Overlay the SettingsMenuView when isShowingSettings is true.
        .overlay(
            Group {
                if isShowingSettings {
                    SettingsMenuView(
                        isShowingSettings: $isShowingSettings,
                        isSplitDPad: $isSplitDPad,
                        selectedController: $selectedController,
                        controllerColor: $controllerColor,
                        controllerName: $controllerName
                    )
                    .transition(.move(edge: .top))
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
