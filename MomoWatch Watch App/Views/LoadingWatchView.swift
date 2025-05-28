//
//  LoadingWatchView.swift
//  MomoWatch Watch App
//
//  Created by Assistant on Date.
//

import SwiftUI

struct LoadingWatchView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Loading...")
                .font(.title2)
                .foregroundColor(.white)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

#Preview {
    LoadingWatchView()
} 