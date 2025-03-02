//
//  MessageListViewModel.swift
//  WatchConnectivitySampleForSwiftUI
//

import SwiftUI
import WatchConnectivity

final class MessageListViewModel: NSObject, ObservableObject {
    @Published var latestRMSSD: String = "No RMSSD Data"
    @Published var latestHRV: String = "No HRV Data"
    @Published var stressLevel: String = "Unknown" // ✅ New: Store stress level
    @Published var messages: [String] = []
    @Published var messagesData: [AnimalModel] = []

    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
}

extension MessageListViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("✅ The session has completed activation.")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("📥 Received Message:", message)

            if let rmssd = message["HRV_RMSSD"] as? Double {
                let formattedRMSSD = "RMSSD: \(String(format: "%.2f", rmssd)) ms"
                print("💓 Received RMSSD Data:", formattedRMSSD)
                self.latestRMSSD = formattedRMSSD

                // ✅ Calculate Stress Level
                let stress = self.calculateStressLevel(rmssd: rmssd)
                self.stressLevel = "Stress Level: \(stress)/100"
                print("⚠️ Calculated Stress Level:", stress)

                self.objectWillChange.send() // ✅ Ensure UI updates
            }

            if let hrvSDNN = message["HRV_SDNN"] as? Double {
                let formattedHRV = "HRV: \(String(format: "%.2f", hrvSDNN)) ms"
                print("💓 Received HRV SDNN Data:", formattedHRV)
                self.latestHRV = formattedHRV
                self.objectWillChange.send() // ✅ Ensure UI updates
            }
        }
    }

    // ✅ New: Convert RMSSD to Stress Level (0-100)
    private func calculateStressLevel(rmssd: Double) -> Int {
        let stressScore = max(0, min(100, 100 - Int(rmssd * 2))) // Normalize RMSSD into stress score
        return stressScore
    }
}
