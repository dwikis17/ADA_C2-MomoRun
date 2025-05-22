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
        // Present the MainMenuScene first, passing the watchSession
        GeometryReader { geometry in

            SpriteView(scene: MainMenuScene(size: geometry.size, watchSession: watchSession))
                .ignoresSafeArea()
        }
        // Removed .onAppear and .onDisappear related to idle timer
        // Removed watch session handlers from here as they belong in the game scene or a manager
    }
}

#Preview {
    ContentView()
}
