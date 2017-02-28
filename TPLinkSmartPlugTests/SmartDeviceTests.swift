//
//  SmartDeviceTests.swift
//  TPLinkSmartPlug
//
//  Created by Colin Harris on 27/2/17.
//  Copyright © 2017 Colin Harris. All rights reserved.
//

import XCTest
@testable import TPLinkSmartPlug

class SmartDeviceTests: XCTestCase {
    
    var smartDevice: SmartDevice!
    
    override func setUp() {
        super.setUp()
        smartDevice = SmartDevice(host: "192.168.0.101", port: 9999)
    }
    
    func testConnect() throws {
        let exp = expectation(description: "connect")
        
        try smartDevice.connect() { exp.fulfill() }
        
        waitForExpectations(timeout: 5) { (error) in
            XCTAssert(self.smartDevice.connected)
            self.smartDevice.disconnect()
        }
    }
    
    func testGetSysInfo() throws {
        let exp = expectation(description: "getSysInfo")
        
        var sysInfoResponse: [String: Any]?
        try smartDevice.connect() {
            self.smartDevice.getSysInfo() { sysInfo in
                sysInfoResponse = sysInfo as? [String: Any]
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print("SysInfo = \(sysInfoResponse)")
            XCTAssert(sysInfoResponse != nil)
            self.smartDevice.disconnect()
        }
    }
    
    func testSetState() throws {
        let exp = expectation(description: "setState")
        
        try smartDevice.connect() {
            self.smartDevice.setState(true)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            self.smartDevice.disconnect()
        }
    }
    
    func testSetLedState() throws {
        let exp = expectation(description: "setLedState")
        
        try smartDevice.connect() {
            self.smartDevice.setLedState(true)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            self.smartDevice.disconnect()
        }
    }
    
}
