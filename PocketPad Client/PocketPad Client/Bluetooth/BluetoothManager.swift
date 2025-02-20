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
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
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
    
    func disconnect() {
        if let peripheral = connectedDevice {
            centralManager.cancelPeripheralConnection(peripheral)
            discoveredServices.removeAll()
            discoveredCharacteristics.removeAll()
            selectedService = nil
            isConnecting = false
            connectedDevice = nil
        }
    }
    
    func sendData(_ dataString: String, to characteristic: CBCharacteristic) {
        guard let data = dataString.data(using: .utf8) else { return }
        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
        DispatchQueue.main.async {
            self.writeStatus = "Sending..."
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
            peripheral.discoverCharacteristics(nil, for: service)
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
}
