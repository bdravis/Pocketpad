//
//  SFPickerView.swift
//  PocketPad Client
//
//  Created by lemin on 4/2/25.
//

import SwiftUI

struct SFPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var chosenSymbol: String
    
    let availableSymbols: [String] = [
        "macwindow", "macwindow.on.rectangle", "text.and.command.macwindow", "square.and.arrow.up", "square.and.arrow.up.fill",
        "arrowshape.left", "arrowshape.left.fill", "arrowshape.right", "arrowshape.right.fill", "arrowshape.up", "arrowshape.up.fill", "arrowshape.down", "arrowshape.down.fill"
    ]
    let columns = [
        GridItem(.adaptive(minimum: 90))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(availableSymbols, id: \.self) { symbol in
                    Button(action: {
                        chosenSymbol = symbol
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
                            if chosenSymbol == symbol {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .foregroundStyle(.blue.opacity(0.6))
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SFPickerView(chosenSymbol: .constant("macwindow"))
}
