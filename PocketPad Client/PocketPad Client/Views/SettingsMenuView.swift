//
//  SettingsMenuView.swift
//  PocketPad
//
//  Created by Bautista Tedin on 2/21/25.
//

import SwiftUI

// MARK: - Layout Constants
private let minMenuWidth: CGFloat = 320
private let minMenuHeight: CGFloat = 500
private let maxWidthFraction: CGFloat = 0.9
private let maxHeightFraction: CGFloat = 0.9

struct SettingsMenuView: View {
    // MARK: - Bound Properties
    @Binding var isShowingSettings: Bool
    
    @AppStorage("splitDPad") var splitDPad: Bool = false
    @AppStorage("selectedController") var selectedController: String = ControllerType.Xbox.stringValue
    @AppStorage("controllerColor") var controllerColor: Color = .blue
    @AppStorage("controllerName") var controllerName: String = "Controller"
    
    @State private var showDPadStyle: Bool = false
    @State private var saveAsMalformed: Bool = false
    @State private var availableControllers: [String] = [] // TODO: Change this to a VM later
    
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
                VStack(spacing: 0) {
                    headerView
                    Divider()
                        .padding(.bottom, 6)
                    ScrollView {
                        settingsContent
                            .padding(.bottom, 20)
                    }
                    Spacer()
                }
                .frame(width: menuWidth, height: menuHeight)
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
            // Controller Type Picker
            HStack {
                Text("Controller Type")
                    .foregroundColor(.primary)
                Spacer()
                Picker("Controller Type", selection: $selectedController) {
//                    ForEach(ControllerType.allCases, id: \.self) { type in
//                        Label(type.stringValue, image: type.stringValue).tag(type.stringValue)
//                    }
                    ForEach(availableControllers, id: \.self) { layout in
                        Label(layout, image: layout.lowercased()).tag(layout)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("ControllerPicker")
                .onChange(of: selectedController, initial: false) {
                    // update the controller layout
                    do {
                        try LayoutManager.shared.setCurrentLayout(to: selectedController)
                        showDPadStyle = LayoutManager.shared.hasDPad
                    } catch {
                        UIApplication.shared.alert(title: "Failed to load layout", body: error.localizedDescription)
                        selectedController = ControllerType.Xbox.stringValue
                    }
                }
                .onAppear {
                    showDPadStyle = LayoutManager.shared.hasDPad
                    availableControllers = LayoutManager.shared.availableLayouts
                }
            }
            .padding(.horizontal, 16)
            //Picker for D-PAD (Split (True) vs Conjoined (False))
            if showDPadStyle {
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
                .padding(.horizontal, 16)
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
            .padding(.horizontal, 16)
            HStack {
                Text("Controller Name")
                    .foregroundColor(.primary)
                Spacer()
                TextField("Enter controller name", text: $controllerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("NameField")
            }
            .padding(.horizontal, 16)
            
            // MARK: Saving layouts (temporary)
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
                        try LayoutManager.shared.setCurrentLayout(to: ControllerType.Xbox.stringValue)
                        try LayoutManager.shared.deleteAllLayouts()
                        try LayoutManager.shared.loadLayouts(includeControllerTypes: true)
                        selectedController = ControllerType.Xbox.stringValue
                        availableControllers = LayoutManager.shared.availableLayouts
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
            }
            .padding(.horizontal, 16)
        }
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
            availableControllers = LayoutManager.shared.availableLayouts
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
            let badLayout = LayoutConfig.init(name: "Malformed", landscapeButtons: [
                BadButtonTypeConfig(position: CGPointZero, scale: 0, type: .joystick, inputId: 0)
            ], portraitButtons: [
                
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
}

// MARK: - Preview
#Preview {
    SettingsMenuView(
        isShowingSettings: .constant(true)
    )
}

