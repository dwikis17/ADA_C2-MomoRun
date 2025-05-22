//
//  SplashScreenView.swift
//  ADA_C2_MomoRun
//
//  Created by Rafie Amandio on 22/05/25.
//

import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: phase - 0.2),
                            .init(color: .white.opacity(0.7), location: phase),
                            .init(color: .clear, location: phase + 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(content)
                    .blendMode(.overlay)
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerEffect())
    }
}

struct SplashScreenView: View {
    @State private var animate = false
    @State private var opacity = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                // Subtle particle effect
                ZStack {
                    ForEach(0..<20) { i in
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: CGFloat.random(in: 2...6))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .scaleEffect(animate ? CGFloat.random(in: 0.8...1.2) : 1)
                            .opacity(animate ? CGFloat.random(in: 0.5...1.0) : 0)
                            .animation(
                                Animation.easeInOut(duration: CGFloat.random(in: 2...4))
                                    .repeatForever()
                                    .delay(CGFloat.random(in: 0...2)),
                                value: animate
                            )
                    }
                }
                
                HStack(spacing: 70) {
                    // Apple Watch icon with breathing animation
                    Image(systemName: "applewatch.watchface")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 10)
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: animate
                        )
                    
                    // Text with shimmering effect
                    VStack(alignment: .center, spacing: 10) {
                        Text("USE YOUR")
                            .font(.custom("Jersey15-Regular", size: 45))
                            .foregroundColor(.white)
                            .shimmering()
                        
                        Text("APPLE WATCH")
                            .font(.custom("Jersey15-Regular", size: 45))
                            .foregroundColor(.white)
                            .shimmering()
                            
                        Text("TO PLAY")
                            .font(.custom("Jersey15-Regular", size: 45))
                            .foregroundColor(.white)
                            .shimmering()
                    }
                }
                .opacity(opacity)
            }
            .onAppear {
                // Start animations when view appears
                animate = true
                
                // Fade in content
                withAnimation(.easeIn(duration: 1.5)) {
                    opacity = 1.0
                }
            }
            .statusBar(hidden: true)
            .preferredColorScheme(.dark)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SplashScreenView()
        .previewInterfaceOrientation(.landscapeRight)
} 
