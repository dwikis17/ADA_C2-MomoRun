//
//  GameOverWatchView.swift
//  MomoWatch Watch App
//
//  Created by Komang Wikananda on 22/05/25.
//

import SwiftUI
import WatchConnectivity

struct GameOverWatchView: View {
    @ObservedObject var watchSession: WatchSessionManager
    @ObservedObject var sensorModel: SensorModel
    @Binding var didPlayHaptic: Bool
    @Binding var gameStarted: Bool
    let caloriesBurned: Double
    let heartRate: Int
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Game Over")
                .font(.custom("Jersey15-Regular", size: 40))
                .foregroundColor(.red)
                .padding()
            
            HStack(spacing: 30) {
                HStack {
                    Image(systemName: "flame.fill")
                    Text("\(caloriesBurned, specifier: "%.1f") kcal")
                }
                HStack {
                    Image(systemName: "heart.fill")
                    Text("\(heartRate)")
                }
            }
            
            Button(action: {
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
    }
}

#Preview {
    GameOverWatchView(
        watchSession: WatchSessionManager(),
        sensorModel: SensorModel(),
        didPlayHaptic: .constant(false),
        gameStarted: .constant(false),
        caloriesBurned: 125.5,
        heartRate: 85
    )
}
