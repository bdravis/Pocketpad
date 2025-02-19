//
//  ContentView.swift
//  PocketPad Client
//
//  Created by lemin on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: ControllerView(buttons: DEBUG_BUTTONS)) {
                    Text("Open Debug ControllerView")
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
