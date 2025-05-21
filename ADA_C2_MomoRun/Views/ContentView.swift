//
//  ContentView.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import SwiftUI
import SpriteKit
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedMessage: String = ""
    var onDirection: ((String) -> Void)?
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let info = message["info"] as? String {
                self.receivedMessage = info
            }
            if let direction = message["direction"] as? String {
                self.onDirection?(direction)
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    // Read the flag from UserDefaults
    @AppStorage("hasSetCalorieTarget") private var hasSetCalorieTarget: Bool = false
    // State variable to control presentation
    @State private var showCalorieSetup = false

    var body: some View {
        // Check if calorie target has been set
        if showCalorieSetup {
            // Show the setup view if it hasn't been set or state variable is true
            CalorieTargetSetupView(showSetup: $showCalorieSetup)
        } else {
            // Show the main content (your existing VStack with SpriteView)
            VStack {
                if !watchSession.receivedMessage.isEmpty {
                    Text("From Watch: \(watchSession.receivedMessage)")
                        .font(.headline)
                        .padding(.top)
                }
                GeometryReader { geometry in
                    SpriteView(scene: MainMenuScene(size: geometry.size))
                        .ignoresSafeArea()
                }
            }
            // .onAppear check is now here to set showCalorieSetup state
            .onAppear {
                 // Only show setup if the flag is false
                 if !hasSetCalorieTarget {
                     showCalorieSetup = true
                 }
                 // The watch session handler is currently commented out, it should be moved to the GameScene or a manager
                 // watchSession.onDirection = { direction in
                 //     if direction == "left" {
                 //         gameScene.moveLeftFromWatch()
                 //     } else if direction == "right" {
                 //         gameScene.moveRightFromWatch()
                 //     }
                 // }
            }
        }
    }
}

#Preview {
    ContentView()
}
