import SwiftUI
import HealthKit

struct ContentView: View {
    let animals = ["ネコ", "イヌ", "ハムスター", "ドラゴン", "ユニコーン"]
    let emojiAnimals = ["🐱", "🐶", "🐹", "🐲", "🦄"]
    
    var viewModel = AnimalListViewModel()
    let healthStore = HKHealthStore() // HealthKit instance
    @State private var timer: Timer? // ✅ Timer for interval-based sending

    var body: some View {
        List(0 ..< animals.count) { index in
            Button {
                self.sendLiveHealthData()
            } label: {
                HStack {
                    Text(self.emojiAnimals[index])
                        .font(.title)
                        .padding()
                    Text(self.animals[index])
                }
            }
        }
        .listStyle(CarouselListStyle())
        .navigationBarTitle(Text("Animal List"))
        .onAppear {
            requestHealthKitAuthorization()
            startLiveHeartRateMonitoring() // ✅ Start Live HR Monitoring
            startSendingDataAtIntervals()  // ✅ Start Timer
        }
        .onDisappear {
            stopSendingData() // ✅ Stop Timer to save resources
        }
    }
    
    // ✅ Start Timer to Send Data Every Second
    private func startSendingDataAtIntervals() {
        stopSendingData() // Ensure no duplicate timers

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.sendLiveHealthData()
        }
    }

    // ✅ Stop Timer When Not Needed
    private func stopSendingData() {
        timer?.invalidate()
        timer = nil
    }

    private func sendMessage(index: Int) {
        let messages: [String: Any] =
            ["animal": animals[index],
             "emoji": emojiAnimals[index]]
        self.viewModel.session.sendMessage(messages, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // ✅ Convert Heart Rate Samples to R-R Intervals
    private func computeRRIntervals(from samples: [HKQuantitySample]) -> [Double] {
        var rrIntervals: [Double] = []

        for i in 1..<samples.count {
            let timeDiff = samples[i].startDate.timeIntervalSince(samples[i-1].startDate)
            let heartRate = samples[i].quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            let rr = 60.0 / heartRate // Convert BPM to RR interval in seconds
            if timeDiff < 2.0 { // Ignore large gaps in data
                rrIntervals.append(rr * 1000) // Convert to milliseconds
            }
        }

        return rrIntervals
    }

    // ✅ Calculate RMSSD from RR Intervals (FIXED)
    private func calculateRMSSD(rrIntervals: [Double]) -> Double {
        guard rrIntervals.count > 1 else { return 0 }
        var squaredDiffs: [Double] = []
        
        for i in 1..<rrIntervals.count {
            let diff = rrIntervals[i] - rrIntervals[i-1]
            squaredDiffs.append(diff * diff)
        }
        
        let meanSquare = squaredDiffs.reduce(0, +) / Double(squaredDiffs.count)
        return sqrt(meanSquare)
    }

    private func sendLiveHealthData() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-300),
                                                    end: Date(),
                                                    options: .strictEndDate)
        
        let query = HKSampleQuery(sampleType: heartRateType,
                                  predicate: predicate,
                                  limit: 10,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], samples.count > 1 else {
                print("⚠️ No sufficient HR data available.")
                return
            }

            let rrIntervals = self.computeRRIntervals(from: samples)
            let rmssd = self.calculateRMSSD(rrIntervals: rrIntervals) // ✅ Fixed Call
            
            print("📤 Sending RMSSD Data: \(rmssd) ms")
            
            let healthData: [String: Any] = [
                "HRV_RMSSD": rmssd
            ]
            
            self.viewModel.session.sendMessage(healthData, replyHandler: nil) { (error) in
                print("❌ Failed to send RMSSD data: \(error.localizedDescription)")
            }
        }
        
        healthStore.execute(query)
    }

    // ✅ Request HealthKit Authorization
    private func requestHealthKitAuthorization() {
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("✅ HealthKit authorization granted.")
            } else {
                print("❌ HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // ✅ Live Heart Rate Monitoring
    private func startLiveHeartRateMonitoring() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

        let query = HKAnchoredObjectQuery(type: heartRateType,
                                          predicate: nil,
                                          anchor: nil,
                                          limit: HKObjectQueryNoLimit) { query, samples, deletedObjects, newAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            let latestHeartRate = samples.last?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            print("❤️ Live Heart Rate: \(latestHeartRate ?? 0) BPM")
        }

        query.updateHandler = { query, samples, deletedObjects, newAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            let latestHeartRate = samples.last?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            print("🔥 Updated Live HR: \(latestHeartRate ?? 0) BPM")
        }

        healthStore.execute(query)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
