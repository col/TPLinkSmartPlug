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
    
    func testTest() {
        XCTAssert(SmartDevice.test() == "test")
    }
    
}
