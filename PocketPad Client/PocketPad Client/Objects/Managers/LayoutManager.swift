//
//  LayoutManager.swift
//  PocketPad Client
//
//  Created by lemin on 3/4/25.
//

import Foundation

class LayoutManager {
    static let shared = LayoutManager() // create a data singleton
    
    var player_id: UInt8 = 0
    
    var availableLayouts: [String] = []
    
    // Current Layout Information
    var currentController: LayoutConfig = .init(name: "DEBUG", landscapeButtons: [], portraitButtons: [])
    var hasDPad: Bool = false
    
    func getLayoutsFolder() -> URL {
        // get a url for the layouts directory in the app's save files
        let url = URL.documentsDirectory.appendingPathComponent("Layouts", conformingTo: .directory)
        if !FileManager.default.fileExists(atPath: url.path()) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
            }
        }
        return url
    }
    
    func saveLayout(_ layout: LayoutConfig) throws {
        let encoder = PropertyListEncoder()
        let data = try encoder.encode(layout)
        let url = getLayoutsFolder().appendingPathComponent("\(layout.name).plist", conformingTo: .propertyList)
        try data.write(to: url)
        print("written to \(url.absoluteString)")
    }
    
    func saveMalformedLayout(_ layout: LayoutConfig) throws {
        // for testing, malform the file by encoding as a json instead
        let encoder = JSONEncoder()
        let data = try encoder.encode(layout)
        let url = getLayoutsFolder().appendingPathComponent("\(layout.name).plist", conformingTo: .propertyList)
        try data.write(to: url)
        print("written to \(url.absoluteString)")
    }
    
    func deleteAllLayouts() throws {
        // delete the files for all layouts
        availableLayouts.removeAll(keepingCapacity: false)
        let url = getLayoutsFolder()
        for name in try FileManager.default.contentsOfDirectory(atPath: url.path()) {
            do {
                try FileManager.default.removeItem(at: url.appendingPathComponent(name, conformingTo: .propertyList))
                print("removed \(name)")
            } catch {
                print("failed to remove \(name): \(error.localizedDescription)")
            }
        }
    }
    
    func loadLayouts(includeControllerTypes: Bool = false) throws {
        // load the list of file names from layouts
        availableLayouts.removeAll(keepingCapacity: true)
        // load the controller types enum first
        if includeControllerTypes {
            for controllerType in ControllerType.allCases {
                availableLayouts.append(controllerType.stringValue)
            }
        }
        
        let url = getLayoutsFolder()
        for name in try FileManager.default.contentsOfDirectory(atPath: url.path()) {
            availableLayouts.append(name.replacingOccurrences(of: ".plist", with: ""))
        }
    }
    
    func loadLayout(for name: String) throws -> LayoutConfig {
        let url = getLayoutsFolder().appendingPathComponent(name, conformingTo: .propertyList)
        let decoder = PropertyListDecoder()
        let data = try Data(contentsOf: url)
        let layout = try decoder.decode(LayoutConfig.self, from: data)
        return layout
    }
    
    private func getControllerType(for name: String) -> ControllerType? {
        for controller in ControllerType.allCases {
            if name == controller.stringValue {
                return controller
            }
        }
        return nil
    }
    
    func setCurrentLayout(to name: String) throws {
        if let controller = getControllerType(for: name) {
            // load the default config from code rather than file
            self.currentController = DefaultLayouts.getLayout(for: controller)
        } else {
            self.currentController = try loadLayout(for: "\(name).plist")
        }
        // check if it has a d-pad
        if currentController.landscapeButtons.enumerated().filter({ $0.element.type == ButtonType.dpad }).count > 0 {
            self.hasDPad = true
        } else if currentController.portraitButtons.enumerated().filter({ $0.element.type == ButtonType.dpad }).count > 0 {
            self.hasDPad = true
        } else {
            self.hasDPad = false
        }
    }
}
