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
    @State private var showingSplash = false
    
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
                Circle()
                    .fill(watchSession.isReachable ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                // Splash Screen
                SplashScreenView()
            }
        }
        .onAppear {
            // Hide splash screen after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showingSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
