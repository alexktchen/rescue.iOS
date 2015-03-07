//
//  SessionService.swift
//  Rescue
//
//  Created by Alex Chen on 2015/1/26.
//  Copyright (c) 2015年 Alex Chen. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class SessionService : NSObject {
    
    let peerID: MCPeerID
    let session: MCSession
    
    var serviceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceBrowser: MCNearbyServiceBrowser?
   
    //delegates
    let sessionDelegate: SessionDelegate!
    var serviceAdvertiserDelegate: AdvertiserDelegate?
    var serviceBrowserDelegate: ServiceBrowserDelegate?
    
    //config stuff
    let serviceType = "rescue"
    let info = ["key":"value"]
    
    
    var inviteePeople:[MCPeerID] = []
    
    init(name:String){

       // peerID = MCPeerID(displayName: "\(UIDevice.currentDevice().identifierForVendor.UUIDString)")
        self.peerID = MCPeerID(displayName: name)

        // You can provide an optinal security identity for custom authentication.
        // Also you can set the encryption preference for the session.
        self.session = MCSession(peer: peerID)

        super.init()

        self.sessionDelegate = SessionDelegate(sessionService: self)
        self.session.delegate = sessionDelegate?

    }
    
    func startBrowsing(){
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        self.serviceBrowserDelegate = ServiceBrowserDelegate(session: session, myPeerID: peerID, sessionService: self)
        self.serviceBrowser?.delegate = serviceBrowserDelegate
        self.serviceBrowser?.startBrowsingForPeers()
    }
    
    func startAdvertising(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: info, serviceType: serviceType)
        self.serviceAdvertiserDelegate = AdvertiserDelegate(mySession: session, sessionService: self)
        self.serviceAdvertiser?.delegate = serviceAdvertiserDelegate
        self.serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func stopBrowsing(){
        self.serviceBrowser?.stopBrowsingForPeers()
    }
    
    func stopAdvertising(){
        self.serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    func disconnect(){
        self.serviceAdvertiser?.stopAdvertisingPeer()
        self.serviceBrowser?.stopBrowsingForPeers()
        self.serviceAdvertiser?.delegate = nil
        self.serviceBrowser?.delegate = nil
        self.inviteePeople.removeAll(keepCapacity: false)
        self.session.disconnect()
        self.session.delegate = nil
    }
    
    
    func onReceive(newHandler:(NSData) -> Void){
        sessionDelegate.handler = newHandler
    }
    
    func onBrowsing(newHandler:()-> Void){
        sessionDelegate.Browsing = newHandler
    }
    
    func onChangesStatue(newHandler:(NSInteger) -> Void){
        sessionDelegate.ChangesState = newHandler
    }
    
    func onConnected(newHandler:(String)-> Void){
        sessionDelegate.Connected = newHandler
    }
    
    func onNotConnected(newHandler:(String)-> Void){
        sessionDelegate.NotConnected = newHandler
    }
    

    func sendPhoto(post : JSQMessage){
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(post)
        var error : NSError?
        session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
    }
    
    func sendCard(post : MessageCard){
        // Send a data message to a list of destination peers
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(post)
        
        var error : NSError?
        
        println("The connectedPeer count is \(session.connectedPeers.count)")
        
        session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if let actualError = error {
            println("An Error Occurred: \(actualError)")
        }
        else{
            println("Yeahhh message sent")
        }
    }
    
    func send(post : JSQMessage){
        // Send a data message to a list of destination peers
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(post)
        
        var error : NSError?
        
        println("The connectedPeer count is \(session.connectedPeers.count)")
        
        session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if let actualError = error {
            println("An Error Occurred: \(actualError)")
        }
        else{
            println("Yeahhh message sent")
        }
    }
    
    
    
    func send(string: String){
        // Send a data message to a list of destination peers
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(string)
        
        var error : NSError?
        
        println("The connectedPeer count is \(session.connectedPeers.count)")
        
        session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if let actualError = error {
            println("An Error Occurred: \(actualError)")
        }
        else{
            println("Yeahhh message sent")
        }
    }
    
}

class SessionDelegate: NSObject, MCSessionDelegate {
    
    var handler:(NSData) -> Void
    
    var ChangesState:(Int) -> Void
    
    var Connected:(String) -> Void
    
    var NotConnected:(String) -> Void
    
    var Browsing:()->Void

    let sessionService:SessionService
    
    init(sessionService:SessionService){
        
        handler = {(text) -> Void in
            println("No handler defined.. so using default !")
        }
        
        ChangesState = {(text)-> Void in }
        
        Browsing = {(text)-> Void in }
        
        Connected = {(text) -> Void in }
        
        NotConnected = {(text) -> Void in}
        
        self.sessionService = sessionService
    }

    func removeObject<T : Equatable>(object: T, inout fromArray array: [T])
    {
        var index = find(array, object)
        array.removeAtIndex(index!)
    }
    
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState){
        
  
        switch state{
            
        case MCSessionState.Connecting:
            println("Browsing")
            self.Browsing()
            break
            
        case MCSessionState.Connected:
            
            let name = peerID?.displayName
            println("Connected")
            self.Connected(name!)
            
            break
        case MCSessionState.NotConnected:
            println("NotConnected")
            self.NotConnected("")
            println("inviteePeople count: \(self.sessionService.inviteePeople.count)")
            sessionService.inviteePeople.removeAll(keepCapacity: false)
            break

        default:
            break
            
        }

    }
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!){
        println("Received data from remote peer")
        self.handler(data)
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!){
        println("Received data from remote peer -> \(peerID?.displayName)")
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!){
        println("Start receiving a resource from remote peer -> \(peerID?.displayName)")
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!){
        println("Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox")
    }
    
    // Made first contact with peer and have identity information about the remote peer (certificate may be nil)
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        println("Made first contact with peer and have identity information about the remote peer (certificate may be nil)")
        if (certificateHandler != nil) {
            certificateHandler(true)
        }
        
    }
}

class AdvertiserDelegate: NSObject, MCNearbyServiceAdvertiserDelegate{
    
    let session: MCSession
    let sessionService: SessionService
    
    init(mySession:MCSession, sessionService:SessionService){
        session = mySession
        self.sessionService = sessionService
       // sessionService.inviteePeople.removeAll(keepCapacity: false)
    }
    
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!){
        
        println("advertiser ! -> Always says YES !!!")
        
        //always say yes !
        println(peerID.displayName)
        
        invitationHandler(true, session)
        sessionService.inviteePeople.append(peerID)
        
    }
    
    // Advertising did not start due to an error
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!){
        
        println("advertiser !!! -> Something NASTY HAPPENED :-( Error: \(error.localizedDescription)")
        
    }
    
}

class ServiceBrowserDelegate: NSObject, MCNearbyServiceBrowserDelegate {
    
    let session: MCSession
    
    let sessionService: SessionService
    
    let inviteTimeout: NSTimeInterval = 3 //30 seconds is the default anyway
    
    let myPeerID: MCPeerID
    
    init(session: MCSession, myPeerID: MCPeerID, sessionService:SessionService){
        self.session = session
        self.myPeerID = myPeerID
        self.sessionService = sessionService
        self.sessionService.inviteePeople.removeAll(keepCapacity: false)
    }
    
    // Found a nearby advertising peer
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("Found a nearby advertising peer")
        
        if peerID?.displayName == myPeerID.displayName {
            println("I have found myself :-)")
        }
        var invitedCount = sessionService.inviteePeople.filter { $0 == peerID }.count
        
        println("The invited count for peer \(peerID.displayName) was \(invitedCount)")
        
        if peerID?.displayName != myPeerID.displayName && invitedCount == 0 {
            
            println("I have found SOMEONE ELSE :-) ... inviting ! > displayName: \(peerID?.displayName)")
            
            browser?.invitePeer(peerID, toSession: session, withContext: nil, timeout: inviteTimeout)
           
        }
    }
    
    
    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!){
        
        let index = find(sessionService.inviteePeople, peerID)
        if index != nil{
            sessionService.inviteePeople.removeAtIndex(index!)
            println("A nearby peer has stopped advertising-> \(peerID?.displayName)")
        }
        
    }
    
    // Browsing did not start due to an error
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!){
        println("Browsing did not start due to an error")
    }
}