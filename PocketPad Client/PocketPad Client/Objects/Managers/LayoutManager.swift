//
//  LayoutManager.swift
//  PocketPad Client
//
//  Created by lemin on 3/4/25.
//

import SwiftUI

class LayoutManager: ObservableObject {
    static let shared = LayoutManager() // create a data singleton
    
    var player_id: UInt8 = 0
    
    // If this is "Player", then a number will be added at the end to avoid duplicates
    // This is to avoid duplicates whenever no custom name is chosen
    var player_id_string: String = "Player"
    
    // This is used when requesting a new string to get around scope stuff
    var requested_player_id_string: String = "Player"
    
    @Published var availableLayouts: [String] = []
    
    // Current Layout Information
    @Published var currentController: LayoutConfig = .init(name: "DEBUG", buttons: [])
    @Published var hasDPad: Bool = false
    
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
        // update the current layout if needed
        if currentController.name == layout.name {
            currentController = layout
            if currentController.buttons.enumerated().filter({ $0.element.type == ButtonType.dpad }).count > 0 {
                self.hasDPad = true
            } else {
                self.hasDPad = false
            }
        }
    }
    
    func saveCurrentLayout() throws {
        try saveLayout(self.currentController)
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
    
    func deleteLayout(_ name: String) throws {
        // delete the layout from both folder and file contents
        if let idx = availableLayouts.firstIndex(where: { $0 == name }) {
            availableLayouts.remove(at: idx)
            let url = getLayoutsFolder()
            try FileManager.default.removeItem(at: url.appendingPathComponent("\(name).plist", conformingTo: .propertyList))
            if currentController.name == name {
                currentController = try self.loadLayout(for: self.availableLayouts.first!)
                UserDefaults.standard.set(currentController, forKey: "selectedController")
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
    
    func layoutExists(for name: String) -> Bool {
        return availableLayouts.filter({ $0 == name }).count > 0
    }
    
    func renameLayout(from initial: String, to newName: String) throws {
        if self.layoutExists(for: newName) {
            throw LayoutError.duplicate
        }
        // TODO: Handle if it is not the current controller
        self.currentController.name = newName
        try self.saveLayout(self.currentController)
        UserDefaults.standard.set(newName, forKey: "selectedController")
        let url = getLayoutsFolder().appendingPathComponent("\(initial).plist", conformingTo: .propertyList)
        do {
            try FileManager.default.removeItem(at: url)
            print("removed \(initial)")
        } catch {
            print("failed to remove \(initial): \(error.localizedDescription)")
        }
        try self.loadLayouts(includeControllerTypes: true)
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
        if currentController.buttons.enumerated().filter({ $0.element.type == ButtonType.dpad }).count > 0 {
            self.hasDPad = true
        } else {
            self.hasDPad = false
        }
    }
    
    // Helper functions for accessing and updating left and right joystick deadzone values
    func getLeftJoystickDeadzone() -> Double {
        return (currentController.buttons.first(where: {
            ($0 as? JoystickConfig)?.input == .LeftJoystick
        }) as? JoystickConfig)?.deadzone ?? 0.0
    }
    
    func getRightJoystickDeadzone() -> Double {
        return (currentController.buttons.first(where: {
            ($0 as? JoystickConfig)?.input == .RightJoystick
        }) as? JoystickConfig)?.deadzone ?? 0.0
    }
    
    func updateLeftJoystickDeadzone(_ newDeadzone: Double) {
        for i in 0..<currentController.buttons.count {
            // find joystick
            if var joystickButton = currentController.buttons[i] as? JoystickConfig {
                if (joystickButton.input == .LeftJoystick) {
                    // update deadzone
                    joystickButton.deadzone = newDeadzone
                    currentController.buttons[i] = joystickButton
                }
            }
        }
    }
    
    func updateRightJoystickDeadzone(_ newDeadzone: Double) {
        for i in 0..<currentController.buttons.count {
            // find joystick
            if var joystickButton = currentController.buttons[i] as? JoystickConfig {
                if (joystickButton.input == .RightJoystick) {
                    // update deadzone
                    joystickButton.deadzone = newDeadzone
                    currentController.buttons[i] = joystickButton
                }
            }
        }
    }

    func deleteButton(inputId: UInt8) {
        // delete the button with the corresponding input id and fix all the input ids to be in chronological order
        currentController.buttons.removeAll { $0.inputId == inputId }
        // fix ids
        var currentId: UInt8 = 0
        currentController.buttons.enumerated().forEach { idx, _ in
            currentController.buttons[idx].inputId = currentId
            currentId += 1
        }
    }
}
