//
//  CalorieTargetSetupView.swift
//  MomoRun
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct CalorieTargetSetupView: View {
    @AppStorage("hasSetCalorieTarget") private var hasSetCalorieTarget: Bool = false
    @AppStorage("dailyCalorieTarget") private var dailyCalorieTarget: Double = 2000 // Default value

    @State private var selectedCalories: Double = 2000 // Initial value for the slider

    // A binding to dismiss this view, controlled by the parent (ContentView)
    @Binding var showSetup: Bool

    var body: some View {
        VStack {
            Spacer()

            Text("Set Your Daily Calorie Target")
                .font(.title)
                .padding()

            Slider(value: $selectedCalories, in: 1000...4000, step: 50) { // Adjust range and step as needed
                Text("Calories") // Accessibility label
            }
            .padding()

            Text("Target: \(Int(selectedCalories)) Calories")
                .font(.headline)

            Button("Save Target") {
                dailyCalorieTarget = selectedCalories
                hasSetCalorieTarget = true
                showSetup = false // Dismiss the setup view
            }
            .padding()
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .background(Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea())
        .foregroundColor(.white)
    }
}

#Preview {
    // Preview requires a binding, so we create a dummy one
    CalorieTargetSetupView(showSetup: .constant(true))
} 