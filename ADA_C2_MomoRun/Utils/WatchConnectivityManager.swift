//
//  WatchConnectivityManager.swift
//  MomoRun
//
//  Created by [Your Name] on [Date].
//

import WatchConnectivity
import Foundation // Import Foundation for NSObject

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedMessage: String = ""
    var onDirection: ((String) -> Void)?
    var onRestart: (() -> Void)?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
        print("WCSession activation did complete with state: \(activationState.rawValue)")
        if let error = error {
            print("WCSession activation error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive if needed
        print("WCSession did become inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Required for WCSessionDelegate - reactivate the session
        print("WCSession did deactivate, reactivating...")
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let info = message["info"] as? String {
                self.receivedMessage = info
                print("Received info: \(info)")
            }
            if let direction = message["direction"] as? String {
                self.onDirection?(direction)
                print("Received direction: \(direction)")
            }
            if let restart = message["restart"] as? Bool, restart {
                self.onRestart?()
                print("Received restart command")
            }
        }
    }
    
    // Example function to send a message to the watch
    func sendToWatch(message: [String: Any]) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable.")
            return
        }
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            if error != nil {
                 print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
} 
