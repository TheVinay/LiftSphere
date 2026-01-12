import Foundation
import HealthKit

@Observable
class HealthKitManager {
    private let healthStore = HKHealthStore()
    
    var isAuthorized = false
    
    // Body Composition
    var weight: Double?
    var height: Double?
    var bodyMassIndex: Double?
    var bodyFatPercentage: Double?
    var leanBodyMass: Double?
    
    // Advanced Body Composition (from smart scales)
    var boneMass: Double?
    var muscleMass: Double?
    var visceralFat: Double?
    
    // Metabolic
    var basalEnergyBurned: Double? // BMR
    var activeEnergyBurned: Double?
    
    // Activity
    var stepCount: Double?
    var distanceWalkingRunning: Double?
    var exerciseTime: Double?
    var standHours: Int?
    
    // Heart & Fitness
    var restingHeartRate: Double?
    var heartRateVariability: Double?
    var vo2Max: Double?
    
    // Sleep
    var sleepHours: Double?
    
    // Nutrition
    var dietaryProtein: Double?
    var dietaryCarbs: Double?
    var dietaryFat: Double?
    var dietaryCalories: Double?
    
    // Date of last update
    var lastUpdated: Date?
    
    // MARK: - Check Availability
    
    static var isHealthDataAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Check Authorization Status
    
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            return
        }
        
        // Check authorization status for multiple representative types
        // We check several common types to see if any are authorized
        let typesToCheck: [HKQuantityTypeIdentifier] = [
            .bodyMass,
            .stepCount,
            .activeEnergyBurned,
            .height
        ]
        
        for typeIdentifier in typesToCheck {
            let status = healthStore.authorizationStatus(for: HKQuantityType(typeIdentifier))
            if status == .sharingAuthorized {
                isAuthorized = true
                return
            }
        }
        
        // If none are explicitly authorized, assume not authorized
        isAuthorized = false
    }
    
    // MARK: - Request Authorization
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        let typesToRead: Set<HKObjectType> = [
            // Body Measurements
            HKQuantityType(.bodyMass),
            HKQuantityType(.height),
            HKQuantityType(.bodyMassIndex),
            HKQuantityType(.bodyFatPercentage),
            HKQuantityType(.leanBodyMass),
            
            // Advanced Body Composition
            HKQuantityType(.appleSleepingWristTemperature), // Available for other metrics
            
            // Metabolic
            HKQuantityType(.basalEnergyBurned),
            HKQuantityType(.activeEnergyBurned),
            
            // Activity
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.appleStandTime),
            
            // Heart & Fitness
            HKQuantityType(.restingHeartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.vo2Max),
            
            // Sleep
            HKCategoryType(.sleepAnalysis),
            
            // Nutrition
            HKQuantityType(.dietaryProtein),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.dietaryFatTotal),
            HKQuantityType(.dietaryEnergyConsumed),
        ]
        
        // Types to write (workouts and calories)
        let typesToWrite: Set<HKSampleType> = [
            HKWorkoutType.workoutType(),
            HKQuantityType(.activeEnergyBurned)
        ]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
        isAuthorized = true
    }
    
    // MARK: - Fetch All Health Data
    
    func fetchAllHealthData() async {
        guard isAuthorized else { return }
        
        async let weightTask = fetchMostRecent(.bodyMass, unit: .pound())
        async let heightTask = fetchMostRecent(.height, unit: .inch())
        async let bmiTask = fetchMostRecent(.bodyMassIndex, unit: .count())
        async let bodyFatTask = fetchMostRecent(.bodyFatPercentage, unit: .percent())
        async let leanBodyMassTask = fetchMostRecent(.leanBodyMass, unit: .pound())
        
        async let bmrTask = fetchToday(.basalEnergyBurned, unit: .kilocalorie())
        async let activeEnergyTask = fetchToday(.activeEnergyBurned, unit: .kilocalorie())
        
        async let stepsTask = fetchToday(.stepCount, unit: .count())
        async let distanceTask = fetchToday(.distanceWalkingRunning, unit: .mile())
        async let exerciseTask = fetchToday(.appleExerciseTime, unit: .minute())
        
        async let restingHRTask = fetchMostRecent(.restingHeartRate, unit: .count().unitDivided(by: .minute()))
        async let hrvTask = fetchMostRecent(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli))
        async let vo2MaxTask = fetchMostRecent(.vo2Max, unit: HKUnit.literUnit(with: .milli).unitDivided(by: .gramUnit(with: .kilo).unitMultiplied(by: .minute())))
        
        async let sleepTask = fetchSleepHours()
        
        async let proteinTask = fetchToday(.dietaryProtein, unit: .gram())
        async let carbsTask = fetchToday(.dietaryCarbohydrates, unit: .gram())
        async let fatTask = fetchToday(.dietaryFatTotal, unit: .gram())
        async let caloriesTask = fetchToday(.dietaryEnergyConsumed, unit: .kilocalorie())
        
        // Await all results
        weight = await weightTask
        height = await heightTask
        bodyMassIndex = await bmiTask
        bodyFatPercentage = await bodyFatTask
        leanBodyMass = await leanBodyMassTask
        
        basalEnergyBurned = await bmrTask
        activeEnergyBurned = await activeEnergyTask
        
        stepCount = await stepsTask
        distanceWalkingRunning = await distanceTask
        exerciseTime = await exerciseTask
        
        restingHeartRate = await restingHRTask
        heartRateVariability = await hrvTask
        vo2Max = await vo2MaxTask
        
        sleepHours = await sleepTask
        
        dietaryProtein = await proteinTask
        dietaryCarbs = await carbsTask
        dietaryFat = await fatTask
        dietaryCalories = await caloriesTask
        
        // Calculate derived metrics
        calculateDerivedMetrics()
        
        lastUpdated = Date()
    }
    
    // MARK: - Fetch Most Recent Value
    
    private func fetchMostRecent(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        let quantityType = HKQuantityType(identifier)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Fetch Today's Cumulative Value
    
    private func fetchToday(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        let quantityType = HKQuantityType(identifier)
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                guard let sum = statistics?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let value = sum.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Fetch Sleep Hours
    
    private func fetchSleepHours() async -> Double? {
        let sleepType = HKCategoryType(.sleepAnalysis)
        
        let calendar = Calendar.current
        let now = Date()
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Calculate total sleep time in hours
                var totalSleep: TimeInterval = 0
                for sample in samples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                        totalSleep += sample.endDate.timeIntervalSince(sample.startDate)
                    }
                }
                
                let hours = totalSleep / 3600.0
                continuation.resume(returning: hours > 0 ? hours : nil)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Calculate Derived Metrics
    
    private func calculateDerivedMetrics() {
        // Calculate BMI if not available but we have weight and height
        if bodyMassIndex == nil, let weight = weight, let height = height, height > 0 {
            // BMI = weight (kg) / height (m)²
            let weightKg = weight * 0.453592 // pounds to kg
            let heightM = height * 0.0254 // inches to meters
            bodyMassIndex = weightKg / (heightM * heightM)
        }
        
        // Calculate muscle mass from lean body mass (approximation)
        if muscleMass == nil, let leanMass = leanBodyMass {
            // Muscle mass is roughly 50-60% of lean body mass
            muscleMass = leanMass * 0.55
        }
        
        // Calculate bone mass (approximation - typically 15-20% of lean mass)
        if boneMass == nil, let leanMass = leanBodyMass {
            boneMass = leanMass * 0.17
        }
    }
    
    // MARK: - Formatted Strings
    
    func formattedWeight() -> String? {
        guard let weight = weight else { return nil }
        return String(format: "%.1f lbs", weight)
    }
    
    func formattedHeight() -> String? {
        guard let height = height else { return nil }
        let feet = Int(height / 12)
        let inches = Int(height.truncatingRemainder(dividingBy: 12))
        return "\(feet)' \(inches)\""
    }
    
    func formattedBMI() -> String? {
        guard let bmi = bodyMassIndex else { return nil }
        return String(format: "%.1f", bmi)
    }
    
    func formattedBodyFat() -> String? {
        guard let bodyFat = bodyFatPercentage else { return nil }
        return String(format: "%.1f%%", bodyFat * 100)
    }
    
    func formattedLeanBodyMass() -> String? {
        guard let leanMass = leanBodyMass else { return nil }
        return String(format: "%.1f lbs", leanMass)
    }
    
    func formattedMuscleMass() -> String? {
        guard let muscle = muscleMass else { return nil }
        return String(format: "%.1f lbs", muscle)
    }
    
    func formattedBoneMass() -> String? {
        guard let bone = boneMass else { return nil }
        return String(format: "%.1f lbs", bone)
    }
    
    func formattedBMR() -> String? {
        guard let bmr = basalEnergyBurned else { return nil }
        return String(format: "%.0f kcal", bmr)
    }
    
    func formattedSteps() -> String? {
        guard let steps = stepCount else { return nil }
        return String(format: "%.0f", steps)
    }
    
    func formattedProtein() -> String? {
        guard let protein = dietaryProtein else { return nil }
        return String(format: "%.1f g", protein)
    }
    
    func bmiCategory() -> String? {
        guard let bmi = bodyMassIndex else { return nil }
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    // MARK: - Write Workout to Health
    
    /// Saves a completed workout to Apple Health
    func saveWorkout(
        name: String,
        startDate: Date,
        duration: TimeInterval,
        totalVolume: Double
    ) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        // Calculate estimated calories burned
        // Conservative estimate: 0.04 calories per kg of volume lifted
        let estimatedCalories = totalVolume * 0.04
        
        let endDate = startDate.addingTimeInterval(duration)
        
        // Create workout builder configuration
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .traditionalStrengthTraining
        workoutConfiguration.locationType = .indoor
        
        // Create workout builder
        let builder = HKWorkoutBuilder(
            healthStore: healthStore,
            configuration: workoutConfiguration,
            device: .local()
        )
        
        // Begin workout session
        try await builder.beginCollection(at: startDate)
        
        // Add energy burned sample
        let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: estimatedCalories)
        let energySample = HKQuantitySample(
            type: HKQuantityType(.activeEnergyBurned),
            quantity: energyQuantity,
            start: startDate,
            end: endDate
        )
        try await builder.addSamples([energySample])
        
        // Add metadata
        try await builder.addMetadata([
            HKMetadataKeyIndoorWorkout: true,
            "WorkoutName": name
        ])
        
        // End collection and finish workout
        try await builder.endCollection(at: endDate)
        try await builder.finishWorkout()
    }
}

// MARK: - Errors

enum HealthKitError: Error {
    case notAvailable
    case notAuthorized
    case noData
}

extension HealthKitError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .noData:
            return "No health data available"
        }
    }
}
