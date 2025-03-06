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
        // checks export/import of all of the controller types
        for controller in ControllerType.allCases {
            let initialLayout = DefaultLayouts.getLayout(for: controller)
            try LayoutManager.shared.saveLayout(DefaultLayouts.getLayout(for: controller))
            let loadedLayout = try LayoutManager.shared.loadLayout(for: "\(controller.stringValue).plist")
            #expect(loadedLayout == initialLayout)
        }
        
        try LayoutManager.shared.loadLayouts() // load the controllers to make sure the files exist
        #expect(LayoutManager.shared.availableLayouts.count >= 4)
        for controller in ControllerType.allCases {
            #expect(LayoutManager.shared.availableLayouts.contains("\(controller.stringValue).plist"))
        }
    }

}
