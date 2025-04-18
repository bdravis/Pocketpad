//
//  EditorTips.swift
//  PocketPad Client
//
//  Created by lemin on 4/18/25.
//

import TipKit

struct OrientationTip: Tip {
    var title: Text {
        Text("Unlock Rotation")
    }
    
    var message: Text? {
        Text("Use this to lock and unlock device rotation for the layout.")
    }
    
    var image: Image? {
        Image(systemName: "lock.rotation")
    }
}

struct OverrideTip: Tip {
    var title: Text {
        Text("Positional Overrides")
    }
    
    var message: Text? {
        Text("This allows you to have different button positions for when you rotate the device.")
    }
    
    var image: Image? {
        Image(systemName: "arrow.turn.up.forward.iphone")
    }
}
