//
//  SFPickerView.swift
//  PocketPad Client
//
//  Created by lemin on 4/2/25.
//

import SwiftUI

struct SFPickerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var button: EditingButtonVM
    
    let availableSymbols: [String] = [
        "plus", "macwindow", "macwindow.on.rectangle", "text.and.command.macwindow", "square.and.arrow.up", "square.and.arrow.up.fill",
        "arrowshape.left", "arrowshape.left.fill", "arrowshape.right", "arrowshape.right.fill", "arrowshape.up", "arrowshape.up.fill", "arrowshape.down", "arrowshape.down.fill"
    ]
    let columns = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
            .padding(5)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(availableSymbols, id: \.self) { symbol in
                        Button(action: {
                            button.icon = symbol
                            dismiss()
                        }) {
                            VStack {
                                Image(systemName: symbol)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text(symbol)
                                Spacer()
                            }
                            .padding(.horizontal, 5)
                            .background {
                                if button.icon == symbol {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .foregroundStyle(.blue.opacity(0.6))
                                }
                            }
                        }
                        .accessibilityIdentifier(symbol)
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
