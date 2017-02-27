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
        let explorer = try SmartDeviceExplorer(broadcastIp: "")
        let exp = expectation(description: "findDevices")
        
        var foundDevices: [Device]?
        try explorer.findDevices { (devices) in
            foundDevices = devices
            exp.fulfill()
        }
        waitForExpectations(timeout: 6) { (error) in
            XCTAssert(foundDevices!.count == 0)
        }
    }
    
}
