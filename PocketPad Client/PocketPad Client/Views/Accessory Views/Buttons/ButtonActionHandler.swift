//
//  ButtonActionHandler.swift
//  PocketPad Client
//
//  Created by lemin on 3/6/25.
//

import SwiftUI

struct ButtonActionHandler: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}


extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(ButtonActionHandler(onPress: {
            HapticsManager.playHaptic()
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
