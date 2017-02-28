//
//  SmartDeviceExplorer.swift
//  TPLinkSmartPlug
//
//  Created by Colin Harris on 27/2/17.
//  Copyright © 2017 Colin Harris. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public class SmartDeviceExplorer: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let DEFAULT_BROADCAST_HOST = "255.255.255.255"
    static let DEFAULT_BROADCAST_PORT = UInt16(9999)
    static let DEFAULT_TIMEOUT = 5
    
    let host: String
    let port: UInt16
    let timeout: Int
    var socket: GCDAsyncUdpSocket!
    var devices = [Device]()
    
    public init(host: String = DEFAULT_BROADCAST_HOST, port: UInt16 = DEFAULT_BROADCAST_PORT, timeout: Int = DEFAULT_TIMEOUT) throws {
        self.host = host
        self.port = port
        self.timeout = timeout
        super.init()
        socket = GCDAsyncUdpSocket.init(delegate: self, delegateQueue: DispatchQueue.main)
        try socket.enableBroadcast(true)
        try socket.enableReusePort(true)
    }    
    
    public func findDevices(callback: @escaping ([Device]) -> Void) throws {
        
        let requestString = "{\"emeter\": {\"get_realtime\": null}, \"system\": {\"get_sysinfo\": null}}"
        let encryptedData = TPLinkSmartHomeProtocol.encrypt(content: requestString, includeLength: false)
        
        socket.send(encryptedData, toHost: host, port: port, withTimeout: TimeInterval(timeout+1), tag: 1)
        try socket.beginReceiving()
        
        let callbackTime = DispatchTime.now() + .seconds(timeout)
        DispatchQueue.main.asyncAfter(deadline: callbackTime) {
            self.socket.close()
            callback(self.devices)
        }
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
        let host = GCDAsyncUdpSocket.host(fromAddress: address)!
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        let jsonString = TPLinkSmartHomeProtocol.decrypt(data: data, includesLength: false)
        if let sysInfo = SmartPlugJSON.fromJson(jsonString) {
            self.devices.append(Device(ip: host, port: port, sysInfo: sysInfo))
        } else {
            print("Error parsing device info")
        }
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("udpSocketDidClose")
    }
}
