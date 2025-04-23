//
//  BluetoothManager.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//
//  Edited by Benjamin Dravis 4/13/25
//

import CoreBluetooth
import SwiftUI
import Combine

final class AlertManager: ObservableObject {
    static let shared = AlertManager() // Singleton
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    func show(title: String, message: String) {
        DispatchQueue.main.async { // Must run on main thread
            self.alertTitle = title
            self.alertMessage = message
            self.showAlert = true
        }
    }
}

// MARK: - Bluetooth Manager
class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    @Published var isScanning = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var connectedDevice: CBPeripheral?
    @Published var discoveredServices: [CBService] = []
    @Published var selectedService: CBService?
    @Published var discoveredCharacteristics: [CBCharacteristic] = []
    @Published var lastMessage: String = ""
    @Published var writeStatus: String = ""
    @Published var isConnecting = false
    
    @Published var paircodeNeeded = false
    @Published var fullyConnected = false
    
    var paircode: String?
    
    @Published var connectionError: String?
    
    @State private var showingIDTakenAlert = false
    @State private var idTakenMessage = ""
    
    private var latency_timer: DispatchSourceTimer?
    
    private var layoutBuffer = ""
    private var expectedLayoutLength: Int?
    private var expectedLayoutLengthHandler: ((Int) -> Void)?
    @ObservedObject private var layoutManager = LayoutManager.shared
    @AppStorage("selectedController") var selectedController: String = ControllerType.getDefaultName()
    
    @AppStorage("connectionType") private var serverType: Int = 0
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        start_latency_sending()
    }
    
    deinit {
        latency_timer?.cancel()
        latency_timer = nil
    }
    
    private func start_latency_sending() {
        latency_timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        latency_timer?.schedule(deadline: .now(), repeating: 3.0)
        latency_timer?.setEventHandler { [weak self] in
            self?.pingServer()
        }
        latency_timer?.resume()
    }
    
    // MARK: - Public Methods
    func startScanning() {
        self.connectionError = ""
        guard centralManager.state == .poweredOn else { return }
        
        isScanning = true
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: [POCKETPAD_SERVICE], options: nil)
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
        discoveredDevices.removeAll()
    }
    
    func connect(to peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        isConnecting = true
        centralManager.connect(peripheral, options: nil)
    }
    
    func sendData(_ dataString: String, to characteristic: CBCharacteristic) {
        guard let data = dataString.data(using: .utf8) else { return }
        peripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
        DispatchQueue.main.async {
            self.writeStatus = "Sending..."
        }
    }
    
    func sendInput(_ data: Data) {
        if serverType == 1 {
            guard let service = selectedService else { return }
            if let char = discoveredCharacteristics.first(where: { $0.uuid == INPUT_CHARACTERISTIC }) {
                peripheral?.writeValue(data, for: char, type: .withoutResponse)
            }
        } else {
            guard NetworkManager.shared.isConnected else { return }
            NetworkManager.shared.sendMessage("{\"pid\": \(LayoutManager.shared.player_id), \"input\": \"\(data.base64EncodedString())\"}")
        }
    }
    
    func pingServer() {
        guard let service = selectedService else { return }
        if let char = discoveredCharacteristics.first(where: { $0.uuid == LATENCY_CHARACTERISTIC }) {
            let now = UInt32(min((Date().timeIntervalSinceReferenceDate * 1000).truncatingRemainder(dividingBy: 100000), Double(UInt32.max)))
            
            let playerIDBytes = withUnsafeBytes(of: LayoutManager.shared.player_id.littleEndian) { Data($0) }
            let timestampBytes = withUnsafeBytes(of: now.littleEndian) { Data($0) }

            // Concatenates, not bitwise add
            let dataToSend = Data(playerIDBytes + timestampBytes)
            
            service.peripheral?.writeValue(dataToSend, for: char, type: .withoutResponse)
        }
    }
     
    func disconnect() {
        if let peripheral = connectedDevice {
            
            // This does not currently work because it should wait until it hears back from the server but there is not a callback for that
            if let characteristic = self.discoveredCharacteristics.first(where: { $0.uuid == CONNECTION_CHARACTERISTIC }) {
                
                let response_data = [LayoutManager.shared.player_id, ConnectionMessage.disconnecting.rawValue, 0]
                
                peripheral.writeValue(Data(response_data), for: characteristic, type: .withResponse)
                peripheral.readValue(for: characteristic)
            }

        }
    }
   
    func readValue(for characteristic: CBCharacteristic) {
        peripheral?.readValue(for: characteristic)
    }
    
    func startNotifications(for characteristic: CBCharacteristic) {
        peripheral?.setNotifyValue(true, for: characteristic)
    }
    
    func stopNotifications(for characteristic: CBCharacteristic) {
        peripheral?.setNotifyValue(false, for: characteristic)
    }
    
    func updateControllerConfiguration() {
        let selectedController = UserDefaults.standard.string(forKey: "selectedController") ?? "Xbox"
        let selectedControllerValue = ControllerType(stringValue: selectedController)?.rawValue ?? 0
        
        guard let service = selectedService else { return }
        
        let encoder = JSONEncoder()
        
        var data = Data()
        
        do {
            data = try encoder.encode(LayoutManager.shared.currentController)
        } catch {
            print("encoding error when sending layout")
            return
        }
        
        let subdata_size = 182
        var position = 0
        
        guard let service = selectedService else { return }
        if let char = discoveredCharacteristics.first(where: { $0.uuid == CONTROLLER_TYPE_CHARACTERISTIC }) {
    
            let init_transmission_packet = Data([UInt8(LayoutManager.shared.player_id),
                                                     UInt8(selectedControllerValue),
                                                     UInt8(255)
                                                    ])
                
            service.peripheral?.writeValue(init_transmission_packet, for: char, type: .withResponse)
            service.peripheral?.readValue(for: char)
                
            while position < data.count {
                    
                let chunk_size: UInt8 = UInt8(min(position + subdata_size, data.count) - position)
                
                let chunk = data.subdata(in: position..<position + Int(chunk_size))
                    
                let packet = Data([UInt8(LayoutManager.shared.player_id),
                                    UInt8(selectedControllerValue),
                                    UInt8(chunk_size)
                                  ]) + chunk
                    
                service.peripheral?.writeValue(packet, for: char, type: .withResponse)
                service.peripheral?.readValue(for: char)
                position += subdata_size
            }
                
            let end_transmission_packet = Data([UInt8(LayoutManager.shared.player_id),
                                                    UInt8(selectedControllerValue),
                                                    UInt8(0)
                                                   ])
                
            service.peripheral?.writeValue(end_transmission_packet, for: char, type: .withResponse)
            service.peripheral?.readValue(for: char)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.bluetoothState = central.state
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            if !self.discoveredDevices.contains(peripheral) {
                self.discoveredDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedDevice = peripheral
            self.isConnecting = false
            self.stopScanning()
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.isConnecting = false
            self.connectionError = error?.localizedDescription ?? ""
            print("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.connectedDevice = nil
            self.isConnecting = false
            self.discoveredServices.removeAll()
            self.discoveredCharacteristics.removeAll()
            self.selectedService = nil
            self.lastMessage = ""
            self.writeStatus = ""
            self.peripheral = nil
            if self.connectionError == nil {
                self.connectionError = "Connection lost"
            }
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        DispatchQueue.main.async {
            self.discoveredServices = services
        }
        
        for service in services {
            if service.uuid == POCKETPAD_SERVICE {
                self.selectedService = service
            }
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Services modified: \(invalidatedServices)")
        
        for service in invalidatedServices {
            if service.uuid == POCKETPAD_SERVICE {
                print("Invalidated PocketPad service")
                self.selectedService = nil
                self.discoveredServices.removeAll()
                self.discoveredCharacteristics.removeAll()
                self.connectedDevice = nil
                self.isConnecting = false
                self.lastMessage = ""
                self.connectionError = "Connection lost"
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        
        DispatchQueue.main.async {
            if service == self.selectedService {
                self.discoveredCharacteristics = characteristics
            }
        }
        
        // Send 1 to CONNECTION_CHARACTERITIC on connection
        
        for characteristic in characteristics {
            if characteristic.uuid == CONNECTION_CHARACTERISTIC {
                // Send the message upon discovering the characteristic
                
                send_string_id_and_request_string_number()
                
            }
        }
    }

    func send_string_id_and_request_string_number() {
        
        guard let service = selectedService else { return }
        guard let characteristics = service.characteristics else { return }
        let requested_player_id = LayoutManager.shared.player_id_string.utf8
        let requested_player_id_len: UInt8 = UInt8(LayoutManager.shared.player_id_string.count)
        
        let packet = Data([LayoutManager.shared.player_id, ConnectionMessage.requesting_id.rawValue, requested_player_id_len] + requested_player_id)
       
        for characteristic in characteristics {
            if characteristic.uuid == CONNECTION_CHARACTERISTIC {
                
                service.peripheral?.writeValue(packet, for: characteristic, type: .withResponse)
                service.peripheral?.readValue(for: characteristic)

                
                // Rest of functionality on this path is in didUpdateValueFor with ConnectionMessage.requesting_id
            }
        }
        
    }
    
    func requestID() {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error reading characteristic value: \(error!.localizedDescription)")
            return
        }
        
        guard error == nil,
              let data = characteristic.value else {
            print("Error reading characteristic: \(error?.localizedDescription ?? "unknown")")
            return
        }
        switch characteristic.uuid {
        case PAIRCODE_CHARACTERISTIC:
            paircode = String(data: data, encoding: .utf8)
            print("PAIRCODE \(paircode)")
            paircodeNeeded = true
        case CONNECTION_CHARACTERISTIC:
            handleConnectionMessage(data, from: peripheral, characteristic: characteristic)
        case LAYOUT_REQUEST_CHARACTERISTIC:
            if expectedLayoutLength == nil {
                let length = data.prefix(4).withUnsafeBytes {
                    $0.load(as: UInt32.self)
                }.littleEndian
                print("Length \(length)")
                expectedLayoutLength = Int(length)
                expectedLayoutLengthHandler?(Int(length))
                expectedLayoutLengthHandler = nil
            }
            else {
                let chunkData = data.subdata(in: 1..<data.count)
                if let chunkString = String(data: chunkData, encoding: .utf8) {
                    layoutBuffer += chunkString
                    if layoutBuffer.utf8.count >= expectedLayoutLength! {
                        guard let layout_encoded = layoutBuffer.data(using: .utf8) else {
                            fatalError("Failed to convert string to Data")
                        }
                        let decoder = JSONDecoder()
                        do {
                            let layout = try decoder.decode(LayoutConfig.self, from: layout_encoded)
                            do {
                                try saveLayoutIfNeeded(layout)
                                try layoutManager.loadLayouts(includeControllerTypes: true)
                                try layoutManager.setCurrentLayout(to: layout.name)
                                selectedController = layout.name
                            } catch {
                                UIApplication.shared.alert(body: error.localizedDescription)
                            }
                        } catch {
                            print("Decoding failed:", error)
                        }
                    }
                }
            }
        default:
            if let str = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async { self.lastMessage = str }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.writeStatus = "Error: \(error.localizedDescription)"
            } else {
                self.writeStatus = "Sent successfully"
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
            return
        }
    }
    
    func sendLayout(layout: LayoutConfig) {
        
        guard let service = selectedService else { return }
        
        let encoder = JSONEncoder()
        
        var data = Data()
        
        do {
            data = try encoder.encode(layout)
        } catch {
            print("encoding error when sending layout")
            return
        }
  
        let subdata_size = 182
        var position = 0
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == CONNECTION_CHARACTERISTIC {
                
                let init_transmission_packet = Data([UInt8(LayoutManager.shared.player_id),
                                                     UInt8(ConnectionMessage.transmitting_layout.rawValue),
                                                     UInt8(255)
                                                     ])
                
                service.peripheral?.writeValue(init_transmission_packet, for: characteristic, type: .withResponse)
                service.peripheral?.readValue(for: characteristic)
                
                while position < data.count {
                    
                    let chunk_size: UInt8 = UInt8(min(position + subdata_size, data.count) - position)
                    
                    let chunk = data.subdata(in: position..<position + Int(chunk_size))
                    
                    let packet = Data([UInt8(LayoutManager.shared.player_id),
                                       UInt8(ConnectionMessage.transmitting_layout.rawValue),
                                       UInt8(chunk_size)
                                       ]) + chunk
                    
                    service.peripheral?.writeValue(packet, for: characteristic, type: .withResponse)
                    service.peripheral?.readValue(for: characteristic)
                    position += subdata_size
                }
                
                let end_transmission_packet = Data([UInt8(LayoutManager.shared.player_id),
                                   UInt8(ConnectionMessage.transmitting_layout.rawValue),
                                   UInt8(0)
                                   ])
                
                service.peripheral?.writeValue(end_transmission_packet, for: characteristic, type: .withResponse)
                service.peripheral?.readValue(for: characteristic)
            }
        }
        
    }
    
    private func handleConnectionMessage(_ data: Data, from peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        
        let bytes = [UInt8](data)
        guard bytes.count >= 2 else {return}
        let signal = bytes[1]
        
        switch signal {
        case ConnectionMessage.recieved.rawValue:
            print("Server acknowledged disconnection")
            centralManager.cancelPeripheralConnection(peripheral)
            discoveredServices.removeAll()
            discoveredCharacteristics.removeAll()
            selectedService = nil
            isConnecting = false
            connectedDevice = nil
            fullyConnected = false
            paircodeNeeded = false
        
        case ConnectionMessage.requesting_id.rawValue:
            print("Server acknowledged connection")
            print("player_id: \(data)")
            
            let int_player_id = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            
            if int_player_id != 255 {
                // If requested Id is available,continue with connection
                
                LayoutManager.shared.player_id = int_player_id
                
                let selectedController = UserDefaults.standard.string(forKey: "selectedController") ?? "Xbox"
                
                sendLayout(layout: LayoutManager.shared.currentController)
                
                let selectedControllerValue = ControllerType(stringValue: selectedController)?.rawValue ?? 0
                
                let response_data = [LayoutManager.shared.player_id, ConnectionMessage.connecting.rawValue, UInt8(selectedControllerValue)]
                
                peripheral.writeValue(Data(response_data), for: characteristic, type: .withResponse)
                peripheral.readValue(for: characteristic)
                // get paircode characteristic
                
                if let pairchar = discoveredCharacteristics.first(where: { $0.uuid == PAIRCODE_CHARACTERISTIC }) {
                    peripheral.readValue(for: pairchar)
                }
                
            } else {
                //Display to user that ID is taken
                print("invalid id")
                AlertManager.shared.show(
                    title: "ID Taken",
                    message: "The ID is already in use."
                )
                
                LayoutManager.shared.requested_player_id_string = "Player"
                BluetoothManager.shared.connectedDevice = nil
            }
        case ConnectionMessage.requesting_id_change.rawValue:
            print("Server acknowledged connection")
            print("player_id: \(data)")
            
            let int_player_id = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            
            if int_player_id != 255 {
                // If requested Id is available,continue with connection
                
                LayoutManager.shared.player_id_string = LayoutManager.shared.requested_player_id_string
                
            } else {
                
                //Display to user that ID is taken
                print("invalid id")
                AlertManager.shared.show(
                    title: "ID Taken",
                    message: "The ID is already in use."
                )
                LayoutManager.shared.requested_player_id_string = "Player"
                disconnect()
            }
        default:
            if let str = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {self.lastMessage = str}
            }
        }
    }
    
    func saveLayoutIfNeeded(_ layout: LayoutConfig) throws {
        guard !layoutManager.layoutExists(for: layout.name) else {
            // No-op for duplicates
            return
        }
        try layoutManager.saveLayout(layout)
    }
}

extension BluetoothManager {
    //- Parameters:
    //  - playerId: The player's ID as a UInt8.
    //  - pitch: The pitch value (Float).
    //   - roll: The roll value (Float).
    //  - yaw: The yaw value (Float).
    func sendMotionData(playerId: UInt8, pitch: Float, roll: Float, yaw: Float, xAcceleration: Float, yAcceleration: Float, zAcceleration: Float) {
//        guard let _ = selectedService else { return }
        
        // Convert the Float values to raw bytes (4 bytes each, little endian)
        // We use the bitPattern property (UInt32) for consistent endianness
        let pitchBytes = withUnsafeBytes(of: pitch.bitPattern.littleEndian) { Data($0) }
        let rollBytes  = withUnsafeBytes(of: roll.bitPattern.littleEndian)  { Data($0) }
        let yawBytes   = withUnsafeBytes(of: yaw.bitPattern.littleEndian)   { Data($0) }
        let xBytes = withUnsafeBytes(of: xAcceleration.bitPattern.littleEndian) { Data($0) }
        let yBytes  = withUnsafeBytes(of: yAcceleration.bitPattern.littleEndian)  { Data($0) }
        let zBytes   = withUnsafeBytes(of: zAcceleration.bitPattern.littleEndian)   { Data($0) }
        
        // Define a unique event code for motion data (e.g., 99)
        let motionEvent: UInt8 = 99
        
        // Build the data packet:
        // [playerId (1 byte), motionEvent (1 byte), pitch(4 bytes), roll(4 bytes), yaw(4 bytes)]
        var packet = Data([playerId, motionEvent])
        packet.append(pitchBytes)
        packet.append(rollBytes)
        packet.append(yawBytes)
        packet.append(xBytes)
        packet.append(yBytes)
        packet.append(zBytes)
        
        // Send the packet using the existing sendInput method
        sendInput(packet)
    }
}

extension BluetoothManager {
    
    func requestExpectedLayoutLength(using characteristic: CBCharacteristic, completion: @escaping (Int) -> Void) {
        layoutBuffer = ""
        expectedLayoutLength = nil
        expectedLayoutLengthHandler = completion
        
        var trigger = Data()
        let start = UInt32(0).littleEndian
        let end   = UInt32(0).littleEndian
        trigger.append(contentsOf: withUnsafeBytes(of: start) { Data($0) })
        trigger.append(contentsOf: withUnsafeBytes(of: end)   { Data($0) })

        peripheral?.writeValue(trigger, for: characteristic, type: .withResponse)
        peripheral?.readValue(for:  characteristic)
    }
}

extension BluetoothManager {
    
    func requestGameData() {
        guard let service = selectedService,
              let char = service.characteristics?.first(where: { $0.uuid == LAYOUT_REQUEST_CHARACTERISTIC })
        else { return }

        requestExpectedLayoutLength(using: char) { [weak self] layoutLength in guard let self = self else { return }
            for index in stride(from: 0, to: layoutLength, by: 240) {
                var packet = Data()
                let start = UInt32(index).littleEndian
                let end   = UInt32(index + 240).littleEndian
                packet.append(contentsOf: withUnsafeBytes(of: start) { Data($0) })
                packet.append(contentsOf: withUnsafeBytes(of: end)   { Data($0) })
                
                self.peripheral?.writeValue(packet, for: char, type: .withResponse)
                self.peripheral?.readValue(for: char)
            }
        }
    }
}
