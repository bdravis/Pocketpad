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
    // TODO: Make a View Model with the buttons
    @State private var orientation = UIDeviceOrientation.unknown
    @ObservedObject private var layoutManager = LayoutManager.shared
    
    let isEditor: Bool
    
    @State private var showAddPopup: Bool = false
    @State private var selectedBtn: UInt8? = nil
    @State private var btnEditViewPos: CGFloat = 1.0
    
    @State private var showDeleteAlert: Bool = false
    @State private var showRenameAlert: Bool = false
    @State private var newName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach($layoutManager.currentController.buttons, id: \.wrappedValue.id) { btn in
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
                        .scaleEffect(btn.wrappedValue.scale)
                        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                        .position(
                            x: btn.wrappedValue.position.scaledPos.x * geometry.size.width,
                            y: btn.wrappedValue.position.scaledPos.y * geometry.size.height
                        )
                        .offset(
                            x: btn.wrappedValue.position.offset.x,
                            y: btn.wrappedValue.position.offset.y
                        )
                        .rotationEffect(.degrees(btn.wrappedValue.rotation))
                        .disabled(isEditor)
                        if isEditor && selectedBtn == btn.wrappedValue.inputId {
                            ButtonInfoView(config: btn.wrappedValue)
                                .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
                                .scaleEffect(btn.scale.wrappedValue)
                                .position(
                                    x: btn.wrappedValue.position.scaledPos.x * geometry.size.width,
                                    y: btn.wrappedValue.position.scaledPos.y * geometry.size.height
                                )
                                .offset(
                                    x: btn.wrappedValue.position.offset.x,
                                    y: btn.wrappedValue.position.offset.y
                                )
                        }
                    }
                    .onTapGesture {
                        if selectedBtn == btn.wrappedValue.inputId {
                            selectedBtn = nil
                        } else {
                            selectedBtn = btn.wrappedValue.inputId
                        }
                    }
                    .overlay {
                        if selectedBtn == btn.inputId.wrappedValue {
                            EditButtonView(button: btn)
                                .frame(maxHeight: geometry.size.height * 0.3)
                                .position(x: 0.5 * geometry.size.width, y: (btnEditViewPos * geometry.size.height) - (geometry.size.height * 0.15))
                        }
                    }
                }
            }
            .onRotate { newOrientation in
                orientation = newOrientation
            }
            .onAppear {
                orientation = UIDevice.current.orientation
            }
            .onDisappear {
                // save controller
                if isEditor {
                    do {
                        try LayoutManager.shared.saveCurrentLayout()
                    } catch {
                        print(error.localizedDescription)
                        // TODO: Add error message
                    }
                }
            }
            .toolbar {
                if isEditor {
                    ToolbarItem(placement: .topBarLeading, content: {
                        HStack {
                            Button(action: {
                                showDeleteAlert.toggle()
                            }) {
                                Image(systemName: "trash")
                            }
                            .foregroundStyle(.red)
                            Button(action: {
                                newName = ""
                                showRenameAlert.toggle()
                            }) {
                                Image(systemName: "pencil")
                            }
                        }
                    })
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button(action: {
                            showAddPopup.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                    })
                }
            }
            .sheet(isPresented: $showAddPopup) {
                AddButtonView()
            }
            .alert("Delete Layout", isPresented: $showDeleteAlert, actions: {
                Button("Cancel") {
                    showDeleteAlert = false
                }
                Button("Delete") {
                    do {
                        try layoutManager.deleteLayout(layoutManager.currentController.name)
                        showDeleteAlert = false
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        // TODO: Add error message
                        print(error.localizedDescription)
                    }
                }
            }, message: {
                Text("Are you sure you want to delete this layout? This cannot be undone.")
            })
            .alert("Rename Layout", isPresented: $showRenameAlert, actions: {
                TextField("Layout Name", text: $newName)
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
                        // TODO: Add error message
                        print(error.localizedDescription)
                    }
                }
            }, message: {
                Text("Choose a new name for the current layout.")
            })
        }
        .navigationTitle("Controller")
        .navigationBarTitleDisplayMode(.inline)
    }
}
//
//#Preview {
//    ControllerView(layout: .init(name: "Debug", buttons: DEBUG_BUTTONS), isEditor: false)
//}
