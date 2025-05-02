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

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private var connection: NWConnection?
    @Published var receivedMessage: String = ""
    @Published var isConnected: Bool = false
    @Published var pairing: Bool = false
    @Published var networkState: Bool = false  // Tracks whether WiFi is available
    
    @Published var connectionError: String?
    
    @Published var discoveredServers: [NWEndpoint] = []
    
    private var browser: NWBrowser?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnecting: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.networkState = path.status == .satisfied && path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: queue)
    }
    
    func browseServers() {
        print("Searching for server...")
        let params = NWParameters.tcp
        params.includePeerToPeer = true
        browser = NWBrowser(for: .bonjour(type: "_pocketpad._tcp", domain: nil), using: params)
        
        browser?.browseResultsChangedHandler = { results, _ in
            print("Found results: \(results)")
            for result in results {
                if case let NWEndpoint.service(name, type_, domain, interface) = result.endpoint {
                    print("Found service: \(name) of type \(type_) in domain \(domain) on interface \(interface)")
                    
                    // Construct the full service name, including type and domain
                    let fullServiceName = "\(name).\(type_).\(domain)"
                    print("Full service name: \(fullServiceName), \(result.endpoint)")
                    
                    self.discoveredServers.append(result.endpoint)
                }
            }
        }
        
        isConnecting = true
        browser?.start(queue: .main)
    }
    
    func stopBrowsing() {
        discoveredServers.removeAll()
        isConnecting = true
        if let browser = browser {
            browser.cancel()
        }
    }
    
    func connect(to endpoint: NWEndpoint) {
        print("Connecting to \(endpoint)...")
        
        connection = NWConnection(to: endpoint, using: .tcp)
//        connection = NWConnection(host: NWEndpoint.Host("xx.xx.xx.xx"), port: NWEndpoint.Port(3000), using: params)

        
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
        print("Sending: \(message)")
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
                            
                            if message.status == "malformed_layout" {
                                // resend the layout
                                self.sendLayout(false)
                            }
                            else if message.status == "disconnect" {
                                self.connectionError = message.error
                                self.disconnect()
                            }
                            else if message.status == "pair_success" {
                                self.sendMessage("{\"request_id\": \"\(LayoutManager.shared.player_id_string)\"}")
                            }
                            else if message.status == "connect" {
                                guard let pid = message.pid else {
                                    self.connectionError = "Something went wrong"
                                    self.disconnect()
                                    return
                                }
                                self.connectionError = nil
                                self.isConnected = true
                                self.pairing = false
                                print("PID: \(pid)")
                                LayoutManager.shared.player_id = pid
                                
                                self.sendLayout(false)
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
    
    func sendInput(_ data: Data) {
        guard isConnected else { return }
        sendMessage("{\"pid\": \(LayoutManager.shared.player_id), \"input\": \"\(data.base64EncodedString())\"}")
    }
    
    func sendLayout(_ is_new: Bool) {
        guard isConnected else { return }
        
        let encoder = JSONEncoder()
        let layout = LayoutManager.shared.currentController
        
        var data = Data()
        
        do {
            data = try encoder.encode(layout)
        } catch {
            print("encoding error when sending layout")
            return
        }
        let selectedController = UserDefaults.standard.string(forKey: "selectedController") ?? "Xbox"
        let selectedControllerValue = ControllerType(stringValue: selectedController)?.rawValue ?? 0
        
        sendMessage("{\"pid\": \(LayoutManager.shared.player_id), \"\(is_new ? "new_" : "")layout\": \"\(data.base64EncodedString())\", \"controller_type\": \(selectedControllerValue)}")
    }
}
