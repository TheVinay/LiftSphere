import Foundation

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
        warmupMinutes: Int,
        coreMinutes: Int,
        stretchMinutes: Int
    ) -> GeneratedWorkoutPlan {

        let candidates = ExerciseLibrary.forMode(mode,
                                                 selectedMuscles: selectedMuscles,
                                                 calisthenicsOnly: calisthenicsOnly)

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
