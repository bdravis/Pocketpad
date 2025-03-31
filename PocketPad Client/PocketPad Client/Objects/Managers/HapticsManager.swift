//
//  HapticsManager.swift
//  PocketPad Client
//
//  Created by Bautista Tedin Fiorito on 3/30/25.
//

import UIKit

class HapticsManager {
    // Shared instance for global access.
    static let shared = HapticsManager()
    private init() { }
    
    // Triggers an impact haptic feedback.
    // set haptic to medium
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        // Create an impact feedback generator with the specified style.
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        // Trigger the haptic feedback.
        generator.impactOccurred()
    }
}
