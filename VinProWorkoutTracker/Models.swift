import Foundation
import SwiftData

@Model
class SetEntry {
    var exerciseName: String = ""
    var weight: Double = 0
    var reps: Int = 0
    var timestamp: Date = Date()
    var isOneRepMax: Bool = false  // Flag for actual 1RM tests
    
    // ✅ INVERSE RELATIONSHIP: Required for CloudKit sync
    var workout: Workout?

    init(
        exerciseName: String,
        weight: Double,
        reps: Int,
        timestamp: Date = Date(),
        isOneRepMax: Bool = false
    ) {
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.timestamp = timestamp
        self.isOneRepMax = isOneRepMax
    }
    
    /// Calculate the volume (weight × reps) for this set
    var volume: Double {
        weight * Double(reps)
    }
}

@Model
class Workout {
    var date: Date = Date()
    var name: String = ""

    // Status flags
    var isCompleted: Bool = false
    var isArchived: Bool = false

    // Durations
    var warmupMinutes: Int = 0
    var coreMinutes: Int = 0
    var stretchMinutes: Int = 0

    // Plan
    var mainExercises: [String] = []
    var coreExercises: [String] = []
    var stretches: [String] = []
    
    // Notes (for links, thoughts, etc.)
    var notes: String = ""

    // Logged sets - ✅ MADE OPTIONAL for CloudKit, INVERSE relationship with SetEntry
    @Relationship(deleteRule: .cascade, inverse: \SetEntry.workout)
    var sets: [SetEntry]?

    init(
        date: Date = Date(),
        name: String,
        warmupMinutes: Int = 0,
        coreMinutes: Int = 0,
        stretchMinutes: Int = 0,
        mainExercises: [String] = [],
        coreExercises: [String] = [],
        stretches: [String] = [],
        notes: String = "",
        sets: [SetEntry] = []
    ) {
        self.date = date
        self.name = name
        self.warmupMinutes = warmupMinutes
        self.coreMinutes = coreMinutes
        self.stretchMinutes = stretchMinutes
        self.mainExercises = mainExercises
        self.coreExercises = coreExercises
        self.stretches = stretches
        self.notes = notes
        self.sets = sets.isEmpty ? nil : sets
    }

    var totalVolume: Double {
        sets?.reduce(0) { $0 + ($1.weight * Double($1.reps)) } ?? 0
    }
}
@Model
class CustomWorkoutTemplate {
    var name: String = ""
    var dayOfWeek: String? = nil // Optional: "Monday", "Tuesday", etc., or nil
    var createdDate: Date = Date()
    
    // Template structure (same as Workout)
    var warmupMinutes: Int = 5
    var coreMinutes: Int = 5
    var stretchMinutes: Int = 5
    var mainExercises: [String] = []
    var coreExercises: [String] = []
    var stretches: [String] = []
    
    init(
        name: String,
        dayOfWeek: String? = nil,
        warmupMinutes: Int = 5,
        coreMinutes: Int = 5,
        stretchMinutes: Int = 5,
        mainExercises: [String] = [],
        coreExercises: [String] = [],
        stretches: [String] = []
    ) {
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.createdDate = Date()
        self.warmupMinutes = warmupMinutes
        self.coreMinutes = coreMinutes
        self.stretchMinutes = stretchMinutes
        self.mainExercises = mainExercises
        self.coreExercises = coreExercises
        self.stretches = stretches
    }
    
    /// Convert this template into a new Workout instance
    func toWorkout() -> Workout {
        return Workout(
            date: Date(),
            name: self.name,
            warmupMinutes: self.warmupMinutes,
            coreMinutes: self.coreMinutes,
            stretchMinutes: self.stretchMinutes,
            mainExercises: self.mainExercises,
            coreExercises: self.coreExercises,
            stretches: self.stretches
        )
    }
}

