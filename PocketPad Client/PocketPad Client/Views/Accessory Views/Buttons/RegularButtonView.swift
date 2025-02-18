//
//  RegularButtonView.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct RegularButtonView: View {
    var config: RegularButtonConfig
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.green)
            Text("Reg Btn")
        }
    }
}
