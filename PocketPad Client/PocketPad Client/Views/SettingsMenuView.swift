//
//  SettingsMenuView.swift
//  PocketPad
//
//  Created by Bautista Tedin on 2/21/25.
//
//  Edited by Benjamin Dravis on 4/19/25
//

import SwiftUI
import TipKit

// MARK: - Layout Constants
private let minMenuWidth: CGFloat = 320
private let minMenuHeight: CGFloat = 500
private let maxWidthFraction: CGFloat = 0.9
private let maxHeightFraction: CGFloat = 0.9

struct SettingsMenuView: View {
    // MARK: - Bound Properties
    @Binding var isShowingSettings: Bool
    @Binding var exitAllMenusCallback: (() -> Void)?
    @Binding var isCustomLayout: Bool
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @ObservedObject private var layoutManager = LayoutManager.shared
    
    @AppStorage("splitDPad") var splitDPad: Bool = false
    @AppStorage("selectedController") var selectedController: String = ControllerType.getDefaultName()
    @AppStorage("controllerColor") var controllerColor: Color = .blue

    @AppStorage("motionControlEnabled") var motionControlEnabled: Bool = false
    
    @AppStorage("connectionType") private var serverType: Int = 0

    @EnvironmentObject var motionManager: MotionManager
    
    // MARK: - Add Help & FAQs Properties
    @Environment(\.openURL) private var openURL  // Environment key to open URLs
    private let helpFAQURL = Bundle.main
        .object(forInfoDictionaryKey: "HelpFAQURL") as? String
        ?? "https://docs.google.com/document/d/1VsSVCmji7lz9CRxUKt2FdRm9Vd-MRM4ke3S1Zd5uDqQ/edit?usp=sharing"

    @State private var playerName: String = LayoutManager.shared.player_id_string
    @State private var showDPadStyle: Bool = false
    @State private var saveAsMalformed: Bool = false
    @State private var showDeletingAllDataAlert: Bool = false
    @State private var makingNewLayout: Bool = false
    @State private var newLayoutName: String = ""
    @State private var requestGameLayout: Bool = false
    
    @EnvironmentObject private var alertManager: AlertManager
    
    // deadzone view variables
    @State private var showingLeftDeadzoneView: Bool = false
    @State private var showingRightDeadzoneView: Bool = false
    @State private var leftJoystickDeadzone: Double = LayoutManager.shared.getLeftJoystickDeadzone()
    @State private var rightJoystickDeadzone: Double = LayoutManager.shared.getRightJoystickDeadzone()
    
    // turbo view variables
    @ObservedObject private var turboManager = TurboManager.shared
    @State private var showingTurboSettings: Bool = false
    
    // macro view variables
    @ObservedObject private var macroManager = MacroManager.shared
    @State private var showingMacroSettings: Bool = false
    
    @StateObject private var bluetoothManager = BluetoothManager.shared

    
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
                if !showingLeftDeadzoneView && !showingRightDeadzoneView && !showingTurboSettings && !showingMacroSettings {
                    VStack(spacing: 0) {
                        headerView
                        Divider()
                            .padding(.bottom, 6)
                        ScrollView {
                            settingsContent
                                .padding(.bottom, 20)
                        }
                        .accessibilityIdentifier("SettingsScrollView")
                        Spacer()
                    }
                    .frame(width: menuWidth, height: menuHeight)
                    .onAppear {
                        if let savedController = UserDefaults.standard.string(forKey: "selectedController") {
                            selectedController = savedController
                        }
                    }

                }
                
                if showingLeftDeadzoneView {
                    JoystickDeadzoneView(
                        isShowingDeadzoneView: $showingLeftDeadzoneView,
                        deadzoneValue: $leftJoystickDeadzone,
                        joystickName: .constant("Left Joystick")
                    )
                }
                
                if showingRightDeadzoneView {
                    JoystickDeadzoneView(
                        isShowingDeadzoneView: $showingRightDeadzoneView,
                        deadzoneValue: $rightJoystickDeadzone,
                        joystickName: .constant("Right Joystick")
                    )
                }
                
                if showingTurboSettings {
                    TurboSettingsView(isShowingTurboSettings: $showingTurboSettings)
                }
                
                if showingMacroSettings {
                    MacroSettingsView(isShowingMacroSettings: $showingMacroSettings)
                }
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
            Text("Settings")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 16)
            Spacer()
            Button {
                isShowingSettings = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.trailing, 16)
            }
            .accessibilityIdentifier("SettingsCloseButton")
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Main Settings Content
    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Section("Support") {
                Button {
                    guard let url = URL(string: helpFAQURL) else { return }
                        openURL(url)
                    } label: {
                        HStack {
                            Text("Help & FAQs")
                            Spacer()
                            Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityIdentifier("HelpFAQsButton")
                    .padding(.vertical, 8)
                }
            // Bluetooth VS Network
            HStack {
                Text("Connection Type")
                    .foregroundColor(.primary)
                Spacer()
                Picker("Connection Type", selection: $serverType) {
                    Text("Network").tag(0)
                    Text("Bluetooth").tag(1)
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("ConnectionTypePicker")
            }
            .disabled(BluetoothManager.shared.connectedDevice != nil || NetworkManager.shared.isConnected)
            // Controller Type Picker
            HStack {
                Text("Current Layout")
                    .foregroundColor(.primary)
                Spacer()
                Picker("Picker\(selectedController)", selection: $selectedController) {
                    ForEach(layoutManager.availableLayouts, id: \.self) { layout in
                        if UIImage(named: layout.lowercased()) != nil {
                            Label(layout, image: layout.lowercased()).tag(layout)
                        } else {
                            Label(layout, systemImage: "gamecontroller").tag(layout)
                        }
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("ControllerPicker")
                .onChange(of: selectedController, initial: false) {
                    // update the controller layout
                    do {
                        try LayoutManager.shared.setCurrentLayout(to: selectedController)
                        showDPadStyle = LayoutManager.shared.hasDPad
                        leftJoystickDeadzone = LayoutManager.shared.getLeftJoystickDeadzone()
                        rightJoystickDeadzone = LayoutManager.shared.getRightJoystickDeadzone()
                        turboManager.stopAllTurbo()
                        macroManager.clearMacrosForController()
                        
                        isCustomLayout = !DefaultLayouts.isDefaultLayout(name: selectedController)
                        if serverType == 1 {
                            bluetoothManager.updateControllerConfiguration()
                        } else {
                            NetworkManager.shared.sendLayout(true)
                        }
                    } catch {
                        UIApplication.shared.alert(title: "Failed to load layout", body: error.localizedDescription)
                        selectedController = ControllerType.getDefaultName()
                    }
                }
                .onAppear {
                    exitAllMenusCallback = exitAllMenus
                    showDPadStyle = LayoutManager.shared.hasDPad
                }
            }
            Button(action: {
                newLayoutName = ""
                makingNewLayout.toggle()
            }) {
                Text("Create New Layout")
            }
            .accessibilityIdentifier("CreateNewLayoutButton")
            .alert("New Layout", isPresented: $makingNewLayout) {
                TextField("Layout Name", text: $newLayoutName)
                    .accessibilityIdentifier("Name")
                
                Button("OK", action: {
                    if newLayoutName != "" {
                        do {
                            guard !layoutManager.layoutExists(for: newLayoutName) else { throw LayoutError.duplicate }
                            let newLayout: LayoutConfig = .init(name: newLayoutName, lockToOrientation: .all, buttons: [])
                            try layoutManager.saveLayout(newLayout)
                            try layoutManager.loadLayouts(includeControllerTypes: true)
                            try layoutManager.setCurrentLayout(to: newLayoutName)
                            selectedController = newLayoutName
                        } catch {
                            UIApplication.shared.alert(body: error.localizedDescription)
                        }
                    }
                })
                .accessibilityIdentifier("LayoutNameOK")
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("What will the name of the layout be?")
            }
            // MARK: Share Layout
            if isCustomLayout {
                ShareLink("Share Layout", item: layoutManager.getLayoutURL(name: selectedController))
            }
            //Picker for D-PAD (Split (True) vs Conjoined (False))
            if layoutManager.hasDPad {
                HStack {
                    Text("DPad Style")
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("D-PAD", selection: $splitDPad) {
                        Text("Conjoined").tag(false)
                        Text("Split").tag(true)
                    }
                    .pickerStyle(.menu)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityIdentifier("DPadStyle")
                }
            }
            
            Button(action: {
                requestGameLayout.toggle()
            }) {
                Text("Request Game Layout")
            }
            .padding(.horizontal, 16)
            .accessibilityIdentifier("RequestGameLayoutButton")
            .alert("Request Layout", isPresented: $requestGameLayout) {
                Button("OK", action: {
                    bluetoothManager.requestGameData()
                })
                .accessibilityIdentifier("requestLayoutOK")
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you would like to request the layout on file for your current game?")
            }
            
            // Controller Color Section
            HStack {
                Text("Controller Color")
                    .foregroundColor(.primary)
                
                Spacer()
                
                ColorPicker("", selection: $controllerColor, supportsOpacity: false)
                    .labelsHidden()
                    .padding(.trailing, 16)
                    .accessibilityIdentifier("ControllerColorPicker")

            }
            HStack {
                Text("Player Name")
                    .foregroundColor(.primary)
                Spacer()
                TextField("Enter Player Name", text: $playerName, onCommit: {
                    // Update the shared LayoutManager when editing is complete
                    LayoutManager.shared.player_id_string = playerName
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("NameField")
            }
            
            .alert(
                alertManager.alertTitle,
                isPresented: $alertManager.showAlert
            ) {
            } message: {
                Text(alertManager.alertMessage)
            }
            
            // MARK: - Joystick deadzone
            Section {
                // Left joystick
                HStack {
                    Text("Left Joystick Deadzone")
                    Spacer()
                    Button(action: {
                        showingLeftDeadzoneView = true
                    }) {
                        Text("\(Int(leftJoystickDeadzone * 100))%")
                            .foregroundColor(.blue)
                    }
                    .accessibilityIdentifier("LeftDeadzoneButton")
                }
                
                // Right joystick
                HStack {
                    Text("Right Joystick Deadzone")
                    Spacer()
                    Button(action: {
                        showingRightDeadzoneView = true
                    }) {
                        Text("\(Int(rightJoystickDeadzone * 100))%")
                            .foregroundColor(.blue)
                    }
                    .accessibilityIdentifier("RightDeadzoneButton")
                }
            } header: {
                Text("Joystick Settings")
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            // MARK: - Turbo Settings
            Section {
                HStack {
                    Text("Turbo Repeat Rate")
                    Spacer()
                    Button(action: {
                        showingTurboSettings = true
                    }) {
                        Text("\(Int(turboManager.turboRate)) presses/sec")
                            .foregroundColor(.blue)
                    }
                    .accessibilityIdentifier("TurboRateButton")
                }
            } header: {
                Text("Turbo Settings")
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            // MARK: - Macro Settings
            Section {
                HStack {
                    Text("Manage Macros")
                    Spacer()
                    Button(action: {
                        showingMacroSettings = true
                    }) {
                        Text("Edit")
                            .foregroundColor(.blue)
                    }
                    .accessibilityIdentifier("ViewMacrosButton")
                }
            } header: {
                Text("Macro Settings")
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            // MARK: Add toggle for motion control
            HStack {
                Text("Enable Motion Control")
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $motionControlEnabled)
                    .labelsHidden()
                    .accessibilityIdentifier("MotionControlToggle")
                    // Updated iOS 17 .onChange signature
                    .onChange(of: motionControlEnabled) {
                        if motionControlEnabled {
                            motionManager.startUpdates()
                        } else {
                            motionManager.stopUpdates()
                        }
                    }
            }
            
            // MARK: - Haptic Feedback Toggle
            HStack {
                Text("Enable Haptic Feedback")
                    .foregroundColor(.primary)
                Spacer()
                Toggle("", isOn: $hapticsEnabled)
                    .labelsHidden()
                    .accessibilityIdentifier("HapticFeedbackToggle")
            }
            
            // MARK: Resetting Tutorial
            Button(action: {
                UserDefaults.standard.set(false, forKey: "finishedTutorial")
                UserDefaults.standard.set(true, forKey: "resetTips")
            }) {
                Text("View Tutorial")
            }
            .accessibilityIdentifier("ViewTutorial")
            
            // MARK: Removing All Data
            Button(action: {
                showDeletingAllDataAlert.toggle()
            }) {
                Text("Delete App Data")
            }
            .foregroundStyle(.red)
            .accessibilityIdentifier("RemoveAllData")
            .alert("Delete App Data", isPresented: $showDeletingAllDataAlert, actions: {
                Button("Cancel", role: .cancel) {
                    showDeletingAllDataAlert = false
                }
                Button("Delete", role: .destructive) {
                    do {
                        try layoutManager.deleteAllLayouts()
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                        return
                    }
                    if let bundleID = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleID)
                    }
                    // set to clear tips
                    UserDefaults.standard.set(true, forKey: "resetTips")
                    // close the app
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
                .accessibilityIdentifier("ConfirmDelete")
            }, message: {
                Text("Are you sure you want to delete all app data? This cannot be undone.")
            })
            
            // MARK: Saving layouts (debug)
            #if DEBUG
            Section {
                // Toggle to save layout as malformed
                Toggle("Save as malformed file", isOn: $saveAsMalformed)
                    .accessibilityIdentifier("SaveAsMalformed")
                
                // Picker to choose a layout to save
                HStack {
                    Text("Save layout")
                    Spacer()
                    Button(action: {
                        showSaveLayoutPopup()
                    }) {
                        Text("Choose Template")
                    }
                    .accessibilityIdentifier("ChooseTemplate")
                }
                
                // Remove files for layout
                Button(action: {
                    do {
                        try LayoutManager.shared.setCurrentLayout(to: ControllerType.getDefaultName())
                        try LayoutManager.shared.deleteAllLayouts()
                        try LayoutManager.shared.loadLayouts(includeControllerTypes: true)
                        selectedController = ControllerType.getDefaultName()
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }) {
                    Text("Remove all file layouts")
                }
                .foregroundStyle(.red)
                .accessibilityIdentifier("RemoveLayoutFiles")
            } header: {
                Text("Layouts (testing)")
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            } footer: {
                Text("DEBUG BUILD")
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            #endif
        }
        .padding(.horizontal, 16)
    }
    
    func saveLayoutFile(for controller: ControllerType) {
        var layout = DefaultLayouts.getLayout(for: controller)
        layout.name = "\(controller.stringValue) Saved"
        do {
            if saveAsMalformed {
                try LayoutManager.shared.saveMalformedLayout(layout)
            } else {
                try LayoutManager.shared.saveLayout(layout)
            }
            try LayoutManager.shared.loadLayouts(includeControllerTypes: true)
            UIApplication.shared.alert(title: "Layout Successfully Saved", body: "It can be found in the \"Controller Type\" menu.")
        } catch {
            UIApplication.shared.alert(body: "Failed to save the layout:\n\(error.localizedDescription)")
        }
    }
    
    func showSaveLayoutPopup() {
        // TODO: refactor this later to an extension
        let alert = UIAlertController(title: "Choose a layout to save", message: "It will save it as a \(!saveAsMalformed ? "non-" : "")malformed file", preferredStyle: .actionSheet)
        
        // add the actions
        let xboxAction = UIAlertAction(title: "Xbox", style: .default) { (action) in
            saveLayoutFile(for: .Xbox)
        }
        xboxAction.accessibilityIdentifier = "Xbox Saved"
        alert.addAction(xboxAction)
        let wiiAction = UIAlertAction(title: "Wii", style: .default) { (action) in
            saveLayoutFile(for: .Wii)
        }
        wiiAction.accessibilityIdentifier = "Wii Saved"
        alert.addAction(wiiAction)
        let malformedAction = UIAlertAction(title: "Malformed", style: .default) { (action) in
            // make a malformed layout
            let badLayout = LayoutConfig.init(name: "Malformed", buttons: [
                BadButtonTypeConfig(position: .init(scaledPos: CGPointZero), scale: 0.0, rotation: 0.0, type: .joystick, inputId: 0)
            ])
            do {
                try LayoutManager.shared.saveLayout(badLayout)
                UIApplication.shared.alert(title: "Layout Successfully Saved", body: "It can be found in the \"Controller Type\" menu.")
            } catch {
                UIApplication.shared.alert(title: "Failed to save the layout", body: error.localizedDescription)
            }
        }
        malformedAction.accessibilityIdentifier = "MalformedLayout"
        alert.addAction(malformedAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            // cancels the action
        }
        alert.addAction(cancelAction)
        
        let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
        // present popover for iPads
        alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
        
        // present the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    func exitAllMenus() {
        showingLeftDeadzoneView = false
        showingRightDeadzoneView = false
        showingTurboSettings = false
        showingMacroSettings = false
    }
}

// MARK: - Preview
#Preview {
    SettingsMenuView(
        isShowingSettings: .constant(true),
        exitAllMenusCallback: .constant(nil),
        isCustomLayout: .constant(true)
    )
}

