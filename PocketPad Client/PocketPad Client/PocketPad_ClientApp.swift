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
    @State private var openedAsImport: Bool = false
    @StateObject private var motionManager = MotionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(motionManager)
                .environmentObject(AlertManager.shared)
                .overlay {
                    LaunchScreen()
                        .opacity(isShowingSplash ? 1.0 : 0.0)
                        .transition(.opacity)
                        .animation(.easeIn, value: isShowingSplash)
                        .onAppear {
                            if isShowingSplash {
                                // Load the controller layouts
                                if !openedAsImport {
                                    // prevent a race condition with onOpenURL
                                    do {
                                        try LayoutManager.shared.updateLayoutFilesForNewFormat() // TODO: Make only run first time (with tutorial)
                                        try LayoutManager.shared.loadLayouts(includeControllerTypes: true)
                                    } catch {
                                        UIApplication.shared.alert(body: error.localizedDescription)
                                    }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isShowingSplash = false
                                }
                                
                                do {
                                    try LayoutManager.shared.setCurrentLayout(to: UserDefaults.standard.string(forKey: "selectedController") ?? ControllerType.getDefaultName())
                                } catch {
                                    // failed to load controller, reset to default
                                    UserDefaults.standard.set(ControllerType.getDefaultName(), forKey: "selectedController")
                                    try! LayoutManager.shared.setCurrentLayout(to: ControllerType.getDefaultName()) // should never fail
                                }
                            }
                        }
                }
                .onOpenURL(perform: { url in
                    // MARK: Importing Layout
                    if url.pathExtension == "pp" {
                        openedAsImport = true
                        do {
                            let importedName = try LayoutManager.shared.importLayoutFile(url: url)
                            try LayoutManager.shared.loadLayouts(includeControllerTypes: true)
                            UIApplication.shared.alert(title: "Successfully imported layout \(importedName)", body: "You can find it inside of the controller list in settings.")
                        } catch {
                            // failed to import layout
                            UIApplication.shared.alert(title: "Failed to import layout \(url.lastPathComponent)", body: error.localizedDescription)
                        }
                    }
                })
        }
    }
}
