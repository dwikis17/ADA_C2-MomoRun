//
//  ContentView.swift
//  MomoWatch Watch App
//
//  Created by Dwiki on 20/05/25.
//

import Foundation
import SwiftUI
import WatchConnectivity
import WatchKit

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var status: String = ""
    @Published var gameOver: Bool = false
    @Published var showCalorieSetup: Bool = false
    @Published var currentScreen: String = "mainMenu" // Track current phone screen
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("Watch: Error finishing UserInfo transfer: \(error.localizedDescription). UserInfo: \(userInfoTransfer.userInfo)")
        } else {
            // This confirms the system has processed the send request.
            // It doesn't guarantee the iPhone has received it yet, but it's a successful handoff from the Watch's perspective.
            print("Watch: UserInfo transfer finished successfully (system acknowledged). UserInfo: \(userInfoTransfer.userInfo)")
        }
    }
    
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
    
//    func sendFinalSessionCalories(_ calories: String) {
//        if WCSession.default.isReachable {
//            WCSession.default.sendMessage(["sessionFinalCalories": calories], replyHandler: nil)
//        }
//    }
    
    func sendFinalSessionCalories(_ calories: String) {
        let session = WCSession.default
        print("Watch Session State: activated=\(session.activationState.rawValue), reachable=\(session.isReachable)")
        
        if session.isReachable {
            let calorieData = ["sessionFinalCalories": calories]

//            if session.activationState == .activated {
//                let userInfoTransfer = session.transferUserInfo(calorieData)
//                print("Queued final session calories for transfer: \(calories) with identifier \(userInfoTransfer)")
//            } else {
//                print("WCSession not activated on Watch. Cannot transfer user info.")
//            }
            session.sendMessage(calorieData, replyHandler: { _ in
                print("Successfully sent final session calories (\(calories)) to iPhone.")
            }, errorHandler: { error in
                print("Error sending final session calories to iPhone: \(error.localizedDescription)")
            })
        } else {
            print("Watch is not reachable. can't send calories.")
        }
    }
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    @StateObject private var sensorModel = SensorModel()
    @State private var didPlayHaptic = false
    @State private var gameStarted = false
    @State private var calorieValue: Double = 2000
    
    @StateObject private var healthStore = HealthStore()
    @State private var caloriesBurned: Double = 0.0
    @State private var heartRate: Int = 0
    
    private var showCalories: Bool = true
    
 
    var body: some View {
        ZStack {
            Image(.momoBG)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Show different views based on current phone screen
            switch watchSession.currentScreen {
            case "mainMenu":
                // Main menu view
                VStack(spacing: 15) {
                    Text("MomoRun")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Ready to Play!")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("Start Game") {
                        if WCSession.default.isReachable {
                            WCSession.default.sendMessage(["start": true], replyHandler: nil)
                            gameStarted = true
//                            sensorModel.startFetchingSensorData()
                            startSensor(true, true)
                        }
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                
            case "calorieSetup":
                // Calorie setup view
                VStack(spacing: 10) {
                    Text("\(Int(calorieValue))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .focusable(true)
                        .digitalCrownRotation(
                            $calorieValue,
                            from: 0.0,
                            through: 5000.0,
                            by: 50.0,
                            sensitivity: .medium,
                            isContinuous: false,
                            isHapticFeedbackEnabled: true
                        )
                        .onChange(of: calorieValue) { oldValue, newValue in
                            // Send direction command instead of actual value
                            if newValue > oldValue {
                                watchSession.sendCalorieDirection("up")
                            } else if newValue < oldValue {
                                watchSession.sendCalorieDirection("down")
                            }
                        }
                    
                    Text("KCAL")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button("DONE") {
                        watchSession.sendCalorieDone()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.top)
                }
                .onAppear {
                    // Initialize to 500 when view appears
                    calorieValue = 500.0
                }
                
            case "loading":
                // Loading view
                VStack(spacing: 15) {
                    Text("Loading...")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
            case "gameOver":
                // Game over view
                VStack(spacing: 15) {
                    Text("Game Over")
                        .font(.custom("Jersey15-Regular", size:40))
                        .foregroundColor(.red)
                        .padding()
                    
                    HStack (spacing: 30) {
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("\(caloriesBurned, specifier: "%.1f") kcal")
                        }
                        HStack {
                            Image(systemName: "heart.fill")
                            Text("\(heartRate)")
                        }
                    }
                    
                    Button(action : {
                        startSensor(true)
//                        watchSession.gameOver = false
//                        watchSession.status = ""
                        didPlayHaptic = false
//                        sensorModel.startFetchingSensorData()
                        if WCSession.default.isReachable {
                            WCSession.default.sendMessage(["restart": true], replyHandler: nil) { err in
                                print("this is restart error \(err.localizedDescription)")
                            }
                            // Immediately start the game after retry
                            WCSession.default.sendMessage(["start": true], replyHandler: nil)
                            WCSession.default.sendMessage(["calories" : self.caloriesBurned],replyHandler: nil, errorHandler: { error in
                                print("HERE- Error sending final session calories to iPhone: \(error.localizedDescription)")
                            })
                            gameStarted = true
                        }
                    }) {
                        Image(.retryBtn)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 150)
                }
                .onAppear() {
                    startSensor(false)
                }
                
            case "game":
                // Game controls view
                VStack (spacing: 10) {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("\(caloriesBurned, specifier: "%.1f") kcal")
                    }
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("\(heartRate)")
                    }
                }
                
                // Motion controls section (only shown when game is started)
                Button(action: {
                    startSensor(!sensorModel.isFetching)
                }) {
                    Text(sensorModel.isFetching ? "Stop Controls" : "Start Controls")
                }
                .tint(sensorModel.isFetching ? .red : .white)
                
                if sensorModel.isFetching {
                    Text("Motion tracking active")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                
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
    
    private func startSensor(_ start: Bool, _ isFirstStart: Bool = false) {
        
        if start && isFirstStart {
            healthStore.startWorkout()
        } else  if start {
            healthStore.resumeSession()
        }
        
        if start  {
            sensorModel.startFetchingSensorData()
            healthStore.startCalorieSession()
            self.caloriesBurned = CalorieData.shared.getTodayCalories()
            print("Starting fetch...")
            print("Today calories: \(CalorieData.shared.getTodayCalories())")
            self.heartRate = 0 // Reset heart rate every start a new fetch
            
            if Config.getHealthStoreData {
                Task {
                    await healthStore.requestHealthData()
                    healthStore.startLiveCalorieUpdates { calories in
                        self.caloriesBurned = calories
                    }
                    healthStore.fetchHeartRateLive { rate in
                        self.heartRate = Int(rate)
                    }
                }
            }
        } else {
            sensorModel.stopFetchingSensorData()
            healthStore.pauseSession()
            healthStore.stopCalorieSession()
            healthStore.stopLiveCalorieUpdates()
            watchSession.sendFinalSessionCalories("\(self.caloriesBurned)")
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
