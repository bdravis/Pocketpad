//
//  GlowEffect.swift
//  PocketPad Client
//
//  Created by lemin on 4/1/25.
//

import SwiftUI

struct GlowEffect: View {
    var color: Color
    var width: CGFloat = 8
    var blur: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 60)
                .strokeBorder(color, lineWidth: width)
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height
                )
                .blur(radius: blur)
        }
        .ignoresSafeArea()
    }
}
