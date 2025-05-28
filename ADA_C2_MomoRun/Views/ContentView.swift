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
    
    // Add state to control splash screen visibility
    @State private var showingSplash = Config.showSplashScreen
    @State private var showingBlackTransition = false
    
    // GameSceneLab will be instantiated when the Play button is tapped
    // private var gameScene = GameSceneLab()

    var body: some View {
        
        
        ZStack {
            // Main content
            if !showingSplash {
               GeometryReader { geometry in
                   SpriteView(scene: MainMenuScene(size: geometry.size, watchSession: watchSession))
                       .ignoresSafeArea()
               }
                // Watch Connection Status Indicator (SwiftUI)
            } else {
                // Splash Screen
                SplashScreenView()
            }
            
            // Black transition overlay
            if showingBlackTransition {
                Color.black
                    .ignoresSafeArea()
                    .zIndex(1000)
            }
        }
        .onAppear {
            // Start transition sequence after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                startFadeToBlackTransition()
            }
        }
    }
    
    private func startFadeToBlackTransition() {
        // Step 1: Fade to black
        withAnimation(.easeInOut(duration: 0.5)) {
            showingBlackTransition = true
        }
        
        // Step 2: After black screen is shown, hide splash and show main menu
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingSplash = false
            
            // Step 3: Fade out from black to reveal main menu
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showingBlackTransition = false
                }
            }
        }
    }
    
    private func createMainMenuScene() -> MainMenuScene {
        let scene = MainMenuScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), watchSession: watchSession)
        scene.scaleMode = .aspectFill
        return scene
    }
}

#Preview {
    ContentView()
}
