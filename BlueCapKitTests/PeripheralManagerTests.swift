//
//  PeripheralManagerTests.swift
//  BlueCapKit
//
//  Created by Troy Stribling on 3/25/15.
//  Copyright (c) 2015 Troy Stribling. The MIT License (MIT).
//

import UIKit
import XCTest
import CoreBluetooth
import CoreLocation
import BlueCapKit

class PeripheralManagerTests: XCTestCase {

    let peripheralName  = "Test Peripheral"
    let advertisedUUIDs = CBUUID(string:Gnosus.HelloWorldService.Greeting.uuid)
  
//
//    class BeaconRegionMock : BeaconRegionWrappable {
//        
//        let promise = StreamPromise<[BeaconMock]>()
//        
//        var identifier : String {
//            return "ID"
//        }
//        
//        var beaconPromise  : StreamPromise<[BeaconMock]> {
//            return self.promise
//        }
//        
//        func peripheralDataWithMeasuredPower(measuredPower:Int?) -> [String:AnyObject] {
//            return [:]
//        }
//    }
//    
//    class BeaconMock : BeaconWrappable {
//        
//    }
//
    override func setUp() {
        GnosusProfiles.create()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPowerOnWhenPoweredOn() {
        let (_, peripheralManager) = createPeripheralManager(false, state: .PoweredOn)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = peripheralManager.powerOn()
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testPowerOnWhenPoweredOff() {
        let (mock, peripheralManager) = createPeripheralManager(false, state: .PoweredOff)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = peripheralManager.powerOn()
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        mock.state = .PoweredOn
        peripheralManager.didUpdateState()
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testPowerOffWhenPoweredOn() {
        let (mock, peripheralManager) = createPeripheralManager(false, state: .PoweredOn)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = peripheralManager.powerOff()
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        mock.state = .PoweredOff
        peripheralManager.didUpdateState()
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testPowerOffWhenPoweredOff() {
        let (_, peripheralManager) = createPeripheralManager(false, state: .PoweredOff)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = peripheralManager.powerOff()
        future.onSuccess {
            expectation.fulfill()
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStartAdvertisingSuccess() {
        let (mock, peripheralManager) = createPeripheralManager(false, state: .PoweredOn)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = peripheralManager.startAdvertising(self.peripheralName, uuids:[self.advertisedUUIDs])
        future.onSuccess {
            expectation.fulfill()
            XCTAssert(mock.startAdvertisingCalled, "startAdvertising not called")
            if let advertisedData = mock.advertisementData,
                   name = advertisedData[CBAdvertisementDataLocalNameKey] as? String,
                   uuids = advertisedData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                XCTAssertEqual(name, self.peripheralName, "peripheralName invalid")
                XCTAssertEqual(uuids[0], self.advertisedUUIDs, "advertised UUIDs invalid")
            } else {
                XCTAssert(false, "advertisementData not found")
            }
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        peripheralManager.didStartAdvertising(nil)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStartAdvertisingFailure() {
        let (mock, peripheralManager) = createPeripheralManager(false, state: .PoweredOn)
        let expectation = expectationWithDescription("onFailure fulfilled for future")
        let future = peripheralManager.startAdvertising(self.peripheralName, uuids:[self.advertisedUUIDs])
        future.onSuccess {
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
            XCTAssertEqual(error.code, TestFailure.error.code, "error code invalid")
            XCTAssert(mock.startAdvertisingCalled, "startAdvertising not called")
            if let advertisedData = mock.advertisementData,
                name = advertisedData[CBAdvertisementDataLocalNameKey] as? String,
                uuids = advertisedData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
                    XCTAssertEqual(name, self.peripheralName, "peripheralName invalid")
                    XCTAssertEqual(uuids[0], self.advertisedUUIDs, "advertised UUIDs invalid")
            } else {
                XCTAssert(false, "advertisementData not found")
            }
        }
        peripheralManager.didStartAdvertising(TestFailure.error)
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStartAdvertisingWhenAdvertising() {
        let (mock, peripheralManager) = createPeripheralManager(true, state: .PoweredOn)
        let expectation = expectationWithDescription("onFailure fulfilled for future")
        let future = peripheralManager.startAdvertising(self.peripheralName, uuids:[self.advertisedUUIDs])
        future.onSuccess {
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            expectation.fulfill()
            XCTAssertEqual(error.code, PeripheralManagerError.IsAdvertising.rawValue, "Error code is invalid")
            XCTAssert(mock.advertisementData == nil, "advertisementData found")
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
    
//    func testStartAdvertisingBeaconSuccess() {
//        let mock = PeripheralManagerMock(isAdvertising:false, state:.PoweredOn)
//        let expectation = expectationWithDescription("onSuccess fulfilled for future")
//        let future = mock.impl.startAdvertising(mock, region:BeaconRegionMock())
//        future.onSuccess {
//            expectation.fulfill()
//        }
//        future.onFailure {error in
//            XCTAssert(false, "onFailure called")
//        }
//        PeripheralQueue.sync {
//            mock.impl.didStartAdvertising(nil)
//        }
//        waitForExpectationsWithTimeout(2) {error in
//            XCTAssertNil(error, "\(error)")
//        }
//    }
//
//    func testStartAdvertisingBeaconFailure() {
//        let mock = PeripheralManagerMock(isAdvertising:false, state:.PoweredOn)
//        let expectation = expectationWithDescription("onFailure fulfilled for future")
//        let future = mock.impl.startAdvertising(mock, region:BeaconRegionMock())
//        future.onSuccess {
//            XCTAssert(false, "onSuccess called")
//        }
//        future.onFailure {error in
//            expectation.fulfill()
//        }
//        PeripheralQueue.sync {
//            mock.impl.didStartAdvertising(TestFailure.error)
//        }
//        waitForExpectationsWithTimeout(2) {error in
//            XCTAssertNil(error, "\(error)")
//        }
//    }
//
//    func testStartAdvertisingBeaconWhenAdvertising() {
//        let mock = PeripheralManagerMock(isAdvertising:true, state:.PoweredOn)
//        let expectation = expectationWithDescription("onFailure fulfilled for future")
//        let future = mock.impl.startAdvertising(mock, region:BeaconRegionMock())
//        future.onSuccess {
//            XCTAssert(false, "onSuccess called")
//        }
//        future.onFailure {error in
//            XCTAssert(error.code == PeripheralManagerError.IsAdvertising.rawValue, "Error code is invalid \(error.code)")
//            expectation.fulfill()
//        }
//        waitForExpectationsWithTimeout(2) {error in
//            XCTAssertNil(error, "\(error)")
//        }
//    }

    func testStopAdvertising() {
        let (mock, peripheralManager) = createPeripheralManager(true, state: .PoweredOn)
        let expectation = expectationWithDescription("onSuccess fulfilled for future")
        let future = peripheralManager.stopAdvertising()
        future.onSuccess {
            expectation.fulfill()
            XCTAssert(mock.stopAdvertisingCalled, "stopAdvertisingCalled not called")
        }
        future.onFailure {error in
            XCTAssert(false, "onFailure called")
        }
        mock.isAdvertising = false
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testStopAdvertisingWhenNotAdvertsing() {
        let (mock, peripheralManager) = createPeripheralManager(false, state: .PoweredOn)
        let expectation = expectationWithDescription("onFailure fulfilled for future")
        let future = peripheralManager.stopAdvertising()
        future.onSuccess {
            XCTAssert(false, "onSuccess called")
        }
        future.onFailure {error in
            XCTAssertEqual(error.code, PeripheralManagerError.IsNotAdvertising.rawValue, "Error code is invalid")
            XCTAssertFalse(mock.stopAdvertisingCalled, "stopAdvertisingCalled called")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2) {error in
            XCTAssertNil(error, "\(error)")
        }
    }
}
