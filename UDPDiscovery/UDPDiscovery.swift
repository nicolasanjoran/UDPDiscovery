//
//  UDPDiscovery.swift
//  Umix
//
//  Created by Nicolas Anjoran on 03/07/16.
//  Copyright © 2016 Nicolas Anjoran. All rights reserved.
//

import Foundation

public protocol UDPDiscoveryDelegate {
    
    func udpDiscovery(discovery: UDPDiscovery, didReceivedResponseFrom ip: String, message: String?)
    func udpDiscovery(discovery: UDPDiscovery, didReceivedRequestFrom ip: String) -> String?
    
}

public extension UDPDiscoveryDelegate{
    public func udpDiscovery(discovery: UDPDiscovery, didReceivedResponseFrom ip: String, message: String?){}
    public func udpDiscovery(discovery: UDPDiscovery, didReceivedRequestFrom ip: String) -> String?{return nil}
}

public enum UDPDiscovery_InstanceType {
    case Server
    case Client
}

public class UDPDiscovery {
    
    public static let sharedInstance = UDPDiscovery()
    
    //let addresses = NetworkUtils.getWiFiAddress()
    public var type = UDPDiscovery_InstanceType.Client
    public var serverRunning = false;
    public var clientSearching = false;
    public var identifier = "UDPDiscovery"
    public var defaultMessage = ""
    public var listenIP : String  = ""
    public var listenPort : Int = 14332
    public var delegate : UDPDiscoveryDelegate?
    private var client : UDPClient?
    private var server : UDPServer?
    
    public func startServer()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if(self.client != nil)
            {
                self.client?.close()
            }
            self.client = UDPClient(addr: "255.255.255.255", port: self.listenPort)
            self.client?.enableBroadcast()
            if(self.server != nil)
            {
                self.server?.close()
            }
            if(self.type == .Client)
            {
                self.listenIP = ""
            }
            print (self.listenPort)
            print (self.listenIP)
                self.server = UDPServer(addr: self.listenIP, port: self.listenPort)
                self.serverRunning = true
                while self.serverRunning {
                    print("[UDPDiscovery] Server Running.")
                    let (data,remoteip,remoteport)=self.server!.recv(1024)
                    if let d=data{
                        if let str=String(bytes: d, encoding: NSUTF8StringEncoding){
                            print(str)
                            if(str.componentsSeparatedByString(":").first == "\(self.identifier).discover.request" && self.type == .Server)
                            {
                                print("[UDPDiscovery] discover request received from \(remoteip):\(remoteport)  -> Sending response")
                                dispatch_async(dispatch_get_main_queue(), {
                                    let msg = self.delegate?.udpDiscovery(self, didReceivedRequestFrom: remoteip)
                                    var resp = "\(self.identifier).discover.server:"
                                    if msg != nil {
                                        resp = resp + msg!
                                    }else{
                                        resp = resp + self.defaultMessage
                                    }
                                    self.client?.send(str: resp)
                                })
                            }else if(str.componentsSeparatedByString(":").first == "\(self.identifier).discover.server"){
                                print("[UDPDiscovery] discover server response received from \(remoteip):\(remoteport)")
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.delegate?.udpDiscovery(self, didReceivedResponseFrom: remoteip, message: str.componentsSeparatedByString(":")[1])
                                })
                            }
                        }
                    }
                }
 
            
        }
    }
    
    public func stopServer()
    {
        serverRunning = false
        server?.close()
        self.client?.close()
        print("[UDPDiscovery] Server stopped.")
    }
    
    public func startSearch()
    {
        self.clientSearching = true
        if(self.client != nil)
        {
            self.client?.close()
        }
        self.client = UDPClient(addr: "255.255.255.255", port: listenPort)
        self.client?.enableBroadcast()
        startServer()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            while self.clientSearching {
                print("[UDPDiscovery] Sending Search Broadcast...")
                self.client?.send(str: "\(self.identifier).discover.request")
                sleep(1)
            }
        }
        
    }
    
    public func stopSearch()
    {
        self.clientSearching = false;
        stopServer()
    }
    
}