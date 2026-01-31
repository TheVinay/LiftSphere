import Foundation
import SwiftData

struct GeneratedWorkoutPlan {
    let name: String
    let mainExercises: [ExerciseTemplate]
    let coreExercises: [ExerciseTemplate]
    let stretches: [String]
    let warmupMinutes: Int
    let coreMinutes: Int
    let stretchMinutes: Int
}

struct WorkoutGenerator {

    static func generate(
        mode: WorkoutMode,
        goal: Goal,
        selectedMuscles: Set<MuscleGroup>,
        calisthenicsOnly: Bool,
        machinesOnly: Bool,
        freeWeightsOnly: Bool,
        warmupMinutes: Int,
        coreMinutes: Int,
        stretchMinutes: Int,
        context: ModelContext? = nil
    ) -> GeneratedWorkoutPlan {

        // Use custom exercise manager if context provided, otherwise fall back to built-in only
        let candidates: [ExerciseTemplate]
        if let context = context {
            candidates = CustomExerciseManager.getExercisesForMode(
                mode,
                selectedMuscles: selectedMuscles,
                calisthenicsOnly: calisthenicsOnly,
                machinesOnly: machinesOnly,
                freeWeightsOnly: freeWeightsOnly,
                context: context
            )
        } else {
            candidates = ExerciseLibrary.forMode(
                mode,
                selectedMuscles: selectedMuscles,
                calisthenicsOnly: calisthenicsOnly,
                machinesOnly: machinesOnly,
                freeWeightsOnly: freeWeightsOnly
            )
        }

        let core = ExerciseLibrary.coreExercises
        let main = Array(candidates.shuffled().prefix(4))
        let corePicked = Array(core.shuffled().prefix(3))
        let stretches = Array(ExerciseLibrary.stretchSuggestionsBase.shuffled().prefix(4))

        let title = "\(mode.displayName) – \(goal.displayName)"

        return GeneratedWorkoutPlan(
            name: title,
            mainExercises: main,
            coreExercises: corePicked,
            stretches: stretches,
            warmupMinutes: warmupMinutes,
            coreMinutes: coreMinutes,
            stretchMinutes: stretchMinutes
        )
    }
}
