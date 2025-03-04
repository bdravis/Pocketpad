//
//  PocketPad_ClientTests.swift
//  PocketPad ClientTests
//
//  Created by lemin on 2/17/25.
//

import Testing
import UIKit
@testable import PocketPad_Client

struct PocketPad_ClientTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func exportBasicControllers() async throws {
        // MARK: Export to Controllers
        try LayoutManager.shared.saveLayout(DefaultLayouts.SwitchConfig)
        
        // MARK: Read Controller Files
        try LayoutManager.shared.loadLayouts()
        let loadedSwitchLayout = try LayoutManager.shared.loadLayout(for: "Switch.plist")
        #expect(loadedSwitchLayout.name == DefaultLayouts.SwitchConfig.name) // TODO: Make this compare the structs as a whole
    }

}
