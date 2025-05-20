//
//  ContentView.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import SwiftUI
import SpriteKit
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedMessage: String = ""
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let info = message["info"] as? String {
                self.receivedMessage = info
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    var body: some View {
        VStack {
            if !watchSession.receivedMessage.isEmpty {
                Text("From Watch: \(watchSession.receivedMessage)")
                    .font(.headline)
                    .padding(.top)
            }
            SpriteView(scene: GameScene())
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
