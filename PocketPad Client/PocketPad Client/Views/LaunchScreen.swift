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
                Image(systemName: "gamecontroller.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("PocketPad")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
