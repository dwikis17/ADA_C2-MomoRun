//
//  ContentView.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import SwiftUI
import SpriteKit
import WatchConnectivity
// Removed import UIKit


struct ContentView: View {
    // Instantiate the WatchSessionManager from the utility file
    @StateObject private var watchSession = WatchSessionManager()
    
    // GameSceneLab will be instantiated when the Play button is tapped
    // private var gameScene = GameSceneLab()

    var body: some View {
        ZStack { // Use ZStack to layer SpriteView and the indicator
            // Present the MainMenuScene first, passing the watchSession
            GeometryReader { geometry in
                SpriteView(scene: MainMenuScene(size: geometry.size, watchSession: watchSession))
                    .ignoresSafeArea()
            }
            
            // MARK: - Watch Connection Status Indicator (SwiftUI)
            Circle()
                .fill(watchSession.isReachable ? Color.green : Color.red)
                .frame(width: 20, height: 20) // Size of the circle
                .padding(.top, 20) // Padding from the top
                .padding(.leading, 20) // Padding from the left
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Position in top left
        }
        // Removed .onAppear and .onDisappear related to idle timer
        // Removed watch session handlers from here as they belong in the game scene or a manager
    }
}

#Preview {
    ContentView()
}
