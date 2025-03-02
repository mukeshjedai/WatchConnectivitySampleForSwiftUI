import HealthKit

class HealthManager: ObservableObject {
    private var healthStore = HKHealthStore()
    
    @Published var steps: Int = 0
    @Published var calories: Double = 0.0
    @Published var exerciseTime: Double = 0.0

    // Request permission to access HealthKit data
    func requestHealthKitAccess() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

        let allTypes: Set = [stepType, calorieType, exerciseType]

        healthStore.requestAuthorization(toShare: [], read: allTypes) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.fetchTodaySteps()
                    self.fetchTodayCalories()
                    self.fetchTodayExerciseTime()
                }
            } else {
                print("HealthKit Permission Denied: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    // Fetch today's step count
    func fetchTodaySteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let todayPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: todayPredicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            
            DispatchQueue.main.async {
                self.steps = stepCount
            }
        }
        healthStore.execute(query)
    }

    // Fetch today's calories burned
    func fetchTodayCalories() {
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let todayPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: todayPredicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())

            DispatchQueue.main.async {
                self.calories = caloriesBurned
            }
        }
        healthStore.execute(query)
    }

    // Fetch today's exercise time
    func fetchTodayExerciseTime() {
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let todayPredicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: Date()),
            end: Date(),
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: todayPredicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            let minutes = sum.doubleValue(for: HKUnit.minute())

            DispatchQueue.main.async {
                self.exerciseTime = minutes
            }
        }
        healthStore.execute(query)
    }
}
