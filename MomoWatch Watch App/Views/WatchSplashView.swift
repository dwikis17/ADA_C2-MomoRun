//
//  WatchSplashView.swift
//  MomoWatch Watch App
//
//  Created by Rafie Amandio on 28/05/25.
//

import SwiftUI

struct WatchSplashView: View {
    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.8
    @State private var glowOpacity: Double = 0.0
    @State private var showMainContent = false
    
    var body: some View {
        if showMainContent {
            ContentView()
        } else {
            GeometryReader { geometry in
                ZStack {
                    // Pure black background
                    Color.black
                        .ignoresSafeArea()
                    
                    // Particle effects
                    ZStack {
                        ForEach(0..<12, id: \.self) { i in
                            WatchParticleView(
                                geometry: geometry,
                                index: i
                            )
                        }
                    }
                    
                    // Centered logo with elegant animations
                    ZStack {
                        // Subtle glow effect
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .blur(radius: 10)
                            .opacity(glowOpacity * 0.4)
                            .scaleEffect(logoScale * 1.15)
                        
                        // Main logo
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    }
                }
                .onAppear {
                    // Elegant entrance sequence
                    
                    // 1. Fade in with gentle scale
                    withAnimation(.easeOut(duration: 1.2)) {
                        logoOpacity = 1.0
                        logoScale = 1.0
                    }
                    
                    // 2. Start subtle glow after fade in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            glowOpacity = 1.0
                        }
                    }
                    
                    // 3. Gentle breathing animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                            logoScale = 1.05
                        }
                    }
                    
                    // 4. Transition to main content
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            showMainContent = true
                        }
                    }
                }
            }
        }
    }
}

struct WatchParticleView: View {
    let geometry: GeometryProxy
    let index: Int
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5
    @State private var xPosition: CGFloat = 0
    @State private var yPosition: CGFloat = 0
    
    private let size: CGFloat
    private let animationDuration: Double
    private let initialDelay: Double
    
    init(geometry: GeometryProxy, index: Int) {
        self.geometry = geometry
        self.index = index
        self.size = CGFloat.random(in: 1...3) // Smaller for watch screen
        self.animationDuration = Double.random(in: 6...10)
        self.initialDelay = Double.random(in: 0...2)
    }
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.2))
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(x: xPosition, y: yPosition)
            .onAppear {
                // Set initial random position
                xPosition = CGFloat.random(in: 0...geometry.size.width)
                yPosition = CGFloat.random(in: 0...geometry.size.height)
                
                // Start continuous animations with initial delay
                DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
                    startContinuousAnimations()
                }
            }
    }
    
    private func startContinuousAnimations() {
        // Scale animation
        withAnimation(
            Animation.easeInOut(duration: animationDuration)
                .repeatForever(autoreverses: true)
        ) {
            scale = CGFloat.random(in: 0.8...1.2)
        }
        
        // Opacity animation
        withAnimation(
            Animation.easeInOut(duration: animationDuration * 0.8)
                .repeatForever(autoreverses: true)
        ) {
            opacity = Double.random(in: 0.3...1.0)
        }
        
        // Position animation (slow drift)
        withAnimation(
            Animation.linear(duration: animationDuration * 2)
                .repeatForever(autoreverses: true)
        ) {
            xPosition = CGFloat.random(in: 0...geometry.size.width)
            yPosition = CGFloat.random(in: 0...geometry.size.height)
        }
    }
}

#Preview {
    WatchSplashView()
} 

