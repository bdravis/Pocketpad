//
//  SFPickerView.swift
//  PocketPad Client
//
//  Created by lemin on 4/2/25.
//

import SwiftUI

struct DisplaySymbol: Identifiable {
    let id: UUID
    let title: String
    let systemName: String
    
    init(_ systemName: String, title: String? = nil) {
        self.id = UUID()
        self.title = title ?? systemName
        self.systemName = systemName
    }
}

let AvailableSymbols: [DisplaySymbol] = [
    .init("plus", title: "Plus"),
    .init("minus", title: "Minus"),
    
    .init("macwindow", title: "Window"),
    .init("macwindow.on.rectangle", title: "Windows"),
    .init("text.and.command.macwindow", title: "Terminal Window"),
    .init("line.3.horizontal", title: "Horizontal Lines"),
    
    .init("square.and.arrow.up", title: "Share"),
    .init("square.and.arrow.up.fill", title: "Share (Filled)"),
    
    .init("arrowshape.left", title: "Left Arrow"),
    .init("arrowshape.left.fill", title: "Left Arrow (Filled)"),
    .init("arrowshape.right", title: "Right Arrow"),
    .init("arrowshape.right.fill", title: "Right Arrow (Filled)"),
    .init("arrowshape.up", title: "Up Arrow"),
    .init("arrowshape.up.fill", title: "Up Arrow (Filled)"),
    .init("arrowshape.down", title: "Down Arrow"),
    .init("arrowshape.down.fill", title: "Down Arrow (Filled)")
]
