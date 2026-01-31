import Foundation
import SwiftData

/// Manager for custom exercises with smart delete/archive logic
@Observable
class CustomExerciseManager {
    
    // MARK: - Save Custom Exercise
    
    /// Save a new custom exercise to SwiftData
    static func saveExercise(
        name: String,
        primaryMuscle: MuscleGroup,
        secondaryMuscle: MuscleGroup?,
        equipment: Equipment,
        isCalisthenic: Bool,
        lowBackSafe: Bool,
        machineName: String?,
        info: String?,
        musclesDescription: String,
        instructions: String?,
        formTips: String?,
        context: ModelContext
    ) throws {
        // Check for duplicate names
        let existingExercises = try context.fetch(FetchDescriptor<CustomExercise>())
        if existingExercises.contains(where: { $0.name.lowercased() == name.lowercased() && !$0.isArchived }) {
            throw CustomExerciseError.duplicateName
        }
        
        // Check against built-in exercises
        if ExerciseLibrary.all.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            throw CustomExerciseError.duplicateName
        }
        
        // Create and save
        let customExercise = CustomExercise(
            name: name,
            primaryMuscle: primaryMuscle,
            secondaryMuscle: secondaryMuscle,
            equipment: equipment,
            isCalisthenic: isCalisthenic,
            lowBackSafe: lowBackSafe,
            machineName: machineName,
            info: info,
            musclesDescription: musclesDescription,
            instructions: instructions,
            formTips: formTips
        )
        
        context.insert(customExercise)
        try context.save()
        
        print("✅ Custom exercise '\(name)' saved successfully")
    }
    
    // MARK: - Fetch Custom Exercises
    
    /// Fetch all custom exercises (excluding archived)
    static func fetchActiveExercises(from context: ModelContext) -> [CustomExercise] {
        let descriptor = FetchDescriptor<CustomExercise>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Error fetching custom exercises: \(error)")
            return []
        }
    }
    
    /// Fetch archived exercises
    static func fetchArchivedExercises(from context: ModelContext) -> [CustomExercise] {
        let descriptor = FetchDescriptor<CustomExercise>(
            predicate: #Predicate { $0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Error fetching archived exercises: \(error)")
            return []
        }
    }
    
    // MARK: - Delete/Archive Logic
    
    enum DeleteAction {
        case hardDelete // Permanently remove
        case archive    // Soft delete (hide but preserve)
    }
    
    struct DeleteInfo {
        let action: DeleteAction
        let historyCount: Int
        let message: String
        let confirmButtonText: String
    }
    
    /// Determine what happens when user tries to delete an exercise
    static func getDeleteInfo(for exercise: CustomExercise, context: ModelContext) -> DeleteInfo {
        let count = exercise.historyCount(in: context)
        
        if count == 0 {
            // No history - safe to hard delete
            return DeleteInfo(
                action: .hardDelete,
                historyCount: 0,
                message: "This exercise has no workout history. It will be permanently deleted.",
                confirmButtonText: "Delete"
            )
        } else {
            // Has history - must archive
            let setWord = count == 1 ? "set" : "sets"
            return DeleteInfo(
                action: .archive,
                historyCount: count,
                message: "This exercise has \(count) \(setWord) logged in your workout history. It will be archived to preserve your data. You can restore it later from Settings.",
                confirmButtonText: "Archive"
            )
        }
    }
    
    /// Delete or archive an exercise based on its history
    static func deleteExercise(_ exercise: CustomExercise, context: ModelContext) throws {
        let deleteInfo = getDeleteInfo(for: exercise, context: context)
        
        switch deleteInfo.action {
        case .hardDelete:
            // Permanently delete
            context.delete(exercise)
            try context.save()
            print("🗑️ Hard deleted exercise: \(exercise.name)")
            
        case .archive:
            // Soft delete (archive)
            exercise.isArchived = true
            try context.save()
            print("📦 Archived exercise: \(exercise.name) (\(deleteInfo.historyCount) sets preserved)")
        }
    }
    
    /// Restore an archived exercise
    static func restoreExercise(_ exercise: CustomExercise, context: ModelContext) throws {
        exercise.isArchived = false
        try context.save()
        print("♻️ Restored exercise: \(exercise.name)")
    }
    
    // MARK: - Combine with Built-in Exercises
    
    /// Get all exercises (built-in + custom active) as ExerciseTemplates
    static func getAllExercises(context: ModelContext) -> [ExerciseTemplate] {
        let customExercises = fetchActiveExercises(from: context)
        let customTemplates = customExercises.map { $0.toTemplate() }
        
        return ExerciseLibrary.all + customTemplates
    }
    
    /// Get all exercises filtered by mode, muscles, and equipment
    static func getExercisesForMode(
        _ mode: WorkoutMode,
        selectedMuscles: Set<MuscleGroup>,
        calisthenicsOnly: Bool,
        machinesOnly: Bool,
        freeWeightsOnly: Bool,
        context: ModelContext
    ) -> [ExerciseTemplate] {
        let allExercises = getAllExercises(context: context)
        
        // Apply the same filtering logic as ExerciseLibrary
        var base = allExercises.filter { $0.lowBackSafe }
        
        // Apply equipment filters
        if calisthenicsOnly {
            base = base.filter { $0.isCalisthenic }
        } else if machinesOnly {
            base = base.filter { $0.equipment == .machine || $0.equipment == .cable }
        } else if freeWeightsOnly {
            base = base.filter { $0.equipment == .barbell || $0.equipment == .dumbbell }
        }
        
        switch mode {
        case .push:
            return base.filter {
                [.chest, .shoulders, .arms, .triceps].contains($0.muscleGroup)
            }
        case .pull:
            return base.filter {
                [.back, .arms, .biceps].contains($0.muscleGroup)
            }
        case .legs:
            return base.filter {
                [.legs, .glutes, .quads, .hamstrings, .calves, .innerThigh].contains($0.muscleGroup)
            }
        case .full:
            return base.filter {
                [.chest, .back, .legs, .shoulders, .quads, .hamstrings].contains($0.muscleGroup)
            }
        case .calisthenics:
            return base.filter { $0.isCalisthenic }
        case .muscleGroups:
            var expandedMuscles = Set<MuscleGroup>()
            for muscle in selectedMuscles {
                if muscle.isLegacy {
                    expandedMuscles.formUnion(muscle.modernEquivalents)
                } else {
                    expandedMuscles.insert(muscle)
                }
            }
            return base.filter { expandedMuscles.contains($0.muscleGroup) }
        }
    }
    
    // MARK: - Exercise Database Integration
    
    /// Get primary muscles for any exercise (built-in or custom)
    static func getPrimaryMuscles(for exerciseName: String, context: ModelContext) -> String? {
        // Check built-in database first
        if let builtIn = ExerciseDatabase.primaryMuscles(for: exerciseName) {
            return builtIn
        }
        
        // Check custom exercises
        let descriptor = FetchDescriptor<CustomExercise>(
            predicate: #Predicate { $0.name == exerciseName }
        )
        
        if let custom = try? context.fetch(descriptor).first {
            return custom.musclesDescription
        }
        
        return nil
    }
    
    /// Get instructions for any exercise (built-in or custom)
    static func getInstructions(for exerciseName: String, context: ModelContext) -> [String]? {
        // Check built-in database first
        if let builtIn = ExerciseDatabase.instructions(for: exerciseName) {
            return builtIn
        }
        
        // Check custom exercises
        let descriptor = FetchDescriptor<CustomExercise>(
            predicate: #Predicate { $0.name == exerciseName }
        )
        
        if let custom = try? context.fetch(descriptor).first {
            let instructions = custom.instructionsList
            return instructions.isEmpty ? nil : instructions
        }
        
        return nil
    }
    
    /// Get form tips for any exercise (built-in or custom)
    static func getFormTips(for exerciseName: String, context: ModelContext) -> [String]? {
        // Check built-in database first
        if let builtIn = ExerciseDatabase.formTips(for: exerciseName) {
            return builtIn
        }
        
        // Check custom exercises
        let descriptor = FetchDescriptor<CustomExercise>(
            predicate: #Predicate { $0.name == exerciseName }
        )
        
        if let custom = try? context.fetch(descriptor).first {
            let tips = custom.formTipsList
            return tips.isEmpty ? nil : tips
        }
        
        return nil
    }
    
    /// Check if an exercise is custom
    static func isCustomExercise(_ exerciseName: String, context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<CustomExercise>(
            predicate: #Predicate { $0.name == exerciseName && !$0.isArchived }
        )
        
        return (try? context.fetchCount(descriptor)) ?? 0 > 0
    }
}

// MARK: - Errors

enum CustomExerciseError: LocalizedError {
    case duplicateName
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "An exercise with this name already exists"
        case .invalidData:
            return "Invalid exercise data"
        }
    }
}
