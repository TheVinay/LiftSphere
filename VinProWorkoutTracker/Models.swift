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

@Model
class CustomExercise {
    // Core properties
    var name: String = ""
    var primaryMuscleRaw: String = "" // Store MuscleGroup.rawValue
    var secondaryMuscleRaw: String? = nil
    var equipmentRaw: String = "" // Store Equipment.rawValue
    var isCalisthenic: Bool = false
    var lowBackSafe: Bool = true
    var machineName: String? = nil
    var info: String? = nil
    
    // Educational content
    var musclesDescription: String = ""
    var instructions: String? = nil // Stored as newline-separated string
    var formTips: String? = nil // Stored as newline-separated string
    
    // Metadata
    var createdDate: Date = Date()
    var isArchived: Bool = false
    
    // Computed properties for convenience
    var primaryMuscle: MuscleGroup {
        get { MuscleGroup(rawValue: primaryMuscleRaw) ?? .chest }
        set { primaryMuscleRaw = newValue.rawValue }
    }
    
    var secondaryMuscle: MuscleGroup? {
        get {
            guard let raw = secondaryMuscleRaw else { return nil }
            return MuscleGroup(rawValue: raw)
        }
        set { secondaryMuscleRaw = newValue?.rawValue }
    }
    
    var equipment: Equipment {
        get { Equipment(rawValue: equipmentRaw) ?? .bodyweight }
        set { equipmentRaw = newValue.rawValue }
    }
    
    var instructionsList: [String] {
        get {
            guard let instructions = instructions, !instructions.isEmpty else { return [] }
            return instructions.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
        set {
            instructions = newValue.joined(separator: "\n")
        }
    }
    
    var formTipsList: [String] {
        get {
            guard let tips = formTips, !tips.isEmpty else { return [] }
            return tips.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
        set {
            formTips = newValue.joined(separator: "\n")
        }
    }
    
    init(
        name: String,
        primaryMuscle: MuscleGroup,
        secondaryMuscle: MuscleGroup? = nil,
        equipment: Equipment,
        isCalisthenic: Bool = false,
        lowBackSafe: Bool = true,
        machineName: String? = nil,
        info: String? = nil,
        musclesDescription: String,
        instructions: String? = nil,
        formTips: String? = nil
    ) {
        self.name = name
        self.primaryMuscleRaw = primaryMuscle.rawValue
        self.secondaryMuscleRaw = secondaryMuscle?.rawValue
        self.equipmentRaw = equipment.rawValue
        self.isCalisthenic = isCalisthenic
        self.lowBackSafe = lowBackSafe
        self.machineName = machineName
        self.info = info
        self.musclesDescription = musclesDescription
        self.instructions = instructions
        self.formTips = formTips
        self.createdDate = Date()
        self.isArchived = false
    }
    
    /// Convert to ExerciseTemplate for use in the app
    func toTemplate() -> ExerciseTemplate {
        return ExerciseTemplate(
            name: name,
            muscleGroup: primaryMuscle,
            equipment: equipment,
            secondaryMuscleGroup: secondaryMuscle,
            isCalisthenic: isCalisthenic,
            lowBackSafe: lowBackSafe,
            machineName: machineName,
            info: info
        )
    }
    
    /// Check if this exercise has any workout history
    func hasHistory(in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<SetEntry>(
            predicate: #Predicate { $0.exerciseName == name }
        )
        
        do {
            let count = try context.fetchCount(descriptor)
            return count > 0
        } catch {
            print("❌ Error checking history for \(name): \(error)")
            return false
        }
    }
    
    /// Get the count of sets logged for this exercise
    func historyCount(in context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<SetEntry>(
            predicate: #Predicate { $0.exerciseName == name }
        )
        
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("❌ Error counting history for \(name): \(error)")
            return 0
        }
    }
}

