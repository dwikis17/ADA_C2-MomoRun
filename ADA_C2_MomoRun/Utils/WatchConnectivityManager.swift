//
//  WatchConnectivityManager.swift
//  MomoRun
//
//  Created by [Your Name] on [Date].
//

import WatchConnectivity
import Foundation // Import Foundation for NSObject
import Combine // Import Combine for @Published

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedMessage: String = ""
    @Published var isReachable: Bool = false
    @Published var finalSessionCaloriesFromWatch: Double?
    
    var onDirection: ((String) -> Void)?
    var onRestart: (() -> Void)?
    var onStart: (() -> Void)?
    var onFinalSessionCaloriesReceived: ((Double) -> Void)?
    
    // New callbacks for calorie functionality
    var onCalorieDirection: ((String) -> Void)?
    var onCalorieDone: (() -> Void)?
    
    // New callbacks for screen synchronization
    var onScreenChange: ((String) -> Void)?

    // New callback for go to calorie setup
    var onGoToCalorieSetup: (() -> Void)?

    // New callback for receiving current calorie value
    var onCurrentCalorieValue: ((Int) -> Void)?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            self.isReachable = WCSession.default.isReachable
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation completion if needed
        DispatchQueue.main.async {
            self.isReachable = (activationState == .activated && session.isReachable)
        }
        print("WCSession activation did complete with state: \(activationState.rawValue)")
//        self.isReachable = session.isReachable
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
        self.isReachable = false
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            print("HERE")
            print("received user info | \(userInfo)")
            if let finalCalories = userInfo["sessionFinalCalories"] as? Double {
                print("Received final session calories from Watch: \(finalCalories)")
                CalorieData.shared.addCalories(finalCalories)
                self.onFinalSessionCaloriesReceived?(finalCalories)
            }
        }
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
            if let start = message["start"] as? Bool, start {
                self.onStart?()
                print("Received start command")
            }
            
            // Handle calorie related messages
            if let calorieDirection = message["calorieDirection"] as? String {
                self.onCalorieDirection?(calorieDirection)
                print("Received calorie direction: \(calorieDirection)")
            }
            if let calorieDone = message["calorieDone"] as? Bool, calorieDone {
                self.onCalorieDone?()
                print("Received calorie done command")
            }
            
            // Handle go to calorie setup message from watch
            if let goToCalorieSetup = message["goToCalorieSetup"] as? Bool, goToCalorieSetup {
                self.onGoToCalorieSetup?()
                print("Received go to calorie setup command")
            }
            
            // Handle screen synchronization messages
            if let screenType = message["screenType"] as? String {
                self.onScreenChange?(screenType)
                print("Received screen change: \(screenType)")
            }
            
            // Handle current calorie value from phone
            if let currentCalorieValue = message["currentCalorieValue"] as? Int {
                self.onCurrentCalorieValue?(currentCalorieValue)
                print("Received current calorie value: \(currentCalorieValue)")
            }
            
//            if let finalCalories = message["sessionFinalCalories"] as? Double {
//                print("Received final session calories from Watch: \(finalCalories)")
//                CalorieData.shared.addCalories(finalCalories)
//                self.onFinalSessionCaloriesReceived?(finalCalories)
//            }
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
    
    // Function to tell the watch to show calorie setup UI
    func sendShowCalorieSetup() {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable.")
            return
        }
        
        WCSession.default.sendMessage(["showCalorieSetup": true], replyHandler: nil) { error in
            if error != nil {
                print("Error sending showCalorieSetup: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to notify watch of current screen
    func sendScreenChange(_ screenType: String) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable.")
            return
        }
        
        WCSession.default.sendMessage(["screenType": screenType], replyHandler: nil) { error in
            if error != nil {
                print("Error sending screen change: \(error.localizedDescription)")
            }
        }
    }
    
    // Function to send current calorie value to watch
    func sendCurrentCalorieValue(_ value: Int) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable.")
            return
        }
        
        WCSession.default.sendMessage(["currentCalorieValue": value], replyHandler: nil) { error in
            if error != nil {
                print("Error sending current calorie value: \(error.localizedDescription)")
            }
        }
    }
}
