//
//  BluetoothManager.swift
//  PocketPad Client
//
//  Created by Krish Shah on 2/19/25.
//

import CoreBluetooth
import SwiftUI
import Combine

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
    
    @Published var connectionError: String?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
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
        guard let service = selectedService else { return }
        if let char = discoveredCharacteristics.first(where: { $0.uuid == INPUT_CHARACTERISTIC }) {
            peripheral?.writeValue(data, for: char, type: .withoutResponse)
        }
    }
    
    func pingServer() {
        guard let service = selectedService else { return }
        if let char = discoveredCharacteristics.first(where: { $0.uuid == LATENCY_CHARACTERISTIC }) {
            let now = UInt32(min((Date().timeIntervalSinceReferenceDate * 1000).truncatingRemainder(dividingBy: 100000), Double(UInt32.max)))
            //service.peripheral?.writeValue(String(now).data(using: .utf8)!, for: char, type: .withResponse)
            
            let playerIDBytes = withUnsafeBytes(of: LayoutManager.shared.player_id.littleEndian) { Data($0) }

            let timestampBytes = withUnsafeBytes(of: now.littleEndian) { Data($0) }

            // Concatenates, not bitwise add
            let dataToSend = Data(playerIDBytes + timestampBytes)
            
            service.peripheral?.writeValue(dataToSend, for: char, type: .withResponse)
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
            self.connectionError = "Connection lost"
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
                
                let selectedController = UserDefaults.standard.string(forKey: "selectedController") ?? "Xbox"
                
                let selectedControllerValue = ControllerType(stringValue: selectedController)?.rawValue ?? 0
                
                let response_data = [LayoutManager.shared.player_id, ConnectionMessage.connecting.rawValue, UInt8(selectedControllerValue)]
                
                requestID()
                
                sendLayout(layout: LayoutManager.shared.currentController)

                peripheral.writeValue(Data(response_data), for: characteristic, type: .withResponse)
                peripheral.readValue(for: characteristic)
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
        
        if let value = characteristic.value,
           let string = String(data: value, encoding: .utf8) {
            DispatchQueue.main.async {
                self.lastMessage = string
            }
        }
        
        if characteristic.uuid == CONNECTION_CHARACTERISTIC {
            // Process the server's response
            if let value = characteristic.value {
                let newId = value[0] // Assuming the response is a single byte
                let signal = value[1] // Assuming the response is a single byte
                print("Server response: \(signal)")
                
                // Check if the response is RECIEVED_CONNECTION_INFORMATION
                if signal == ConnectionMessage.recieved.rawValue {
                    print("Server acknowledged disconnection")
                    
                    // Disconnect after receiving the response
                    centralManager.cancelPeripheralConnection(peripheral)
                    discoveredServices.removeAll()
                    discoveredCharacteristics.removeAll()
                    selectedService = nil
                    isConnecting = false
                    connectedDevice = nil
                }
                
                // Check if the response is RECIEVED_CONNECTION_INFORMATION
                if signal == ConnectionMessage.connecting.rawValue {
                    print("Server acknowledged connection")
                    print("player_id: \(value)")
                    
                    LayoutManager.shared.player_id = newId

                }
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
        
        let packet_size = 20
        let code_size = 1
        let id_size = 1
        let size_size = 1
        let subdata_size = 182
        var position = 0
        
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == CONNECTION_CHARACTERISTIC {
                
                let init_transmission_packet = Data([UInt8(LayoutManager.shared.player_id),
                                                     UInt8(ConnectionMessage.transmitting_layout.rawValue),
                                                     UInt8(255)
                                                     ])
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
}

extension BluetoothManager {
    //- Parameters:
    //  - playerId: The player's ID as a UInt8.
    //  - pitch: The pitch value (Float).
    //   - roll: The roll value (Float).
    //  - yaw: The yaw value (Float).
    func sendMotionData(playerId: UInt8, pitch: Float, roll: Float, yaw: Float) {
        guard let _ = selectedService else { return }
        
        // Convert the Float values to raw bytes (4 bytes each, little endian)
        // We use the bitPattern property (UInt32) for consistent endianness
        let pitchBytes = withUnsafeBytes(of: pitch.bitPattern.littleEndian) { Data($0) }
        let rollBytes  = withUnsafeBytes(of: roll.bitPattern.littleEndian)  { Data($0) }
        let yawBytes   = withUnsafeBytes(of: yaw.bitPattern.littleEndian)   { Data($0) }
        
        // Define a unique event code for motion data (e.g., 99)
        let motionEvent: UInt8 = 99
        
        // Build the data packet:
        // [playerId (1 byte), motionEvent (1 byte), pitch(4 bytes), roll(4 bytes), yaw(4 bytes)]
        var packet = Data([playerId, motionEvent])
        packet.append(pitchBytes)
        packet.append(rollBytes)
        packet.append(yawBytes)
        
        // Send the packet using the existing sendInput method
        sendInput(packet)
    }
}
