//
//  GameOverWatchView.swift
//  ADA_C2_MomoRun
//
//  Created by Komang Wikananda on 22/05/25.
//

import SwiftUI


struct GameOverWatchView: View {
    
    var body: some View {
        ZStack {
            Image(.momoBG)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            VStack {
                Text("Game Over")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                
                Text("Score: 100")
            }
        }
    }
}

#Preview {
    GameOverWatchView()
}
