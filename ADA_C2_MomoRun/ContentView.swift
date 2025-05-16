//
//  ContentView.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene())
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
