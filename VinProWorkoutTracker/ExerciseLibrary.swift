import Foundation

// MARK: - Enums & Models

enum WorkoutMode: String, CaseIterable, Identifiable {
    case push
    case pull
    case legs
    case full
    case calisthenics
    case muscleGroups

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .push:         return "Push"
        case .pull:         return "Pull"
        case .legs:         return "Legs"
        case .full:         return "Full Body"
        case .calisthenics: return "Calisthenics"
        case .muscleGroups: return "Custom (Muscles)"
        }
    }
}

enum Goal: String, CaseIterable, Identifiable {
    case strength
    case hypertrophy
    case endurance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .strength:    return "Strength"
        case .hypertrophy: return "Muscle / Size"
        case .endurance:   return "Endurance"
        }
    }
}

enum Equipment: String, CaseIterable {
    case barbell
    case dumbbell
    case machine
    case cable
    case bodyweight
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    case chest
    case back
    case shoulders
    case arms
    case legs
    case glutes
    case core

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

struct ExerciseTemplate {
    let name: String
    let muscleGroup: MuscleGroup
    let equipment: Equipment
    let isCalisthenic: Bool
    let lowBackSafe: Bool
}

// MARK: - Exercise Library

struct ExerciseLibrary {

    static let all: [ExerciseTemplate] = [
        // PUSH
        .init(name: "Flat Dumbbell Bench Press", muscleGroup: .chest, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Incline Dumbbell Press", muscleGroup: .chest, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Machine Chest Press", muscleGroup: .chest, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Seated Dumbbell Shoulder Press", muscleGroup: .shoulders, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Cable Lateral Raise", muscleGroup: .shoulders, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Cable Chest Fly", muscleGroup: .chest, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Triceps Rope Pushdown", muscleGroup: .arms, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Overhead Dumbbell Triceps Extension", muscleGroup: .arms, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),

        // PULL
        .init(name: "Lat Pulldown", muscleGroup: .back, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Seated Cable Row", muscleGroup: .back, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Chest-Supported Row", muscleGroup: .back, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Face Pull", muscleGroup: .back, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "EZ Bar Curl", muscleGroup: .arms, equipment: .barbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Dumbbell Hammer Curl", muscleGroup: .arms, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Assisted Pull-Up", muscleGroup: .back, equipment: .machine, isCalisthenic: false, lowBackSafe: true),

        // LEGS
        .init(name: "Leg Press", muscleGroup: .legs, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Goblet Squat", muscleGroup: .legs, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Leg Extension", muscleGroup: .legs, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Leg Curl", muscleGroup: .legs, equipment: .machine, isCalisthenic: false, lowBackSafe: true),

        // BODYWEIGHT
        .init(name: "Push-Up", muscleGroup: .chest, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Incline Push-Up", muscleGroup: .chest, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Bodyweight Squat", muscleGroup: .legs, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Split Squat", muscleGroup: .legs, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Bench Dip (feet on floor)", muscleGroup: .arms, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Inverted Row (waist height)", muscleGroup: .back, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),

        // CORE
        .init(name: "Front Plank", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Side Plank", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Dead Bug", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Bird Dog", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Pallof Press (cable/band)", muscleGroup: .core, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        
        // ADDITIONAL EXERCISES FOR TEMPLATES
        .init(name: "Rope Lat Prayer", muscleGroup: .back, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Swiss Ball Plank", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Bulgarian Split Squat", muscleGroup: .legs, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Glute Bridge", muscleGroup: .glutes, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Seated Leg Curl", muscleGroup: .legs, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Calf Raise", muscleGroup: .legs, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Farmer Carry", muscleGroup: .core, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Row Machine", muscleGroup: .back, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Hanging Knee Raise", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Toe Touch Crunch", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        .init(name: "Incline Dumbbell Press (Neutral)", muscleGroup: .chest, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Machine Shoulder Press", muscleGroup: .shoulders, equipment: .machine, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Cable Fly", muscleGroup: .chest, equipment: .cable, isCalisthenic: false, lowBackSafe: true),
        .init(name: "Plank to Push-Up", muscleGroup: .core, equipment: .bodyweight, isCalisthenic: true, lowBackSafe: true),
        
        // ADD YOUR NEW EXERCISES HERE
        // Example format:
        // .init(name: "Exercise Name", muscleGroup: .chest, equipment: .dumbbell, isCalisthenic: false, lowBackSafe: true),
    ]

    static func forMode(_ mode: WorkoutMode,
                        selectedMuscles: Set<MuscleGroup>,
                        calisthenicsOnly: Bool,
                        machinesOnly: Bool,
                        freeWeightsOnly: Bool) -> [ExerciseTemplate] {

        var base = all.filter { $0.lowBackSafe }
        
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
            return base.filter { [.chest, .shoulders, .arms].contains($0.muscleGroup) }

        case .pull:
            return base.filter { [.back, .arms].contains($0.muscleGroup) }

        case .legs:
            return base.filter { $0.muscleGroup == .legs || $0.muscleGroup == .glutes }

        case .full:
            return base.filter { [.chest, .back, .legs, .shoulders].contains($0.muscleGroup) }

        case .calisthenics:
            return base.filter { $0.isCalisthenic }

        case .muscleGroups:
            return base.filter { selectedMuscles.contains($0.muscleGroup) }
        }
    }

    static var coreExercises: [ExerciseTemplate] {
        all.filter { $0.muscleGroup == .core }
    }

    static var stretchSuggestionsBase: [String] {
        [
            "Supine hamstring stretch",
            "Hip flexor stretch",
            "Figure-4 stretch",
            "Child’s pose",
            "Cat-cow",
            "Calf stretch",
            "Quad stretch"
        ]
    }
}
