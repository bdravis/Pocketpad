//
//  PocketPad_ClientApp.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import SwiftUI
import TipKit

@main
struct PocketPad_ClientApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    @AppStorage("finishedTutorial") var finishedTutorial: Bool = false
    
    @State private var isShowingSplash = true
    @State private var openedAsImport: Bool = false
    @StateObject private var motionManager = MotionManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if finishedTutorial {
                    ContentView()
                } else {
                    OnBoardingView()
                }
            }
            .transition(.opacity)
            .animation(.easeOut(duration: 0.5), value: finishedTutorial)
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
    
    init() {
        // MARK: Launch Arguments
        #if DEBUG
        if CommandLine.arguments.contains("reset-tips") {
            try? Tips.resetDatastore()
        }
        if CommandLine.arguments.contains("hide-tips") {
            Tips.hideAllTipsForTesting()
        } else if CommandLine.arguments.contains("show-tips") {
            Tips.showAllTipsForTesting()
        }
        if CommandLine.arguments.contains("no-tutorial") {
            finishedTutorial = true
        } else if CommandLine.arguments.contains("show-tutorial") {
            finishedTutorial = false
        }
        if CommandLine.arguments.contains("remove-layouts") {
            try? LayoutManager.shared.deleteAllLayouts()
        }
        if CommandLine.arguments.contains("add-debug-layout-no-buttons") {
            try? LayoutManager.shared.saveLayout(LayoutConfig(name: "Debug Layout", buttons: []))
            UserDefaults.standard.set("Debug Layout", forKey: "selectedController")
//            try? LayoutManager.shared.setCurrentLayout(to: "Debug Layout")
        } else if CommandLine.arguments.contains("add-debug-layout-regular-button") {
            try? LayoutManager.shared.saveLayout(LayoutConfig(name: "Debug Layout", buttons: [
                RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.3, y: 0.3)), scale: 1.0, inputId: 0, input: .A)
            ]))
            UserDefaults.standard.set("Debug Layout", forKey: "selectedController")
//            try? LayoutManager.shared.setCurrentLayout(to: "Debug Layout")
        }
        #endif
        
        // Load and configure the state of all the tips of the app
        try? Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.applicationDefault)])
    }
}
