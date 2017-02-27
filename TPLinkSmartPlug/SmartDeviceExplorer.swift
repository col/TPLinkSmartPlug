//
//  SmartDeviceExplorer.swift
//  TPLinkSmartPlug
//
//  Created by Colin Harris on 27/2/17.
//  Copyright © 2017 Colin Harris. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class SmartDeviceExplorer: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let host = "255.255.255.255"
    static let port: UInt16 = 9999
    
    var socket: GCDAsyncUdpSocket!
    var devices = [Device]()
    
    init(broadcastIp: String) throws {
        super.init()
        socket = GCDAsyncUdpSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        try socket.enableBroadcast(true)
        try socket.enableReusePort(true)
    }    
    
    func findDevices(callback: ([Device]) -> Void) throws {
        
        let requestString = "{\"emeter\": {\"get_realtime\": null}, \"system\": {\"get_sysinfo\": null}}"
        let encryptedData = TPLinkSmartHomeProtocol.encrypt(content: requestString, includeLength: false)
        
        socket.send(encryptedData, toHost: SmartDeviceExplorer.host, port: SmartDeviceExplorer.port, withTimeout: 5, tag: 1)
        try socket.beginReceiving()
        
        // TODO: better way to wait for a response ?
        sleep(3)
        
        callback( [Device]() )
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("didConnectToAddress")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("didNotConnect")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("didNotSendDataWithTag")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("didReceive")
        let jsonString = TPLinkSmartHomeProtocol.decrypt(data: data)
        if let sysInfo = SmartPlugJSON.fromJson(jsonString) {
            var host: NSString?
            var port: UInt16 = 0
            GCDAsyncUdpSocket.getHost(&host, port: &port, fromAddress: address)
            let device = Device(ip: host as! String, port: port, sysInfo: sysInfo)
            self.devices.append(device)
        }
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("udpSocketDidClose")
    }
}
