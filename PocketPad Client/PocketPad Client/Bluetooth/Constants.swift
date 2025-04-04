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
let LATENCY_CHARACTERISTIC = CBUUID(string: "BFC0C92F-317D-4BA9-976B-CC11CE77B4CA")
let CONNECTION_CHARACTERISTIC = CBUUID(string: "EA946B3E-D83D-4804-9DC4-A33A768868C8")
let PLAYER_ID_CHARACTERISTIC = CBUUID(string: "D95A2FA4-22AC-4858-9F3F-008D6D87271E")
let CONTROLLER_TYPE_CHARACTERISTIC = CBUUID(string: "366B5778-9B7E-4D98-B952-A8852B11FA77")
let INPUT_CHARACTERISTIC = CBUUID(string: "E576715C-1C73-4237-8CA6-6625C28FB3DC")
let PAIRCODE_CHARACTERISTIC = CBUUID(string: "B4A2C7F5-7E4D-4F6A-9F1C-3E8E9D3A0F8D")

enum ConnectionMessage: UInt8, Codable {
    case recieved = 0
    case connecting = 1
    case disconnecting = 2
    case transmitting_layout = 3
    case requesting_id = 4
    case requesting_id_change = 5
}
