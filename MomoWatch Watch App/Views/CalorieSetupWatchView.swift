//
//  CalorieSetupWatchView.swift
//  MomoWatch Watch App
//
//  Created by Assistant on Date.
//

import SwiftUI

struct CalorieSetupWatchView: View {
    @ObservedObject var watchSession: WatchSessionManager
    @State private var calorieValue: Double = 500.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                // Top calorie board
                ZStack {
                    Image("calorie-board")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                    
                    VStack(spacing : 1){
                        HStack(spacing: 10) {
                            Text("\(Int(calorieValue))")
                                .font(.custom("Jersey15-Regular", size: 48))
                                .foregroundColor(Color(red: 71/255.0, green: 23/255.0, blue: 21/255.0))
                                .fontWeight(.bold)
                            
                            Text("KCAL")
                                .font(.custom("Jersey15-Regular", size: 32))
                                .foregroundColor(Color(red: 71/255.0, green: 23/255.0, blue: 21/255.0))
                        }
                        
                        Rectangle()
                            .frame(width: 130, height: 2)
                            .foregroundColor(Color(red: 71/255.0, green: 23/255.0, blue: 21/255.0))
                    }
                    
                }
                .focusable(true)
                .digitalCrownRotation(
                    $calorieValue,
                    from: 0.0,
                    through: 5000.0,
                    by: 50.0,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: calorieValue) { oldValue, newValue in
                    // Send direction command instead of actual value
                    if newValue > oldValue {
                        watchSession.sendCalorieDirection("up")
                    } else if newValue < oldValue {
                        watchSession.sendCalorieDirection("down")
                    }
                }
                
                // DONE button using play-button asset
                Button(action: {
                    watchSession.sendCalorieDone()
                }) {
                    ZStack {
                        Image("done-button")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 87)
                    }
                }
                .buttonStyle(.plain)
            }
            .onAppear {
                // Initialize to 500 when view appears
                calorieValue = 500.0
            }
        }
        
    }
}

#Preview {
    CalorieSetupWatchView(watchSession: WatchSessionManager())
} 
