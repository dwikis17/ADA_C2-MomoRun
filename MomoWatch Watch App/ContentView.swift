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
    @State private var tapIndex: Int = 1
    var body: some View {
        VStack {
            Button(action: {
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(["info": "Tap #\(tapIndex)"], replyHandler: nil, errorHandler: { error in
                        DispatchQueue.main.async {
                            watchSession.status = "Failed: \(error.localizedDescription)"
                        }
                    })
                    watchSession.status = "Sent!"
                    tapIndex += 1
                } else {
                    watchSession.status = "Not reachable"
                }
            }) {
                VStack {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.tint)
                    Text("Tap #\(tapIndex)")
                        .font(.headline)
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)
            Text(watchSession.status)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
