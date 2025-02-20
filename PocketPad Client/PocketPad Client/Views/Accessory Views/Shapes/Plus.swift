//
//  Plus.swift
//  PocketPad Client
//
//  Created by lemin on 2/18/25.
//

import SwiftUI

struct Plus: Shape {
    var thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let offset = thickness / 2
        
        path.move(to: CGPoint(x: rect.midX - offset, y: rect.midY - offset)) // start at top left of the up direction
        
        // Top
        path.addLine(to: CGPoint(x: rect.midX - offset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + offset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + offset, y: rect.midY - offset))
        
        // Right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - offset))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + offset))
        path.addLine(to: CGPoint(x: rect.midX + offset, y: rect.midY + offset))
        
        // Bottom
        path.addLine(to: CGPoint(x: rect.midX + offset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - offset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - offset, y: rect.midY + offset))
        
        // Left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + offset))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY - offset))
        path.addLine(to: CGPoint(x: rect.midX - offset, y: rect.midY - offset))
        
        return path
    }
}
