//
//  Device.swift
//  TPLinkSmartPlug
//
//  Created by Colin Harris on 27/2/17.
//  Copyright © 2017 Colin Harris. All rights reserved.
//

import Foundation

struct Device {
    var ip: String
    var port: UInt16
    var sysInfo: [String: Any]
}
