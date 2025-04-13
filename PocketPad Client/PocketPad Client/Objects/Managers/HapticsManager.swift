//
//  HapticsManager.swift
//  PocketPad Client
//
//  Created by Bautista Tedin Fiorito on 3/30/25.
//


import UIKit

class HapticsManager {
    // Static function so that you can call HapticsManager.playHaptic() without an instance.
    static func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

