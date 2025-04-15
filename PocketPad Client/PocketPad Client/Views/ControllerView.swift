//
//  ControllerView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

// MARK: Debug Button Configuration
let DEBUG_BUTTONS: [ButtonConfig] = [ // Example buttons
    // Diamond of buttons
    RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.8), offset: CGPoint(x: 0, y: -DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 0, input: .X),
    RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.8), offset: CGPoint(x: -DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 1, input: .Y),
    RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.8), offset: CGPoint(x: DEFAULT_BUTTON_SIZE, y: 0)), scale: 1.0, inputId: 2, input: .A),
    RegularButtonConfig(position: .init(scaledPos: CGPoint(x: 0.8, y: 0.8), offset: CGPoint(x: 0, y: DEFAULT_BUTTON_SIZE)), scale: 1.0, inputId: 3, input: .B),
//
//    RegularButtonConfig(position: CGPoint(x: 100, y: 300), scale: 1.0, inputId: 8, input: "Share", style: .init(shape: .Circle, iconType: .SFSymbol, icon: "square.and.arrow.up")), // SF Symbol style test
//    RegularButtonConfig(position: CGPoint(x: 260, y: 100), scale: 1.0, inputId: 6, input: "Start", style: .init(shape: .Pill, iconType: .Text, icon: "Start")), // Pill style test
//    RegularButtonConfig(position: CGPoint(x: 200, y: 100), scale: 1.0, inputId: 7, input: "Select", style: .init(shape: .Pill, iconType: .Text)), // No text test
//    
//    JoystickConfig(position: CGPoint(x: 100, y: 200), scale: 1.0, inputId: 4, input: "RightJoystick"),
//    DPadConfig(
//        position: CGPoint(x: 100, y: 0), scale: 1.0, inputId: 5,
//        inputs: [
//            .up: "DPadUp", .right: "DPadRight", .down: "DPadDown", .left: "DPadLeft"
//        ]
//    ),
//    
//    TriggerConfig(position: CGPoint(x: 300, y: 0), scale: 1.0, inputId: 10, input: "RT", side: .right)
]

// MARK: Main Controller View
struct ControllerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isPortait: Bool = false
    @State private var didLockRotation: Bool = false
    @ObservedObject private var layoutManager = LayoutManager.shared
    
    let isEditor: Bool
    
    // Editing Button View Values
    @State private var showAddPopup: Bool = false
    @State private var showSymbolPicker: Bool = false
    @ObservedObject private var selectedBtn: EditingButtonVM = .init()
    @State private var btnEditViewPos: CGFloat = 1.0
    @State private var editViewOpacity: Double = 1.0
    
    // Editing Button Gesture Values
    @State private var dragPos: CGPoint? = nil
    @State private var zoomStart: CGFloat? = nil
    @State private var rotateStart: Double? = nil
    
    // Keep the last safe values
    @State private var lastSafePos: CGPoint? = nil
    @State private var lastSafeScale: CGFloat? = nil
    @State private var isUnsafe: Bool = false
    
    // Alert Values
    @State private var showDeleteAlert: Bool = false
    @State private var deleting: Bool = false
    @State private var showRenameAlert: Bool = false
    @State private var newName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach($layoutManager.currentController.buttons, id: \.wrappedValue.id) { btn in
                    if selectedBtn.isEmpty || selectedBtn.inputId != btn.wrappedValue.inputId {
                        let tapGesture = TapGesture().onEnded {
                            applySelectedButton()
                            selectedBtn.setButton(to: btn.wrappedValue)
                            if (isPortait && selectedBtn.scaledPos.y > 0.5) || (!isPortait && selectedBtn.scaledPos.x > 0.5) {
                                btnEditViewPos = 0.0
                            } else {
                                btnEditViewPos = 1.0
                            }
                        }
                        ZStack {
                            Group {
                                switch btn.wrappedValue.type {
                                case .regular:
                                    RegularButtonView(config: btn.wrappedValue as! RegularButtonConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                case .joystick:
                                    JoystickButtonView(config: btn.wrappedValue as! JoystickConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                case .dpad:
                                    DPadButtonView(config: btn.wrappedValue as! DPadConfig)
                                case .bumper:
                                    BumperButtonView(config: btn.wrappedValue as! BumperConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                case .trigger:
                                    TriggerButtonView(config: btn.wrappedValue as! TriggerConfig)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityIdentifier("ControllerButton")
                                }
                            }
                        }
                        .rotationEffect(.degrees(btn.wrappedValue.rotation))
                        .scaleEffect(btn.wrappedValue.scale)
                        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                        .position(getPos(pos: btn.wrappedValue.position, geomSize: geometry.size))
                        .disabled(isEditor)
                        .gesture(tapGesture, isEnabled: isEditor)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("Button\(btn.inputId)")
                    }
                }
                
                // MARK: Editor Button
                if !selectedBtn.isEmpty {
                    ZStack {
                        Group {
                            switch selectedBtn.type {
                            case .regular:
                                RegularButtonView(config: selectedBtn.asButtonConfig() as! RegularButtonConfig)
                            case .joystick:
                                JoystickButtonView(config: selectedBtn.asButtonConfig() as! JoystickConfig)
                            case .dpad:
                                DPadButtonView(config: selectedBtn.asButtonConfig() as! DPadConfig)
                            case .bumper:
                                BumperButtonView(config: selectedBtn.asButtonConfig() as! BumperConfig)
                            case .trigger:
                                TriggerButtonView(config: selectedBtn.asButtonConfig() as! TriggerConfig)
                            }
                        }
                        .rotationEffect(.degrees(selectedBtn.rotation))
                        .scaleEffect(selectedBtn.scale)
                        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                        .position(getPos(pos: selectedBtn.getPos(), geomSize: geometry.size, dragPosition: self.dragPos, includeOffset: self.dragPos == nil))
                        .disabled(true)
                        .accessibilityAddTraits(.isButton)
                        ButtonInfoView(configVM: selectedBtn, isUnsafe: $isUnsafe)
                            .scaleEffect(selectedBtn.scale)
                            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                            .position(getPos(pos: selectedBtn.getPos(), geomSize: geometry.size, dragPosition: self.dragPos, includeOffset: self.dragPos == nil))
                    }
                    .onTapGesture {
                        applySelectedButton()
                        selectedBtn.clear()
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { drag in
                                if lastSafePos == nil {
                                    lastSafePos = getPos(pos: selectedBtn.getPos(), geomSize: geometry.size, includeOffset: false)
                                }
                                dragPos = drag.location
                                withAnimation {
                                    editViewOpacity = 0.3
                                }
                                if btnEditViewPos > 0.5 && ((isPortait && drag.location.y > geometry.size.height * 0.55) || (!isPortait && drag.location.x > geometry.size.width * 0.55)) {
                                    withAnimation {
                                        btnEditViewPos = 0.0
                                    }
                                } else if btnEditViewPos < 0.5 && ((isPortait && drag.location.y < geometry.size.height * 0.45) || (!isPortait && drag.location.x < geometry.size.width * 0.45)) {
                                    withAnimation {
                                        btnEditViewPos = 1.0
                                    }
                                }
                                if isSafe(geom: geometry.frame(in: .global)), let dragPos = dragPos {
                                    isUnsafe = false
                                    lastSafePos = dragPos
                                } else {
                                    isUnsafe = true
                                }
                            }
                            .onEnded { drag in
                                let pos = drag.location
                                if selectedBtn.overriding && ((selectedBtn.defaultIsPortrait && !isPortait) || (!selectedBtn.defaultIsPortrait && isPortait)) {
                                    selectedBtn.overrideScaledPos = CGPoint(
                                        x: (pos.x - selectedBtn.overrideOffset.x) / geometry.size.width,
                                        y: (pos.y - selectedBtn.overrideOffset.y) / geometry.size.height
                                    )
                                } else {
                                    selectedBtn.scaledPos = CGPoint(
                                        x: (pos.x - selectedBtn.offset.x) / geometry.size.width,
                                        y: (pos.y - selectedBtn.offset.y) / geometry.size.height
                                    )
                                }
                                dragPos = nil
                                if !isSafe(geom: geometry.frame(in: .global)), let lastSafePos = lastSafePos {
                                    // needs to set position back to the safe pos
                                    if selectedBtn.overriding && ((selectedBtn.defaultIsPortrait && !isPortait) || (!selectedBtn.defaultIsPortrait && isPortait)) {
                                        selectedBtn.overrideScaledPos = CGPoint(
                                            x: (lastSafePos.x - selectedBtn.overrideOffset.x) / geometry.size.width,
                                            y: (lastSafePos.y - selectedBtn.overrideOffset.y) / geometry.size.height
                                        )
                                    } else {
                                        selectedBtn.scaledPos = CGPoint(
                                            x: (lastSafePos.x - selectedBtn.offset.x) / geometry.size.width,
                                            y: (lastSafePos.y - selectedBtn.offset.y) / geometry.size.height
                                        )
                                    }
                                }
                                lastSafePos = nil
                                isUnsafe = false
                                withAnimation {
                                    editViewOpacity = 1.0
                                }
                            }
                    )
                    .simultaneousGesture(
                        MagnifyGesture(minimumScaleDelta: 0.0)
                            .onChanged { magnify in
                                if lastSafeScale == nil {
                                    lastSafeScale = selectedBtn.scale
                                }
                                if zoomStart == nil {
                                    zoomStart = selectedBtn.scale
                                }
                                if let zoomStart = zoomStart {
                                    let zoomAmt = zoomStart + (magnify.magnification - 1)
                                    if zoomAmt < 0.25 {
                                        selectedBtn.scale = 0.25
                                    } else if zoomAmt > 4.0 {
                                        selectedBtn.scale = 4.0
                                    } else {
                                        selectedBtn.scale = zoomStart + (magnify.magnification - 1)
                                    }
                                }
                                // check if safe
                                if isSafe(geom: geometry.frame(in: .global)) {
                                    isUnsafe = false
                                    lastSafeScale = selectedBtn.scale
                                } else {
                                    isUnsafe = true
                                }
                            }
                            .onEnded { _ in
                                zoomStart = nil
                                if !isSafe(geom: geometry.frame(in: .global)), let lastSafeScale = lastSafeScale {
                                    selectedBtn.scale = lastSafeScale
                                }
                                lastSafeScale = nil
                                isUnsafe = false
                            }
                    )
                    .simultaneousGesture(
                        RotateGesture(minimumAngleDelta: .degrees(0.0))
                            .onChanged { value in
                                if rotateStart == nil {
                                    rotateStart = selectedBtn.rotation
                                }
                                if let rotateStart = rotateStart {
                                    let rotAmt = rotateStart + value.rotation.degrees
                                    selectedBtn.rotation = rotAmt
                                }
                            }
                            .onEnded { _ in
                                rotateStart = nil
                            }
                    )
                    .overlay {
                        Rectangle()
                            .strokeBorder(Color.gray, lineWidth: 2)
                            .background(Color.gray.opacity(0.4), in: Rectangle())
                            .frame(width: 8, height: 8)
                            .position(getOverlayPos(pos: selectedBtn.getPos(), geomSize: geometry.size))
                    }
                }
            }
            .onChange(of: geometry.size, initial: true) {
                isPortait = geometry.size.height > geometry.size.width
                // MARK: Lock Orientation
                lockRotation()
            }
            .onDisappear {
                // MARK: Unlock Orientation
                unlockRotation()
                guard !deleting else { return }
                // save controller
                if isEditor {
                    // apply the selected button first
                    applySelectedButton()
                    do {
                        try LayoutManager.shared.saveCurrentLayout()
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }
            }
            .toolbar {
                if isEditor {
                    ToolbarItem(placement: .topBarLeading, content: {
                        HStack {
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark")
                            }
                            .accessibilityIdentifier("ExitControllerView")
                            Button(action: {
                                showDeleteAlert.toggle()
                            }) {
                                Image(systemName: "trash")
                            }
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("DeleteLayoutBtn")
                            Button(action: {
                                newName = ""
                                showRenameAlert.toggle()
                            }) {
                                Image(systemName: "pencil")
                            }
                            .accessibilityIdentifier("RenameLayoutBtn")
                            Toggle("Rotation Lock", systemImage: "lock\(didLockRotation ? ".open" : "").rotation", isOn: $didLockRotation)
                                .buttonStyle(.borderless)
                                .toggleStyle(.button)
                                .onChange(of: didLockRotation, initial: false) {
                                    layoutManager.currentController.rotationLocked = didLockRotation
                                    if didLockRotation {
                                        lockRotation()
                                    } else {
                                        unlockRotation()
                                    }
                                }
                        }
                    })
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button(action: {
                            if !selectedBtn.isEmpty {
                                // apply the button to not reset the config
                                applySelectedButton()
                            }
                            showAddPopup.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                        .accessibilityIdentifier("NewButtonBtn")
                    })
                } else {
                    ToolbarItem(placement: .topBarLeading, content: {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                        .accessibilityIdentifier("ExitControllerView")
                    })
                }
            }
            .sheet(isPresented: $showSymbolPicker, content: {
                SFPickerView(button: selectedBtn)
            })
            .sheet(isPresented: $showAddPopup) {
                AddButtonView(selectedBtn: selectedBtn)
            }
            .background {
                if isEditor {
                    Color(uiColor: .systemBackground)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if !selectedBtn.isEmpty {
                                applySelectedButton()
                                selectedBtn.clear()
                            }
                        }
                }
            }
            .overlay {
                if !selectedBtn.isEmpty {
                    EditButtonView(button: selectedBtn, showSymbolPicker: $showSymbolPicker, isPortait: $isPortait)
                        .frame(
                            width: !isPortait ? geometry.size.width * 0.4 : geometry.size.width,
                            height: isPortait ? geometry.size.height * 0.4 : geometry.size.height
                        )
                        .position(
                            x: !self.isPortait ? (btnEditViewPos * geometry.size.width) - (geometry.size.width * 0.2 * (btnEditViewPos * 2 - 1)) : 0.5 * geometry.size.width,
                            y: self.isPortait ? (btnEditViewPos * geometry.size.height) - (geometry.size.height * 0.2 * (btnEditViewPos * 2 - 1)) : (geometry.size.height * 0.5)
                        )
                        .opacity(editViewOpacity)
                }
            }
            .overlay {
                if !isEditor {
                    // controller glow
                    GlowEffect(color: UserDefaults.standard.value(forKey: "controllerColor") as? Color ?? Color.blue)
                }
            }
            .alert("Delete Layout", isPresented: $showDeleteAlert, actions: {
                Button("Cancel") {
                    showDeleteAlert = false
                }
                Button("Delete") {
                    do {
                        try layoutManager.deleteLayout(layoutManager.currentController.name)
                        showDeleteAlert = false
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                    deleting = true
                    presentationMode.wrappedValue.dismiss()
                }
                .accessibilityIdentifier("ConfirmDelete")
            }, message: {
                Text("Are you sure you want to delete this layout? This cannot be undone.")
            })
            .alert("Rename Layout", isPresented: $showRenameAlert, actions: {
                TextField("Layout Name", text: $newName)
                    .accessibilityIdentifier("LayoutNameField")
                Button("Cancel") {
                    showRenameAlert = false
                }
                Button("Done") {
                    do {
                        if newName == "" {
                            return
                        }
                        try layoutManager.renameLayout(from: layoutManager.currentController.name, to: newName)
                        showRenameAlert = false
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }
                .accessibilityIdentifier("LayoutNameOK")
            }, message: {
                Text("Choose a new name for the current layout.")
            })
        }
        .navigationTitle("Controller")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MainControllerScreen")
        .navigationBarBackButtonHidden()
    }
    
    func isSafe(geom: CGRect) -> Bool {
        guard !selectedBtn.isEmpty else { return true }
        let selBtnRect = CGRect(
            x: dragPos?.x ?? (selectedBtn.scaledPos.x * geom.size.width) + selectedBtn.offset.x,
            y: dragPos?.y ?? (selectedBtn.scaledPos.y * geom.size.height) + selectedBtn.offset.y,
            width: selectedBtn.scale * DEFAULT_BUTTON_SIZE,
            height: selectedBtn.scale * DEFAULT_BUTTON_SIZE
        )
        if !geom.contains(selBtnRect) { return false }
        for btn in layoutManager.currentController.buttons {
            if btn.inputId == selectedBtn.inputId { continue }
            let currBtnRect = CGRect(
                x: (btn.position.scaledPos.x * geom.size.width) + btn.position.offset.x,
                y: (btn.position.scaledPos.y * geom.size.height) + btn.position.offset.y,
                width: btn.scale * DEFAULT_BUTTON_SIZE,
                height: btn.scale * DEFAULT_BUTTON_SIZE
            )
            if selBtnRect.intersects(currBtnRect) {
                return false
            }
        }
        return true
    }
    
    func getPos(pos: ButtonPosition, geomSize: CGSize, dragPosition: CGPoint? = nil, includeOffset: Bool = true) -> CGPoint {
        if (isPortait && pos.defaultIsPortrait == false) || (!isPortait && pos.defaultIsPortrait == true) {
            return CGPoint(
                x: (dragPosition?.x ?? (pos.overrideScaledPos?.x ?? pos.scaledPos.x) * geomSize.width) + (includeOffset ? (pos.overrideOffset?.x ?? pos.offset.x) : 0.0),
                y: (dragPosition?.y ?? (pos.overrideScaledPos?.y ?? pos.scaledPos.y) * geomSize.height) + (includeOffset ? (pos.overrideOffset?.y ?? pos.offset.y) : 0.0)
            )
        }
        return CGPoint(
            x: (dragPosition?.x ?? pos.scaledPos.x * geomSize.width) + (includeOffset ? pos.offset.x : 0.0),
            y: (dragPosition?.y ?? pos.scaledPos.y * geomSize.height) + (includeOffset ? pos.offset.y : 0.0)
        )
    }
    func getOverlayPos(pos: ButtonPosition, geomSize: CGSize) -> CGPoint {
        if (isPortait && pos.defaultIsPortrait == false) || (!isPortait && pos.defaultIsPortrait == true) {
            return CGPoint(
                x: self.dragPos != nil ? self.dragPos!.x - pos.overrideOffset!.x : pos.overrideScaledPos!.x * geomSize.width,
                y: self.dragPos != nil ? self.dragPos!.y - pos.overrideOffset!.y : pos.overrideScaledPos!.y * geomSize.height
            )
        }
        return CGPoint(
            x: self.dragPos != nil ? self.dragPos!.x - pos.offset.x : pos.scaledPos.x * geomSize.width,
            y: self.dragPos != nil ? self.dragPos!.y - pos.offset.y : pos.scaledPos.y * geomSize.height
        )
    }
    
    func applySelectedButton() {
        guard !selectedBtn.isEmpty else { return }
        for i in 0..<layoutManager.currentController.buttons.count {
            if layoutManager.currentController.buttons[i].inputId == selectedBtn.inputId {
                selectedBtn.applyToButton(&layoutManager.currentController.buttons[i])
                break
            }
        }
        selectedBtn.clear()
    }
    
    func lockRotation() {
        var newOrientation = layoutManager.currentController.lockToOrientation
        if layoutManager.currentController.rotationLocked {
            // force current orientation
            let rot = newOrientation
            if isPortait && UIDevice.current.orientation == .portrait && (rot == .all || rot == .allButUpsideDown) {
                newOrientation = .portrait
            } else if isPortait && UIDevice.current.orientation == .portraitUpsideDown && (rot == .all) {
                newOrientation = .portraitUpsideDown
            } else if !isPortait && UIDevice.current.orientation == .landscapeLeft && (rot == .all || rot == .landscape || rot == .allButUpsideDown) {
                newOrientation = .landscapeRight
            } else if !isPortait && UIDevice.current.orientation == .landscapeRight && (rot == .all || rot == .landscape || rot == .allButUpsideDown) {
                newOrientation = .landscapeLeft
            } else if isPortait && (rot == .landscapeLeft || rot == .landscape) {
                newOrientation = .landscapeLeft
            } else if isPortait && rot == .landscapeRight {
                newOrientation = .landscapeRight
            }
            didLockRotation = true
        }
        AppDelegate.orientationLock = newOrientation
    }
    func unlockRotation() {
        AppDelegate.orientationLock = .all
    }
}
//
//#Preview {
//    ControllerView(layout: .init(name: "Debug", buttons: DEBUG_BUTTONS), isEditor: false)
//}
