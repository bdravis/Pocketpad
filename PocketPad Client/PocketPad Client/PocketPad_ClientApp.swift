//
//  PocketPad_ClientApp.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import SwiftUI

@main
struct PocketPad_ClientApp: App {
    @State private var isShowingSplash = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay {
                    LaunchScreen()
                        .opacity(isShowingSplash ? 1.0 : 0.0)
                        .transition(.opacity)
                        .animation(.easeIn, value: isShowingSplash)
                        .onAppear {
                            if isShowingSplash {
                                // Load the controller layouts
                                do {
                                    try LayoutManager.shared.loadLayouts()
                                    try LayoutManager.shared.setCurrentLayout(to: UserDefaults.standard.string(forKey: "selectedController") ?? "Xbox")
                                } catch {
                                    print(error.localizedDescription)
                                    // TODO: Add error popup
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isShowingSplash = false
                                }
                            }
                        }
                }
        }
    }
}
