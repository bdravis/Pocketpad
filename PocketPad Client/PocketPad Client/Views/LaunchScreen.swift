//
//  LaunchScreen.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .padding(15)
                    .frame(width: 130, height: 130)
                    .background(.blue, in: Circle())
                
                Text("PocketPad")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    LaunchScreen()
}
