//
//  OnBoardingInfo.swift
//  PocketPad Client
//
//  Created by lemin on 4/18/25.
//

import SwiftUICore

struct OnBoardingPage: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var image: String
    var gradientColors: [Color]
    
    init(title: String, description: String, image: String, gradientColors: [Color] = [Color("WelcomeLight"), Color("WelcomeDark")]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.image = image
        self.gradientColors = gradientColors
    }
}

let onBoardingCards: [OnBoardingPage] = [
    .init(
        title: "Welcome to PocketPad!",
        description: "Here is a tutorial to help you get started with the app.",
        image: "Logo"
    ),
    .init(
        title: "Choosing Your Controller",
        description: "In the Settings menu, you can choose your controller layout and even make your own.\n\nYou can also configure various aspects of your controller like haptics, motion controls, and deadzone.",
        image: "TutorialSettings"
    ),
    .init(
        title: "Designing Your Own Layout",
        description: "In your own layouts, you can customize each button's position, size, rotation, icon, colors, and more!",
        image: "TutorialEditor"
    ),
    .init(
        title: "Connecting to the Server",
        description: "To start playing, connect to any computer running the PocketPad server application.",
        image: "Logo" // TODO: Get screenshots
    ),
    .init(
        title: "Start Playing!",
        description: "Once you are connected, you can open up the controller and start playing.\n\nEnjoy PocketPad!",
        image: "TutorialController"
    )
]
