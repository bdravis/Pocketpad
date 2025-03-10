//
//  TriggerButtonStyle.swift
//  PocketPad Client
//
//  Created by Krish Shah on 3/6/25.
//

import SwiftUI

struct TriggerShape: Shape {
    var side: TriggerSide
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        if side == .middle {
            path.move(to: CGPoint(x: width * 0.2, y: 0)) // Top left corner
            path.addQuadCurve(to: CGPoint(x: width * 0.8, y: 0), control: CGPoint(x: width / 2, y: height * 0.1)) // Curved top
            
            path.addQuadCurve(to: CGPoint(x: width * 0.90, y: height * 0.9), control: CGPoint(x: height * 0.8, y: height * 0.7)) // Right side, sloping down
            path.addQuadCurve(to: CGPoint(x: width * 0.10, y: height * 0.9), control: CGPoint(x: width / 2, y: height)) // Rounded bottom
            
            path.addQuadCurve(to: CGPoint(x: width * 0.2, y: 0), control: CGPoint(x: width * 0.2, y: height * 0.7)) // Rounded bottom
            
            path.closeSubpath()
        } else {
            path.move(to: CGPoint(x: width * abs(CGFloat(side.rawValue) - 0.2), y: 0)) // Top left corner
            path.addQuadCurve(to: CGPoint(x: width * abs(CGFloat(side.rawValue) - 0.8), y: 0), control: CGPoint(x: width / 2, y: height * 0.1)) // Curved top
            
            path.addLine(to: CGPoint(x: width * abs(CGFloat(side.rawValue) - 0.8), y: height * 0.9)) // Right side, sloping down
            path.addQuadCurve(to: CGPoint(x: width * abs(CGFloat(side.rawValue) - 0.05), y: height * 0.9), control: CGPoint(x: width / 2, y: height)) // Rounded bottom
            
            path.addQuadCurve(to: CGPoint(x: width * abs(CGFloat(side.rawValue) - 0.2), y: 0), control: CGPoint(x: width * abs(CGFloat(side.rawValue) - 0.2), y: height * 0.7)) // Rounded bottom
            
            path.closeSubpath()
        }

        return path
    }
}

struct TriggerButtonStyle: ButtonStyle {
    var side: TriggerSide
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
            .fontWeight(.regular)
            .font(.system(size: 10))
            .background(
                Color(uiColor: configuration.isPressed ? .secondaryLabel : .secondarySystemFill)
                    .scaledToFill()
            )
            .foregroundStyle(Color(uiColor: configuration.isPressed ? .systemBackground : .label))
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFit()
            .lineLimit(1)
            .contentShape(TriggerShape(side: side))
            .clipShape(TriggerShape(side: side))
            .overlay(
                TriggerShape(side: side)
                    .stroke(Color(uiColor: .label), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
        //            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    HStack {
        Button(action: {}) {
            Text("LT")
        }
        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
        .scaleEffect(1.5)
        .buttonStyle(TriggerButtonStyle(side: .left))
        .padding()
        Button(action: {}) {
            Text("MT")
        }
        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
        .scaleEffect(1.5)
        .buttonStyle(TriggerButtonStyle(side: .middle))
        .padding()
        Button(action: {}) {
            Text("RT")
        }
        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
        .scaleEffect(1.5)
        .buttonStyle(TriggerButtonStyle(side: .right))
        .padding()
    }
}

