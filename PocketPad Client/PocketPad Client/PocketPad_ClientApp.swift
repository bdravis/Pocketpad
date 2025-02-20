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
            if isShowingSplash {
                LaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                isShowingSplash = false
                            }
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
