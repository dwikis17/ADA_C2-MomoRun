//
//  CalorieSetupWatchView.swift
//  MomoWatch Watch App
//
//  Created by Rafie Amandio on 28/05/25.
//

import SwiftUI

struct CalorieSetupWatchView: View {
    @ObservedObject var watchSession: WatchSessionManager
    @State private var localCalorieValue: Double = 500.0 // Only for digital crown binding
    
    var body: some View {
        VStack(spacing: 15) {
            // Top calorie board
            ZStack {
                Image("calorie-board")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
                
                VStack(spacing: 2) {
                    Text("\(watchSession.currentCalorieValue)")
                        .font(.custom("Jersey15-Regular", size: 28))
                        .foregroundColor(Color(red: 71/255.0, green: 23/255.0, blue: 21/255.0))
                        .fontWeight(.bold)
                    
                    Text("KCAL")
                        .font(.custom("Jersey15-Regular", size: 16))
                        .foregroundColor(Color(red: 71/255.0, green: 23/255.0, blue: 21/255.0))
                }
            }
            .focusable(true)
            .digitalCrownRotation(
                $localCalorieValue,
                from: 0.0,
                through: 5000.0,
                by: 50.0,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: localCalorieValue) { oldValue, newValue in
                // Send direction command instead of actual value
                if newValue > oldValue {
                    watchSession.sendCalorieDirection("up")
                } else if newValue < oldValue {
                    watchSession.sendCalorieDirection("down")
                }
            }
            .onChange(of: watchSession.currentCalorieValue) { oldValue, newValue in
                // Update local value when phone value changes
                localCalorieValue = Double(newValue)
            }
            
            // DONE button using play-button asset
            Button(action: {
                watchSession.sendCalorieDone()
            }) {
                ZStack {
                    Image("play-button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 50)
                    
                    Text("DONE")
                        .font(.custom("Jersey15-Regular", size: 14))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .buttonStyle(.plain)
        }
        .onAppear {
            // Sync local value with watch session value when view appears
            localCalorieValue = Double(watchSession.currentCalorieValue)
        }
    }
}

#Preview {
    CalorieSetupWatchView(watchSession: WatchSessionManager())
} 