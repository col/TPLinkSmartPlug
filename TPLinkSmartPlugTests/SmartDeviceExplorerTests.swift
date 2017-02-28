//
//  SmartDeviceExplorerTests.swift
//  TPLinkSmartPlug
//
//  Created by Colin Harris on 27/2/17.
//  Copyright © 2017 Colin Harris. All rights reserved.
//

import XCTest
@testable import TPLinkSmartPlug

class SmartDeviceExplorerTests: XCTestCase {
    
    func testFindDevices() throws {
        let explorer = try SmartDeviceExplorer(host: "255.255.255.255", port: UInt16(9999), timeout: 3)
        let exp = expectation(description: "findDevices")
        
        var foundDevices: [Device]?
        try explorer.findDevices { (devices) in
            foundDevices = devices
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 4) { (error) in
            XCTAssert(foundDevices!.count == 2)
            for device in foundDevices! {
                print("Device Host: \(device.ip) Port: \(device.port)")
                print("Device Info: \(device.sysInfo)")
            }
        }
    }
    
}
