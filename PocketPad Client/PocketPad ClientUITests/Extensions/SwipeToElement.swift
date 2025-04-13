//
//  SwipeToElement.swift
//  PocketPad Client
//
//  Created by lemin on 4/3/25.
//

import XCTest

extension XCUIElement {
    func isVisible() -> Bool {
        if !self.exists || !self.isHittable || self.frame.isEmpty {
            return false
        }

        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
    
    func scrollToElement(_ element: XCUIElement, upward: Bool, amt: CGFloat = -262) {
        while !element.isVisible() {
            let startCoord = self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: amt * (upward ? -1 : 1)))
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }
}
