//
//  ContentView.swift
//  MomoWatch Watch App
//
//  Created by Dwiki on 20/05/25.
//

import SwiftUI
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var status: String = ""
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}

struct ContentView: View {
    @StateObject private var watchSession = WatchSessionManager()
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                Button(action: {
                    sendDirection("left")
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
                Button(action: {
                    sendDirection("right")
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
            }
            Text(watchSession.status)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding()
    }

    private func sendDirection(_ direction: String) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["direction": direction], replyHandler: nil, errorHandler: { error in
                DispatchQueue.main.async {
                    watchSession.status = "Failed: \(error.localizedDescription)"
                }
            })
            watchSession.status = "Sent: \(direction.capitalized)"
        } else {
            watchSession.status = "Not reachable"
        }
    }
}

#Preview {
    ContentView()
}
