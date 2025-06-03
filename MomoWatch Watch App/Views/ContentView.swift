//
//  ContentView.swift
//  MomoWatch Watch App
//
//  Created by Dwiki on 20/05/25.
//

import SwiftUI
import WatchConnectivity
import WatchKit

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var status: String = ""
    @Published var gameOver: Bool = false
    @Published var showCalorieSetup: Bool = false
    @Published var currentScreen: String = "mainMenu" // Track current phone screen
    @Published var currentCalorieValue: Int = 500 // Track current calorie value from phone
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let info = message["info"] as? String {
                self.status = info
                if info == "Game Over" {
                    self.gameOver = true
                }
            }
            
            if let showCalorieSetup = message["showCalorieSetup"] as? Bool, showCalorieSetup {
                self.showCalorieSetup = true
            }
            
            // Handle screen synchronization
            if let screenType = message["screenType"] as? String {
                self.currentScreen = screenType
                
                // Update specific states based on screen type
                switch screenType {
                case "mainMenu":
                    self.showCalorieSetup = false
                    self.gameOver = false
                case "calorieSetup":
                    self.showCalorieSetup = true
                    self.gameOver = false
                case "loading", "game":
                    self.showCalorieSetup = false
                    self.gameOver = false
                case "gameOver":
                    self.showCalorieSetup = false
                    self.gameOver = true
                default:
                    break
                }
            }
            
            // Handle current calorie value synchronization
            if let currentCalorieValue = message["currentCalorieValue"] as? Int {
                self.currentCalorieValue = currentCalorieValue
            }
        }
    }
    
    // Send a calorie value to the phone
    func sendCalorieValue(_ value: Int) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["calorieValue": value], replyHandler: nil)
        }
    }
    
    // Send calorie done signal to the phone
    func sendCalorieDone() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["calorieDone": true], replyHandler: nil)
            showCalorieSetup = false
        }
    }
    
    // Send direction command to the phone
    func sendCalorieDirection(_ direction: String) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["calorieDirection": direction], replyHandler: nil)
        }
    }
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    @StateObject private var sensorModel = SensorModel()
    @State private var didPlayHaptic = false
    @State private var gameStarted = false
    
    @StateObject private var healthStore = HealthStore()
    @State private var caloriesBurned: Double = 0.0
    @State private var heartRate: Int = 0
    
    private var showCalories: Bool = true
    
    var body: some View {
        ZStack {
            Image(.momoBG)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .ignoresSafeArea()
            
            // Show different views based on current phone screen
            switch watchSession.currentScreen {
            case "mainMenu":
                MainMenuWatchView(
                    sensorModel: sensorModel,
                    gameStarted: $gameStarted
                )
                
            case "calorieSetup":
                CalorieSetupWatchView(watchSession: watchSession)
                
            case "loading":
                LoadingWatchView()
                
            case "gameOver":
                GameOverWatchView(
                    watchSession: watchSession,
                    sensorModel: sensorModel,
                    didPlayHaptic: $didPlayHaptic,
                    gameStarted: $gameStarted,
                    caloriesBurned: caloriesBurned,
                    heartRate: heartRate
                )
                
            case "game":
                GameWatchView(
                    sensorModel: sensorModel,
                    healthStore: healthStore,
                    caloriesBurned: $caloriesBurned,
                    heartRate: $heartRate
                )
                
            default:
                // Fallback view
                Text("Syncing...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(watchSession.status)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .onChange(of: sensorModel.directionX) { _ in
            if !sensorModel.directionX.isEmpty {
                sendDirection(sensorModel.directionX)
            }
        }
        .onChange(of: sensorModel.directionZ) { _ in
            if !sensorModel.directionZ.isEmpty {
                sendDirection(sensorModel.directionZ)
            }
        }
        .onChange(of: watchSession.gameOver) { newValue in
            if newValue {
                if !didPlayHaptic {
                    WKInterfaceDevice.current().play(.failure)
                    didPlayHaptic = true
                }
                sensorModel.stopFetchingSensorData()
                gameStarted = false
            }
        }
    }
    
    private func sendDirection(_ direction: String) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["direction": direction], replyHandler: nil, errorHandler: { error in
                DispatchQueue.main.async {
                    watchSession.status = "Failed: \(error.localizedDescription)"
                }
            })
            watchSession.status = "Sent: \(direction.capitalized)"
        } else {
            watchSession.status = "Not reachable"
        }
    }
}

#Preview {
    ContentView()
}
