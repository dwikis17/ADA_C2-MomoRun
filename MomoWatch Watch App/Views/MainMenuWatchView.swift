//
//  MainMenuWatchView.swift
//  MomoWatch Watch App
//
//  Created by Rafie Amandio on 28/05/25.
//

import SwiftUI
import WatchConnectivity

struct MainMenuWatchView: View {
    @ObservedObject var sensorModel: SensorModel
    @Binding var gameStarted: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // SET GOAL Button
            Button(action: {
                // Send message to phone to go to calorie setup
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(["goToCalorieSetup": true], replyHandler: nil)
                }
            }) {
                Image("set-goal-button")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
            }
            .buttonStyle(.plain)
            
            // PLAY Button
            Button(action: {
                // Send start game message to phone
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(["start": true], replyHandler: nil)
                    gameStarted = true
                    sensorModel.startFetchingSensorData()
                }
            }) {
                Image("play-button")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MainMenuWatchView(
        sensorModel: SensorModel(),
        gameStarted: .constant(false)
    )
} 