//
//  Constants.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import Foundation
import CoreBluetooth

// This is the UUID that designates the device with PocketPad.
// The client can filter out all devices that don't have this UUID.
let POCKETPAD_SERVICE = CBUUID(string: "4AF8BC29-479B-4492-980A-45BFAAA2FAB6")
let POCKETPAD_CHARACTERISTIC = CBUUID(string: "BFC0C92F-317D-4BA9-976B-CC11CE77B4CA")
