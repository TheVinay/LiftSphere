import Foundation
import SwiftData

@Model
class SetEntry {
    var exerciseName: String
    var weight: Double
    var reps: Int
    var timestamp: Date

    init(
        exerciseName: String,
        weight: Double,
        reps: Int,
        timestamp: Date = Date()
    ) {
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.timestamp = timestamp
    }
}

@Model
class Workout {
    var date: Date
    var name: String

    // Status flags
    var isCompleted: Bool = false
    var isArchived: Bool = false   // 👈 NEW

    // Durations
    var warmupMinutes: Int
    var coreMinutes: Int
    var stretchMinutes: Int

    // Plan
    var mainExercises: [String]
    var coreExercises: [String]
    var stretches: [String]

    // Logged sets
    @Relationship(deleteRule: .cascade)
    var sets: [SetEntry]

    init(
        date: Date = Date(),
        name: String,
        warmupMinutes: Int = 0,
        coreMinutes: Int = 0,
        stretchMinutes: Int = 0,
        mainExercises: [String] = [],
        coreExercises: [String] = [],
        stretches: [String] = [],
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
        self.sets = sets
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}
