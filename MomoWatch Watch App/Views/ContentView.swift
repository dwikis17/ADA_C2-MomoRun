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
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    @StateObject private var sensorModel = SensorModel()
    @State private var didPlayHaptic = false
    @State private var gameStarted = false
    @State private var calorieValue: Double = 2000
    
    var body: some View {
        ZStack {
            Image(.momoBG)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Calorie setup view
            if watchSession.showCalorieSetup {
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
                        .onChange(of: calorieValue) { newValue in
                            // Send updated value to phone
                            watchSession.sendCalorieValue(Int(newValue))
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
            } 
            // Game over view
            else if watchSession.gameOver {
                Text("Game Over")
                    .font(.custom("Jersey15-Regular", size:40))
                    .foregroundColor(.red)
                    .padding()
                Button(action : {
                    watchSession.gameOver = false
                    watchSession.status = ""
                    didPlayHaptic = false
                    sensorModel.startFetchingSensorData()
                    if WCSession.default.isReachable {
                        WCSession.default.sendMessage(["restart": true], replyHandler: nil)
                        // Immediately start the game after retry
                        WCSession.default.sendMessage(["start": true], replyHandler: nil)
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
            // Start game view
            else if !gameStarted {
                // Start Game button when game hasn't started yet
                Text("MomoRun")
                    .font(.title3)
                    .padding(.bottom, 5)
                
                Button("Start Game") {
                    if WCSession.default.isReachable {
                        WCSession.default.sendMessage(["start": true], replyHandler: nil)
                        gameStarted = true
                        sensorModel.startFetchingSensorData()
                    }
                }
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
            } 
            // Game controls view
            else {
                // Motion controls section (only shown when game is started)
                Button(action: { 
                    if sensorModel.isFetching {
                        sensorModel.stopFetchingSensorData()
                    } else {
                        sensorModel.startFetchingSensorData()
                    }
                }) {
                    Text(sensorModel.isFetching ? "Stop Controls" : "Start Controls")
                }
                .tint(sensorModel.isFetching ? .red : .white)
                
                if sensorModel.isFetching {
                    Text("Motion tracking active")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
            }
            
            Text(watchSession.status)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding()
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
