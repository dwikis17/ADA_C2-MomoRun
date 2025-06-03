//
//  GameWatchView.swift
//  MomoWatch Watch App
//
//  Created by Rafie Amandio on 28/05/25.
//

import SwiftUI

struct GameWatchView: View {
    @ObservedObject var sensorModel: SensorModel
    @ObservedObject var healthStore: HealthStore
    @Binding var caloriesBurned: Double
    @Binding var heartRate: Int
    var startSensorFunc: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Health stats display
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "flame.fill")
                    Text("\(caloriesBurned, specifier: "%.1f") kcal")
                }
                HStack {
                    Image(systemName: "heart.fill")
                    Text("\(heartRate)")
                }
            }
            
            // Motion controls section
            Button(action: { 
                if sensorModel.isFetching {
                    sensorModel.stopFetchingSensorData()
                    healthStore.stopWorkout()
                } else {
                    sensorModel.startFetchingSensorData()
                    healthStore.startWorkout()
                    caloriesBurned = 0.0 // Reset calorie every start a new fetch
                    heartRate = 0 // Reset heart rate every start a new fetch
                    
                    if Config.getHealthStoreData {
                        Task {
                            await healthStore.requestHealthData()
                            healthStore.fetchActiveEnergyBurned { calories in
                                caloriesBurned = calories
                            }
                            healthStore.fetchHeartRateLive { rate in
                                heartRate = Int(rate)
                            }
                        }
                    }
                }
            }) {
                Text(sensorModel.isFetching ? "Stop Controls" : "Start Controls")
            }
            .tint(sensorModel.isFetching ? .red : .white)
            
            if sensorModel.isFetching {
                Text("Motion tracking active")
                    .font(.footnote)
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    GameWatchView(
        sensorModel: SensorModel(),
        healthStore: HealthStore(),
        caloriesBurned: .constant(0.0),
        heartRate: .constant(0),
        startSensorFunc: {},
    )
} 
