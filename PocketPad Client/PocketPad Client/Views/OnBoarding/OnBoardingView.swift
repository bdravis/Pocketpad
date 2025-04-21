//
//  OnBoardingView.swift
//  PocketPad Client
//
//  Created by lemin on 4/18/25.
//

import SwiftUI

struct OnBoardingView: View {
    @State var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            OnBoardingCardView(info: onBoardingCards[currentIndex], pageCount: onBoardingCards.count, idx: $currentIndex)
        }
    }
}
