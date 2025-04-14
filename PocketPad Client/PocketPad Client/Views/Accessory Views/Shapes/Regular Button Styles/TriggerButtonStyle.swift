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
        } else if side == .left {
            path.move(to: CGPoint(x: width * 0.2, y: 0)) // Top left corner
            path.addQuadCurve(to: CGPoint(x: width * 0.8, y: 0), control: CGPoint(x: width / 2, y: height * 0.1)) // Curved top

            path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.9)) // Right side, sloping down
            path.addQuadCurve(to: CGPoint(x: width * 0.05, y: height * 0.9), control: CGPoint(x: width / 2, y: height)) // Rounded bottom

            path.addQuadCurve(to: CGPoint(x: width * 0.2, y: 0), control: CGPoint(x: width * 0.2, y: height * 0.7)) // Rounded bottom
        } else {
            path.move(to: CGPoint(x: width * 0.8, y: 0)) // Top left corner
            path.addQuadCurve(to: CGPoint(x: width * 0.2, y: 0), control: CGPoint(x: width / 2, y: height * 0.1)) // Curved top

            path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.9)) // Right side, sloping down
            path.addQuadCurve(to: CGPoint(x: width * 0.95, y: height * 0.9), control: CGPoint(x: width / 2, y: height)) // Rounded bottom

            path.addQuadCurve(to: CGPoint(x: width * 0.8, y: 0), control: CGPoint(x: width * 0.8, y: height * 0.7)) // Rounded bottom
        }

        path.closeSubpath()

        return path
    }
}

struct TriggerButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var side: TriggerSide
    var style: GeneralButtonStyle
    var isTurboEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
            .fontWeight(.regular)
            .font(.system(size: 10))
            .background(
                (configuration.isPressed ? getBGPressedColor() : getBGColor())
                    .scaledToFill()
            )
            .foregroundStyle(configuration.isPressed ? getFGPressedColor() : getFGColor())
            .font(.system(size: 200)) // scale the text to the size of the button
            .minimumScaleFactor(0.01)
            .scaledToFit()
            .lineLimit(1)
            .contentShape(TriggerShape(side: side))
            .clipShape(TriggerShape(side: side))
            .overlay(
                TriggerShape(side: side)
                    .stroke(
                        isTurboEnabled ? Color.yellow : getStrokeColor(),
                        style: StrokeStyle(lineWidth: style.borderThickness, lineJoin: .round)
                    )
                    .opacity(configuration.isPressed ? 0.0 : 1.0)
            )
    }
    
    /* Color Getter Functions */
    func getBGColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.color
            : style.lightModeColors.color
        ) ?? DefaultColors.trigger.color
    }
    func getBGPressedColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.pressedColor
            : style.lightModeColors.pressedColor
        ) ?? DefaultColors.trigger.pressedColor
    }
    func getFGColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.foregroundColor
            : style.lightModeColors.foregroundColor
        ) ?? DefaultColors.trigger.foregroundColor
    }
    func getFGPressedColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.foregroundPressedColor
            : style.lightModeColors.foregroundPressedColor
        ) ?? DefaultColors.trigger.foregroundPressedColor
    }
    func getStrokeColor() -> Color {
        return (
            colorScheme == .dark ? style.darkModeColors.strokeColor
            : style.lightModeColors.strokeColor
        ) ?? DefaultColors.trigger.strokeColor
    }
}

#Preview {
    HStack {
        Button(action: {}) {
            Text("LT")
        }
        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
        .scaleEffect(1.5)
        .buttonStyle(TriggerButtonStyle(side: .left, style: .init(), isTurboEnabled: false))
        .padding()
        Button(action: {}) {
            Text("MT")
        }
        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
        .scaleEffect(1.5)
        .buttonStyle(TriggerButtonStyle(side: .middle, style: .init(), isTurboEnabled: false))
        .padding()
        Button(action: {}) {
            Text("RT")
        }
        .frame(width: DEFAULT_BUTTON_SIZE, height: DEFAULT_BUTTON_SIZE)
        .scaleEffect(1.5)
        .buttonStyle(TriggerButtonStyle(side: .right, style: .init(), isTurboEnabled: false))
        .padding()
    }
}

