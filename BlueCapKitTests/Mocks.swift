//
//  Mocks.swift
//  BlueCapKit
//
//  Created by Troy Stribling on 5/2/15.
//  Copyright (c) 2015 Troy Stribling. The MIT License (MIT).
//

import UIKit
import CoreBluetooth
import CoreLocation
import BlueCapKit

struct TestFailure {
    static let error = NSError(domain:"BlueCapKit Tests", code:100, userInfo:[NSLocalizedDescriptionKey:"Testing"])
}

let peripheralAdvertisements = [CBAdvertisementDataLocalNameKey:"Test Peripheral",
                                CBAdvertisementDataTxPowerLevelKey:NSNumber(integer:-45)]

class CBCentralManagerMock : CBCentralManagerInjectable {
    
    var state : CBCentralManagerState
    var scanForPeripheralsWithServicesCalled = false
    var stopScanCalled = false
    
    init(state: CBCentralManagerState = .PoweredOn) {
        self.state = state
    }
    
    func scanForPeripheralsWithServices(uuids: [CBUUID]?, options:[ String:AnyObject]?) {
        self.scanForPeripheralsWithServicesCalled = true
    }
    
    func stopScan() {
        self.stopScanCalled = true
    }
    
    func connectPeripheral(peripheral: CBPeripheral, options: [String:AnyObject]?) {
    }
    
    func cancelPeripheralConnection(peripheral: CBPeripheral) {
    }
    
}

class CentralManagerUT : CentralManager {
    
    var connectPeripheralCalled     = false
    var cancelPeripheralConnection  = false
    
    override func connectPeripheral(peripheral: Peripheral, options: [String:AnyObject]? = nil) {
        self.connectPeripheralCalled = true
    }
    
    override func cancelPeripheralConnection(peripheral: Peripheral) {
        peripheral.didDisconnectPeripheral()
        self.cancelPeripheralConnection = true
    }
    
}

class CBPeripheralMock : CBPeripheralInjectable {
   
    var state : CBPeripheralState
    var _delegate : CBPeripheralDelegate? = nil
    
    var setDelegateCalled                       = false
    var discoverServicesCalled                  = false
    var discoverCharacteristicsCalled           = false
    var setNotifyValueCalled                    = false
    var readValueForCharacteristicCalled        = false
    var writeValueCalled                        = false
    
    var writtenData : NSData?
    var writtenType : CBCharacteristicWriteType?
    var notifyingState : Bool?
    
    var discoverServicesCalledCount         = 0
    var discoverCharacteristicsCalledCount  = 0
    
    var setNotifyValueCount                 = 0
    var readValueForCharacteristicCount     = 0
    var writeValueCount                     = 0
    
    let identifier                          = NSUUID()

    init(state:CBPeripheralState = .Disconnected) {
        self.state = state
    }
    
    var delegate : CBPeripheralDelegate? {
        get {
            return self._delegate
        }
        set {
            self._delegate = newValue
            self.setDelegateCalled = true
        }
    }
    
    var name : String? {
        return "Test Peripheral"
    }

    var services : [CBService]? {
        return nil
    }
    
    func discoverServices(services: [CBUUID]?) {
        self.discoverServicesCalled = true
        self.discoverServicesCalledCount++
    }
    
    func discoverCharacteristics(characteristics: [CBUUID]?, forService: CBService) {
        self.discoverCharacteristicsCalled = true
        self.discoverCharacteristicsCalledCount++
    }
    
    func setNotifyValue(state: Bool, forCharacteristic: CBCharacteristic) {
        self.setNotifyValueCalled = true
        self.setNotifyValueCount++
        self.notifyingState = state
    }
    
    func readValueForCharacteristic(characteristic: CBCharacteristic) {
        self.readValueForCharacteristicCount++
        self.readValueForCharacteristicCalled = true
    }
    
    func writeValue(data:NSData, forCharacteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        self.writeValueCount++
        self.writeValueCalled = true
        self.writtenData = data
        self.writtenType = type
    }

}

class PeripheralUT : Peripheral {
    
    let error:NSError?
    
    init(cbPeripheral: CBPeripheralInjectable, centralManager: CentralManager, advertisements: [String:AnyObject], rssi: Int, error: NSError?) {
        self.error = error
        super.init(cbPeripheral: cbPeripheral, centralManager: centralManager, advertisements: advertisements, rssi: rssi)
    }
    
    override func discoverService(head: Service, tail: [Service], promise: Promise<Peripheral>) {
        if let error = self.error {
            promise.failure(error)
        } else {
            promise.success(self)
            
        }
    }

}

class CBServiceMock : CBMutableService {
    
    init(UUID:CBUUID = CBUUID(string: "2f0a0017-69aa-f316-3e78-4194989a6ccc")) {
        super.init(type: UUID, primary: true)
    }
    
}

class ServiceUT : Service {
    
    let error : NSError?
    let mockCharacteristics : [CBCharacteristic]
    
    init(cbService: CBServiceMock, peripheral: Peripheral, mockCharacteristics: [CBCharacteristic], error: NSError?) {
        self.error = error
        self.mockCharacteristics = mockCharacteristics
        cbService.characteristics = mockCharacteristics
        super.init(cbService:cbService, peripheral:peripheral)
    }
    
    override func discoverAllCharacteristics() -> Future<Service> {
        self.didDiscoverCharacteristics(self.mockCharacteristics, error:self.error)
        return self.characteristicsDiscoveredPromise.future
    }
}

class CBCharacteristicMock : CBMutableCharacteristic {
    
    var _isNotifying = false
    
    override var isNotifying : Bool {
        get {
            return self._isNotifying
        }
        set {
            self._isNotifying = newValue
        }
    }

    init (UUID: CBUUID, properties: CBCharacteristicProperties, permissions: CBAttributePermissions, isNotifying: Bool) {
        super.init(type: UUID, properties: properties, value: nil, permissions: permissions)
        self._isNotifying = isNotifying
    }
    
}

class CBPeripheralManagerMock : CBPeripheralManagerInjectable {

    var updateValueReturn       = true
    
    var startAdvertisingCalled  = false
    var stopAdvertisingCalled   = false
    var addServiceCalled        = false
    var removeServiceCalled     = false
    var removeAllServicesCalled = false
    var respondToRequestCalled  = false
    var updateValueCalled       = false

    var advertisementData : [String:AnyObject]?
    var isAdvertising  : Bool
    var state : CBPeripheralManagerState
    var addedService : CBMutableService?
    var removedService : CBMutableService?
    
    var removeServiceCount = 0
    var addServiceCount = 0
    var updateValueCount = 0
    
    init(isAdvertising: Bool, state: CBPeripheralManagerState) {
        self.isAdvertising = isAdvertising
        self.state = state
    }
    
    func startAdvertising(advertisementData: [String:AnyObject]?) {
        self.startAdvertisingCalled = true
        self.advertisementData = advertisementData
        self.isAdvertising = true
    }
    
    func stopAdvertising() {
        self.stopAdvertisingCalled = true
        self.isAdvertising = false
    }
    
    func addService(service: CBMutableService) {
        self.addServiceCalled = true
        self.addedService = service
        self.addServiceCount++
    }
    
    func removeService(service: CBMutableService) {
        self.removeServiceCalled = true
        self.removedService = service
        self.removeServiceCount++
    }
    
    func removeAllServices() {
        self.removeAllServicesCalled = true
    }
    
    func respondToRequest(request: CBATTRequest, withResult result: CBATTError) {
        self.respondToRequestCalled = true
    }
    
    func updateValue(value: NSData, forCharacteristic characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        self.updateValueCalled = true
        self.updateValueCount++
        return self.updateValueReturn
    }
}

class PeripheralManagerUT : PeripheralManager {
    
    var respondToRequestCalled = false

    var error : NSError?
    var result : CBATTError?
    var request : CBATTRequestInjectable?
    
    override func addServices(promise: Promise<Void>, services: [MutableService]) {
        super.addServices(promise, services: services)
        if let service = services.first {
            self.didAddService(service.cbMutableService, error: self.error)
        }
    }
    
    override func respondToRequest(request: CBATTRequestInjectable, withResult result: CBATTError) {
        self.respondToRequestCalled = true
        self.result = result
        self.request = request
    }
}

class CBATTRequestMock : CBATTRequestInjectable {

    let characteristic: CBCharacteristic
    let offset: Int
    var value: NSData?
    
    init(characteristic: CBMutableCharacteristic, offset: Int, value: NSData? = nil) {
        self.value = value
        self.characteristic = characteristic
        self.offset = offset
    }
    
}

class CBCentralMock : CBCentralInjectable {

    let identifier: NSUUID
    let maximumUpdateValueLength: Int

    init(identifier: NSUUID, maximumUpdateValueLength: Int) {
        self.identifier = identifier
        self.maximumUpdateValueLength = maximumUpdateValueLength
    }
}

func createPeripheralManager(isAdvertising: Bool, state: CBPeripheralManagerState) -> (CBPeripheralManagerMock, PeripheralManagerUT) {
    let mock = CBPeripheralManagerMock(isAdvertising: isAdvertising, state: state)
    return (mock, PeripheralManagerUT(peripheralManager:mock))
}

func createPeripheralManagerServices(peripheral: PeripheralManager) -> [MutableService] {
    let profileManager = ProfileManager.sharedInstance
    if let helloWoroldService = profileManager.service[CBUUID(string: Gnosus.HelloWorldService.uuid)],
           locationService = profileManager.service[CBUUID(string: Gnosus.LocationService.uuid)] {
        return [MutableService(profile:helloWoroldService, peripheralManager: peripheral),
                MutableService(profile:locationService , peripheralManager: peripheral)]
    } else {
        return []
    }
}

