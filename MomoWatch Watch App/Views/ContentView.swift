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
        }
    }
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    @StateObject private var sensorModel = SensorModel()
    @State private var didPlayHaptic = false
    
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
            
            VStack(spacing: 20) {
                if watchSession.gameOver {
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
                        watchSession.gameOver = false
                        watchSession.status = ""
                        didPlayHaptic = false
                        sensorModel.startFetchingSensorData()
                        if WCSession.default.isReachable {
                            WCSession.default.sendMessage(["restart": true], replyHandler: nil)
                        }
                    }) {
                        Image(.retryBtn)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 150)
//                    .font(.headline)
//                    .padding()
//                    .background(Color.green.opacity(0.8))
//                    .background(
//                        Image(.retryBtn)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                    )
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
                } else {
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
                    Button(action: { if sensorModel.isFetching {
                        sensorModel.stopFetchingSensorData()
                    } else {
                        sensorModel.startFetchingSensorData()
                        self.caloriesBurned = 0.0 // Reset calorie every start a new fetch
                        self.heartRate = 0 // Reset heart rate every start a new fetch
                        
                        if Config.getHealthStoreData {
                            Task {
                                await healthStore.requestHealthData()
                                healthStore.fetchActiveEnergyBurned { calories in
                                    self.caloriesBurned = calories
                                }
                                healthStore.fetchHeartRateLive { rate in
                                    self.heartRate = Int(rate)
                                }
                            }
                        }
                    }
                    }) {
                        Text(sensorModel.isFetching ? "Stop Fetching" : "Start Fetching")
                    }
                    .tint(sensorModel.isFetching ? .red : .white)
                }
                Text(watchSession.status)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            .padding()
            .onChange(of: sensorModel.directionX) {
                if !sensorModel.directionX.isEmpty {
                    sendDirection(sensorModel.directionX)
                }
            }
            .onChange(of: sensorModel.directionZ, { 
            if !sensorModel.directionZ.isEmpty {
                sendDirection(sensorModel.directionZ)
            }
        })
        .onChange(of: watchSession.gameOver) { newValue in
                if newValue {
                    if !didPlayHaptic {
                        WKInterfaceDevice.current().play(.failure)
                        didPlayHaptic = true
                    }
                    sensorModel.stopFetchingSensorData()
                }
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
