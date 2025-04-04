//
//  NetworkManager.swift
//  PocketPad Client
//
//  Created by Krish Shah on 4/4/25.
//

import SwiftUI
import Network
import Foundation

struct Message : Codable {
    let status: String?
    let paircode: String?
    let error: String?
    let pid: UInt8?
    let message: String?
}

class TCPClient: ObservableObject {
    static let shared = TCPClient()
    
    private var connection: NWConnection?
    @Published var receivedMessage: String = ""
    @Published var isConnected: Bool = false
    @Published var pairing: Bool = false
    @Published var networkState: Bool = false  // Tracks whether WiFi is available
    
    @Published var connectionError: String?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.networkState = path.status == .satisfied && path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: queue)
    }
    
    func findServerAndConnect(port: UInt16) {
        print("Searching for server...")
        let params = NWParameters.tcp
        params.includePeerToPeer = true
        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: params)
        
        browser.browseResultsChangedHandler = { results, _ in
            print("Found results: \(results)")
            for result in results {
                if case let NWEndpoint.service(name, type_, domain, interface) = result.endpoint {
                    print("Found service: \(name) of type \(type_) in domain \(domain) on interface \(interface)")
                    
                    // Construct the full service name, including type and domain
                    let fullServiceName = "\(name).\(type_).\(domain)"
                    print("Full service name: \(fullServiceName), \(result.endpoint)")
                    
                    self.connect(to: result.endpoint, port: port)
                    browser.cancel()
                    break
                }
            }
        }
        
        browser.start(queue: .main)
    }
    
    func connect(to endpoint: NWEndpoint, port: UInt16) {
        print("Connecting to \(endpoint) on port \(port)...")
        
//        endpoint = NWEndpoint(
        
        let tcpParams = NWProtocolTCP.Options()
        tcpParams.enableFastOpen = true
        tcpParams.keepaliveIdle = 2
        let params = NWParameters(tls: nil, tcp: tcpParams)
        params.includePeerToPeer = true
        
        
        connection = NWConnection(host: NWEndpoint.Host("10.186.169.128"), port: NWEndpoint.Port(3000), using: params)
        
        connection?.pathUpdateHandler = { path in
            print("Connection path update: \(path)")
            if path.status == .satisfied {
                print("Connection path is satisfied")
            } else {
                print("Connection path is not satisfied: \(path.status)")
            }
        }
        
        connection?.stateUpdateHandler = { newState in
            DispatchQueue.main.async {
                switch newState {
                case .ready:
                    print("Connected to server")
                    self.pairing = true
                    self.receiveMessage()
                case .failed(let error):
                    print("Connection failed: \(error)")
                    self.isConnected = false
                case .waiting(let error):
                    print("Waiting for connection... \(error)")
                    self.isConnected = false
                case .cancelled:
                    print("Connection cancelled")
                    self.isConnected = false
                case .preparing:
                    print("Preparing connection...")
                    self.isConnected = false
                default:
                    print("Connection state changed: \(newState)")
                    break
                }
            }
        }
        connection?.start(queue: .main)
    }
    
    func sendMessage(_ message: String) {
        guard let connection = connection else { return }
        let data = message.data(using: .utf8) ?? Data()
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Send failed: \(error)")
            }
        }))
    }
    
    private func receiveMessage() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    // parse JSON into Message struct
                    if let jsonData = message.data(using: .utf8) {
                        do {
                            let decoder = JSONDecoder()
                            let message = try decoder.decode(Message.self, from: jsonData)
                            
                            print(message)
                            
                            if message.status == "disconnect" {
                                self.connectionError = message.error
                                self.disconnect()
                            }
                            if let pid = message.pid {
                                self.connectionError = nil
                                self.isConnected = true
                                self.pairing = false
                                print("PID: \(pid)")
                                LayoutManager.shared.player_id = pid
                            }
                        } catch {
                            print("Failed to parse JSON: \(error)")
                        }
                    } else {
                        print("Failed to convert message to data")
                    }
                }
            }
            if error == nil {
                self.receiveMessage()
            }
        }
    }
    
    func sendPaircode(_ code: String) {
        sendMessage("{\"paircode\": \"\( code )\"}")
    }
    
    func disconnect() {
        connection?.cancel()
        DispatchQueue.main.async {
            self.isConnected = false
            self.pairing = false
        }
        print("Disconnected from server")
    }
    
    func sendInput(pid: UInt8, iid: UInt8, btype: UInt8, event: UInt8) {
        if !isConnected {
            return
        }
        let packet = Data([pid, iid, btype, event])
        sendMessage("{\"pid\": \(pid), \"message\": \"\(packet.base64EncodedString())\"}")
    }
    
    func sendInput(pid: UInt8, iid: UInt8, btype: UInt8, event: UInt8, dpadDirection: UInt8) {
        if !isConnected {
            return
        }
        let packet = Data([pid, iid, btype, event, dpadDirection])
        sendMessage("{\"pid\": \(pid), \"message\": \"\(packet.base64EncodedString())\"}")
    }
    
    func sendInput(pid: UInt8, iid: UInt8, btype: UInt8, event: UInt8, angle: UInt8, magnitude: UInt8) {
        if !isConnected {
            return
        }
        let packet = Data([pid, iid, btype, event, angle, magnitude])
        sendMessage("{\"pid\": \(pid), \"message\": \"\(packet.base64EncodedString())\"}")
    }
    
//    func sendMotionData(playerId: UInt8, pitch: Float, roll: Float, yaw: Float) {
//        if !isConnected {
//            return
//        }
//        
//        // Convert the Float values to raw bytes (4 bytes each, little endian)
//        // We use the bitPattern property (UInt32) for consistent endianness
//        let pitchBytes = withUnsafeBytes(of: pitch.bitPattern.littleEndian) { Data($0) }
//        let rollBytes  = withUnsafeBytes(of: roll.bitPattern.littleEndian)  { Data($0) }
//        let yawBytes   = withUnsafeBytes(of: yaw.bitPattern.littleEndian)   { Data($0) }
//        
//        // Define a unique event code for motion data (e.g., 99)
//        let motionEvent: UInt8 = 99
//        
//        // Build the data packet:
//        // [playerId (1 byte), motionEvent (1 byte), pitch(4 bytes), roll(4 bytes), yaw(4 bytes)]
//        var packet = Data([playerId, motionEvent])
//        packet.append(pitchBytes)
//        packet.append(rollBytes)
//        packet.append(yawBytes)
//        
//        // Send the packet using the existing sendInput method
//        sendMessage(String(data: packet, encoding: .utf8) ?? "")
//    }
}
