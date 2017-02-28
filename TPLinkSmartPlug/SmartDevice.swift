//
//  SmartDevice.swift
//  TPLinkSmartPlug
//
//  Created by Colin Harris on 27/2/17.
//  Copyright © 2017 Colin Harris. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public class SmartDevice: NSObject, GCDAsyncSocketDelegate {
    
    public typealias RequestCallback = (Any?) -> ()
    
    enum RequestType: Int {
        case SysInfo
        case Time
        case SetRelayState
        case SetLedState
    }
    
    let host: String
    let port: UInt16
    let timeout: UInt16
    
    var socket: GCDAsyncSocket?
    var connectCallback: (() -> ())?
    var requestCallback: RequestCallback?
    var connected = false
    
    public init(host: String, port: UInt16 = 9999, timeout: UInt16 = 5) {
        self.host = host
        self.port = port
        self.timeout = timeout
        super.init()
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "SmartDevice-\(host)"))
    }
    
    public func connect(callback: @escaping () -> ()) throws {
        self.connectCallback = callback
        try socket?.connect(toHost: host, onPort: port, withTimeout: TimeInterval(timeout))
    }
    
    public func disconnect() {
        socket?.delegate = nil
        socket?.disconnect()
    }
    
    func sendRequest(target: String, command: String, args: [String: Any]? = [:], tag: RequestType, callback: RequestCallback? = nil) {
        self.requestCallback = callback
        let request = [target: [command: args]]
        let encryptedRequest = TPLinkSmartHomeProtocol.encrypt(content: SmartPlugJSON.toJson(request)!)
        socket?.write(encryptedRequest, withTimeout: TimeInterval(timeout), tag: tag.rawValue)
        socket?.readData(withTimeout: TimeInterval(timeout), tag: tag.rawValue)
    }
    
    public func getSysInfo(callback: @escaping RequestCallback) {
        sendRequest(target: "system", command: "get_sysinfo", tag: .SysInfo, callback: callback)
    }
    
    public func getTime(callback: @escaping RequestCallback) {
        sendRequest(target: "time", command: "get_time", tag: .Time, callback: callback)
    }
    
    public func setState(_ state: Bool) {
        sendRequest(target: "system", command: "set_relay_state", args: ["state": state ? 1 : 0], tag: .SetRelayState)
    }
    
    public func setLedState(_ state: Bool) {
        sendRequest(target: "system", command: "set_led_off", args: ["off": state ? 0 : 1], tag: .SetLedState)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("socket:didConnectToHost")
        connected = true
        DispatchQueue.main.async {
            self.connectCallback?()
        }
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("socket:didRead - tag: \(tag)")
        let response = SmartPlugJSON.fromJson(TPLinkSmartHomeProtocol.decrypt(data: data))!
        
        switch RequestType(rawValue: tag)! {
        case .SysInfo:
            let target = response["system"] as? [String: Any]
            let command = target?["get_sysinfo"] as? [String: Any]
            self.requestCallback?(command)
        default:
            print("Unknown request type!")
        }
    }

    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("socket:didWriteDataWithTag")
    }

    public func socketDidCloseReadStream(_ sock: GCDAsyncSocket) {
        print("socketDidCloseReadStream")
    }

    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect - \(err?.localizedDescription)")
    }

}
