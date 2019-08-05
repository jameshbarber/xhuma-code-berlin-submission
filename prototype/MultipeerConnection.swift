//
//  MultipeerConnection.swift
//  self-build
//
//  Created by James Hilton-Barber on 2019/07/30.
//  Copyright © 2019 James Hilton-Barber. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MultipeerConnection: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mpcSession)
    }
    
    
    var myPeerId: MCPeerID!
    var mpcSession: MCSession!
    var mpcBrowser: MCNearbyServiceBrowser!
    var mpcAdvertiser: MCNearbyServiceAdvertiser!
    var sessionActive: Bool!
    var status = ""
    
    var peerConnections: Array<MCPeerID>!
    
    override init(){
        super.init()
        
        print("Began init()")
        
        // create Peer ID
        myPeerId = MCPeerID(displayName: UIDevice.current.name)
        // Init Session
        sessionActive = false
        mpcSession = MCSession(peer: myPeerId)
        mpcSession.delegate = self
        
        mpcAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: "xhuma-chat")
        mpcAdvertiser.delegate = self

        mpcBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: "xhuma-chat")
        mpcBrowser.delegate = self
        mpcBrowser.startBrowsingForPeers()
        mpcAdvertiser.startAdvertisingPeer()
        
    }
    
    
    // Advertiser Methods
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Conntected to peer: \(peerID.displayName)")
            if mpcSession.connectedPeers.count > 1 {
                sessionActive = true
            }
        case .connecting:
            print("Connecting to peer: \(peerID.displayName)")
        case .notConnected:
            print("Disconnected from Peer: \(peerID.displayName)")
            if mpcSession.connectedPeers.count < 1 {
                sessionActive = false
            }
        default:
            print("Error")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("received: \(data) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("received: \(stream) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("receiving: \(resourceName) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("finished: \(resourceName) from peer \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if info?["String"] == nil {
            print("Found peer \(peerID.displayName)")
            mpcBrowser.invitePeer(peerID, to: mpcSession, withContext: nil, timeout: 20)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }

}
