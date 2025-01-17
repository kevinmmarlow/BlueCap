//
//  ServiceTests.swift
//  BlueCapKit
//
//  Created by Troy Stribling on 1/7/15.
//  Copyright (c) 2015 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import CoreBluetooth
import CoreLocation
import BlueCapKit

class ServiceTests: XCTestCase {
    
    var centralManager : CentralManager!
    var mockCharateristics = [CBCharacteristicMock]()
    let mockService = CBServiceMock(UUID:CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6ccc"))
    
    override func setUp() {
        self.centralManager = CentralManagerUT(centralManager:CBCentralManagerMock(state:.PoweredOn))
        self.mockCharateristics.append(CBCharacteristicMock(UUID:CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6111"), properties:[.Read, .Write], permissions:[.Readable, .Writeable], isNotifying:false))
        self.mockCharateristics.append(CBCharacteristicMock(UUID:CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6222"), properties:[.Read, .Write], permissions:[.Readable, .Writeable], isNotifying:false))
        self.mockCharateristics.append(CBCharacteristicMock(UUID:CBUUID(string:"2f0a0017-69aa-f316-3e78-4194989a6333"), properties:[.Read, .Write], permissions:[.Readable, .Writeable], isNotifying:false))
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDiscoverCharacteristicsSuccess() {
        let peripheral = Peripheral(cbPeripheral:CBPeripheralMock(state:.Connected), centralManager:self.centralManager, advertisements:peripheralAdvertisements, rssi:-45)
        let service  = ServiceUT(cbService:self.mockService, peripheral:peripheral, mockCharacteristics:self.mockCharateristics, error:nil)
        let onSuccessExpectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = service.discoverAllCharacteristics()
        future.onSuccess {_ in
            onSuccessExpectation.fulfill()
            XCTAssert(service.characteristics.count == 3, "Characteristic count wroung")
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDiscoverCharacteristicsFailure() {
        let peripheral = Peripheral(cbPeripheral:CBPeripheralMock(state:.Connected), centralManager:self.centralManager, advertisements:peripheralAdvertisements, rssi:-45)
        let service  = ServiceUT(cbService:self.mockService, peripheral:peripheral, mockCharacteristics:self.mockCharateristics, error:TestFailure.error)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = service.discoverAllCharacteristics()
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testDiscoverCharacteristicsDisconnected() {
        let peripheral = Peripheral(cbPeripheral:CBPeripheralMock(state:.Disconnected), centralManager:self.centralManager, advertisements:peripheralAdvertisements, rssi:-45)
        let service  = Service(cbService:self.mockService, peripheral:peripheral)
        let onFailureExpectation = expectationWithDescription("onFailure fulfilled for future")
        let future = service.discoverAllCharacteristics()
        future.onSuccess {_ in
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            onFailureExpectation.fulfill()
            XCTAssert(error.code == PeripheralError.Disconnected.rawValue, "Error code invalid \(error.code)")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

}
