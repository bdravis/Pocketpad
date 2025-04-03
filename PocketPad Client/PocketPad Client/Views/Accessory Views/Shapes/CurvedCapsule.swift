//
//  CurvedCapsule.swift
//  PocketPad Client
//
//  Created by lemin on 4/2/25.
//

import SwiftUI

struct CurvedCapsule: Shape {
    var xInset: CGFloat = 0.15
    var yInset: CGFloat = 0.2
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.width * xInset, y: rect.height * yInset))
        // top side
        path.addQuadCurve(
            to: CGPoint(x: rect.width * (1 - xInset), y: rect.height * yInset),
            control: CGPoint(x: rect.width / 2, y: 0)
        )
        // right side
        path.addQuadCurve(
            to: CGPoint(x: rect.width * (1 - xInset), y: rect.height * (1 - yInset)),
            control: CGPoint(x: rect.width, y: rect.height / 2)
        )
        // bottom side
        path.addQuadCurve(
            to: CGPoint(x: rect.width * xInset, y: rect.height * (1 - yInset)),
            control: CGPoint(x: rect.width / 2, y: rect.height * (1 - yInset*2))
        )
        // left side
        path.addQuadCurve(
            to: CGPoint(x: rect.width * xInset, y: rect.height * yInset),
            control: CGPoint(x: 0, y: rect.height / 2)
        )
        path.closeSubpath()
        return path
    }
    
    
}

#Preview {
    VStack {
        CurvedCapsule()
            .fill(Color.gray)
            .stroke(.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            .frame(width: 100, height: 50)
        Capsule()
            .fill(.blue)
            .frame(width: 100, height: 75)
    }
}
