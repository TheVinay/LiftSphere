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
    // Core muscle groups (original)
    case chest
    case back
    case shoulders
    case arms
    case legs
    case glutes
    case core
    
    // 🆕 Expanded muscle groups for better tracking
    case biceps
    case triceps
    case forearms
    case quads
    case hamstrings
    case calves
    case innerThigh
    case abs
    case obliques
    case lowerBack
    case hipFlexors
    case traps
    case rearDelts

    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .innerThigh: return "Inner Thigh"
        case .lowerBack: return "Lower Back"
        case .hipFlexors: return "Hip Flexors"
        case .rearDelts: return "Rear Delts"
        default: return rawValue.capitalized
        }
    }
    
    /// Returns suggested modern muscle groups for legacy cases
    var modernEquivalents: [MuscleGroup] {
        switch self {
        case .arms:
            return [.biceps, .triceps]
        case .core:
            return [.abs, .obliques, .lowerBack]
        case .legs:
            return [.quads, .hamstrings, .calves]
        default:
            return [self]
        }
    }
    
    /// True if this is a legacy muscle group that should be migrated
    var isLegacy: Bool {
        [.arms, .core, .legs].contains(self)
    }
    
    // MARK: - UI Filtering Helpers
    
    /// Returns all non-legacy muscle groups for UI display (filters, pickers, etc.)
    /// Use this instead of MuscleGroup.allCases to hide legacy groups from users
    static var modernGroups: [MuscleGroup] {
        allCases.filter { !$0.isLegacy }
    }
    
    /// Maps legacy group to primary modern equivalent for single selection contexts
    /// - .arms → .biceps
    /// - .core → .abs
    /// - .legs → .quads
    var primaryModernEquivalent: MuscleGroup {
        switch self {
        case .arms: return .biceps
        case .core: return .abs
        case .legs: return .quads
        default: return self
        }
    }
}

struct ExerciseTemplate: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let muscleGroup: MuscleGroup            // Primary
    let secondaryMuscleGroup: MuscleGroup? // Optional
    let equipment: Equipment
    let isCalisthenic: Bool
    let lowBackSafe: Bool
    let machineName: String?               // Optional
    let info: String?                      // Optional
    
    var usesBodyweight: Bool {
        equipment == .bodyweight
    }
    
    /// True if this exercise uses a legacy muscle group
    var isLegacyExercise: Bool {
        muscleGroup.isLegacy || secondaryMuscleGroup?.isLegacy == true
    }
    
    /// Returns a suggested updated version of this exercise with modern muscle groups
    func modernized() -> ExerciseTemplate? {
        guard isLegacyExercise else { return nil }
        
        // If primary muscle group is legacy, suggest a modern alternative based on exercise name
        if muscleGroup.isLegacy {
            let modernGroup = inferModernMuscleGroup(from: muscleGroup, exerciseName: name)
            
            return ExerciseTemplate(
                name: name,
                muscleGroup: modernGroup,
                equipment: equipment,
                secondaryMuscleGroup: secondaryMuscleGroup,
                isCalisthenic: isCalisthenic,
                lowBackSafe: lowBackSafe,
                machineName: machineName,
                info: info // Keep original info, don't replace it
            )
        }
        
        return nil
    }
    
    /// Intelligently infers the modern muscle group based on exercise name
    private func inferModernMuscleGroup(from legacy: MuscleGroup, exerciseName: String) -> MuscleGroup {
        let nameLower = exerciseName.lowercased()
        
        switch legacy {
        case .arms:
            // Check for bicep-related keywords
            if nameLower.contains("curl") || 
               nameLower.contains("bicep") ||
               nameLower.contains("biceps") {
                return .biceps
            }
            // Check for tricep-related keywords
            else if nameLower.contains("tricep") ||
                    nameLower.contains("triceps") ||
                    nameLower.contains("pushdown") ||
                    nameLower.contains("extension") ||
                    nameLower.contains("dip") {
                return .triceps
            }
            // Default to biceps if unclear
            return .biceps
            
        case .core:
            // Check for oblique-related keywords
            if nameLower.contains("side") ||
               nameLower.contains("twist") ||
               nameLower.contains("oblique") ||
               nameLower.contains("rotation") {
                return .obliques
            }
            // Check for lower back keywords
            else if nameLower.contains("superman") ||
                    nameLower.contains("back extension") ||
                    nameLower.contains("lower back") {
                return .lowerBack
            }
            // Default to abs
            return .abs
            
        case .legs:
            // Check for hamstring keywords
            if nameLower.contains("curl") ||
               nameLower.contains("hamstring") {
                return .hamstrings
            }
            // Check for calf keywords
            else if nameLower.contains("calf") {
                return .calves
            }
            // Default to quads
            return .quads
            
        default:
            // Not a legacy group, return as-is
            return legacy
        }
    }

    // ✅ Order: equipment BEFORE secondaryMuscleGroup
    init(
        name: String,
        muscleGroup: MuscleGroup,
        equipment: Equipment,
        secondaryMuscleGroup: MuscleGroup? = nil,
        isCalisthenic: Bool = false,
        lowBackSafe: Bool = true,
        machineName: String? = nil,
        info: String? = nil
    ) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.secondaryMuscleGroup = secondaryMuscleGroup
        self.equipment = equipment
        self.isCalisthenic = isCalisthenic
        self.lowBackSafe = lowBackSafe
        self.machineName = machineName
        self.info = info
    }


    // ✅ Order: secondaryMuscleGroup BEFORE equipment (for your existing rows)
    init(
        name: String,
        muscleGroup: MuscleGroup,
        secondaryMuscleGroup: MuscleGroup?,
        equipment: Equipment,
        isCalisthenic: Bool = false,
        lowBackSafe: Bool = true,
        machineName: String? = nil,
        info: String? = nil
    ) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.secondaryMuscleGroup = secondaryMuscleGroup
        self.equipment = equipment
        self.isCalisthenic = isCalisthenic
        self.lowBackSafe = lowBackSafe
        self.machineName = machineName
        self.info = info
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: ExerciseTemplate, rhs: ExerciseTemplate) -> Bool {
        lhs.name == rhs.name
    }
}


struct ExerciseDetail {
    let name: String
    let primaryMuscles: [String]
    let instructions: [String]
    let formTips: [String]
}

// MARK: - Exercise Library

struct ExerciseLibrary {

    static let all: [ExerciseTemplate] = [
        // ========== CHEST EXERCISES ==========
        
        // 🆕 Machine Chest Exercises
        .init(
            name: "Machine Bench Press",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .machine,
            machineName: "Chest Press Machine",
            info: "Horizontal pushing movement for pectorals"
        ),
        .init(
            name: "Incline Machine Press",
            muscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            equipment: .machine,
            machineName: "Incline Chest Press Machine",
            info: "Upper chest emphasis"
        ),
        .init(
            name: "Pec Fly (Machine)",
            muscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            equipment: .machine,
            machineName: "Pec Deck Machine",
            info: "Horizontal adduction of arms"
        ),
        .init(
            name: "Chest Dip (Machine)",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .machine,
            machineName: "Assisted Dip Machine",
            info: "Lower chest emphasis"
        ),
        
        // Chest - Dumbbell
        .init(
            name: "Flat Dumbbell Bench Press",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .dumbbell
        ),
        .init(
            name: "Incline Dumbbell Press",
            muscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            equipment: .dumbbell
        ),
        .init(
            name: "Incline Dumbbell Press (Neutral)",
            muscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            equipment: .dumbbell
        ),
        
        // Chest - Barbell
        .init(
            name: "Bench Press",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .barbell
        ),
        
        // Chest - Cable
        .init(
            name: "Cable Chest Press",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .cable,
            machineName: "Dual Cable Station",
            info: "Chest press using cables"
        ),
        .init(
            name: "Cable Chest Fly",
            muscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            equipment: .cable
        ),
        .init(
            name: "Cable Fly",
            muscleGroup: .chest,
            secondaryMuscleGroup: .shoulders,
            equipment: .cable
        ),
        
        // ========== BACK EXERCISES ==========
        
        // 🆕 Machine Back Exercises
        .init(
            name: "Lat Pulldown",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .machine,
            machineName: "Lat Pulldown Machine",
            info: "Vertical pulling motion"
        ),
        .init(
            name: "Seated Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .machine,
            machineName: "Seated Row Machine",
            info: "Horizontal pulling"
        ),
        .init(
            name: "High Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .rearDelts,
            equipment: .machine,
            machineName: "High Row Machine",
            info: "Upper-back emphasis"
        ),
        .init(
            name: "Assisted Pull-Up",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .machine,
            machineName: "Assisted Pull-Up Machine",
            info: "Bodyweight vertical pull"
        ),
        .init(
            name: "Pullover Machine",
            muscleGroup: .back,
            secondaryMuscleGroup: .chest,
            equipment: .machine,
            machineName: "Pullover Machine",
            info: "Straight-arm lat movement"
        ),
        
        // Back - Existing
        .init(
            name: "Seated Cable Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .cable
        ),
        .init(
            name: "Cable Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .cable,
            info: "Alias for Seated Cable Row"
        ),
        .init(
            name: "Dumbbell Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .dumbbell,
            info: "Single-arm or bent-over row"
        ),
        .init(
            name: "Chest-Supported Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .machine
        ),
        .init(
            name: "Face Pull",
            muscleGroup: .back,
            secondaryMuscleGroup: .rearDelts,
            equipment: .cable
        ),
        .init(
            name: "Rope Lat Prayer",
            muscleGroup: .back,
            equipment: .cable
        ),
        .init(
            name: "Row Machine",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .machine
        ),
        .init(
            name: "Bent Over Row",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .barbell,
            lowBackSafe: false
        ),
        .init(
            name: "Deadlift",
            muscleGroup: .back,
            secondaryMuscleGroup: .hamstrings,
            equipment: .barbell,
            lowBackSafe: false
        ),
        .init(
            name: "Inverted Row (waist height)",
            muscleGroup: .back,
            secondaryMuscleGroup: .biceps,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        
        // ========== SHOULDER EXERCISES ==========
        
        // 🆕 Machine Shoulder Exercises
        .init(
            name: "Shoulder Press (Machine)",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .triceps,
            equipment: .machine,
            machineName: "Shoulder Press Machine",
            info: "Vertical pushing"
        ),
        .init(
            name: "Lateral Raise (Machine)",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .traps,
            equipment: .machine,
            machineName: "Lateral Raise Machine",
            info: "Isolates medial delts"
        ),
        .init(
            name: "Rear Delt Fly (Machine)",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .back,
            equipment: .machine,
            machineName: "Reverse Pec Deck",
            info: "Posterior delts"
        ),
        
        // Shoulders - Existing
        .init(
            name: "Seated Dumbbell Shoulder Press",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .triceps,
            equipment: .dumbbell
        ),
        .init(
            name: "Shoulder Press",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .triceps,
            equipment: .dumbbell,
            info: "Alias for Seated Dumbbell Shoulder Press"
        ),
        .init(
            name: "Machine Shoulder Press",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .triceps,
            equipment: .machine
        ),
        .init(
            name: "Cable Lateral Raise",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .traps,
            equipment: .cable
        ),
        .init(
            name: "Lateral Raise",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .traps,
            equipment: .dumbbell,
            info: "Dumbbell lateral raise"
        ),
        .init(
            name: "Dumbbell Lateral Raise",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .traps,
            equipment: .dumbbell,
            info: "Side delt isolation"
        ),
        .init(
            name: "Cable Rear Delt Fly",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .back,
            equipment: .cable,
            info: "Rear deltoid isolation"
        ),
        .init(
            name: "Dumbbell Shrugs",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .traps,
            equipment: .dumbbell
        ),
        .init(
            name: "Overhead Press",
            muscleGroup: .shoulders,
            secondaryMuscleGroup: .triceps,
            equipment: .barbell
        ),
        .init(
            name: "Pike Push-Up",
            muscleGroup: .shoulders,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        
        // ========== LEG EXERCISES ==========
        
        // 🆕 Machine Leg Exercises
        .init(
            name: "Leg Press",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .machine,
            machineName: "Leg Press Machine",
            info: "Compound leg push"
        ),
        .init(
            name: "Hack Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .machine,
            machineName: "Hack Squat Machine",
            info: "Squat pattern"
        ),
        .init(
            name: "Leg Extension",
            muscleGroup: .quads,
            equipment: .machine,
            machineName: "Leg Extension Machine",
            info: "Knee extension"
        ),
        .init(
            name: "Seated Leg Curl",
            muscleGroup: .hamstrings,
            secondaryMuscleGroup: .glutes,
            equipment: .machine,
            machineName: "Seated Leg Curl Machine",
            info: "Knee flexion"
        ),
        .init(
            name: "Lying Leg Curl",
            muscleGroup: .hamstrings,
            secondaryMuscleGroup: .glutes,
            equipment: .machine,
            machineName: "Lying Leg Curl Machine",
            info: "Hip extension assist"
        ),
        .init(
            name: "Standing Leg Curl",
            muscleGroup: .hamstrings,
            secondaryMuscleGroup: .glutes,
            equipment: .machine,
            machineName: "Standing Leg Curl Machine",
            info: "Single-leg curl"
        ),
        .init(
            name: "Hip Abduction",
            muscleGroup: .glutes,
            equipment: .machine,
            machineName: "Hip Abduction Machine",
            info: "Outer thighs"
        ),
        .init(
            name: "Hip Adduction",
            muscleGroup: .innerThigh,
            equipment: .machine,
            machineName: "Hip Adduction Machine",
            info: "Inner thighs"
        ),
        .init(
            name: "Glute Kickback",
            muscleGroup: .glutes,
            secondaryMuscleGroup: .hamstrings,
            equipment: .machine,
            machineName: "Glute Kickback Machine",
            info: "Hip extension"
        ),
        .init(
            name: "Standing Calf Raise",
            muscleGroup: .calves,
            equipment: .machine,
            machineName: "Standing Calf Raise Machine",
            info: "Ankle plantar flexion"
        ),
        .init(
            name: "Seated Calf Raise",
            muscleGroup: .calves,
            equipment: .machine,
            machineName: "Seated Calf Raise Machine",
            info: "Soleus emphasis"
        ),
        
        // Legs - Existing
        .init(
            name: "Leg Curl",
            muscleGroup: .hamstrings,
            secondaryMuscleGroup: .glutes,
            equipment: .machine
        ),
        .init(
            name: "Romanian Deadlift",
            muscleGroup: .hamstrings,
            secondaryMuscleGroup: .glutes,
            equipment: .barbell,
            lowBackSafe: false,
            info: "Hip hinge movement for hamstrings"
        ),
        .init(
            name: "Calf Raise on Leg Press",
            muscleGroup: .calves,
            equipment: .machine,
            info: "Calf raises using leg press machine"
        ),
        .init(
            name: "Goblet Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .dumbbell
        ),
        .init(
            name: "Barbell Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .barbell,
            lowBackSafe: false
        ),
        .init(
            name: "Bodyweight Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Bulgarian Split Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Split Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Assisted Pistol Squat",
            muscleGroup: .quads,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Lateral Lunge",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Jump Squat",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Lunge Jump",
            muscleGroup: .quads,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Butt Kick",
            muscleGroup: .hamstrings,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Calf Raise",
            muscleGroup: .calves,
            equipment: .machine
        ),
        
        // ========== GLUTE EXERCISES ==========
        .init(
            name: "Glute Bridge",
            muscleGroup: .glutes,
            secondaryMuscleGroup: .hamstrings,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Hip Thrust",
            muscleGroup: .glutes,
            secondaryMuscleGroup: .hamstrings,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Single Leg Glute Bridge",
            muscleGroup: .glutes,
            secondaryMuscleGroup: .hamstrings,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Nordic Hamstring Curl",
            muscleGroup: .hamstrings,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        
        // ========== ARM EXERCISES (BICEPS) ==========
        
        // 🆕 Machine Biceps Exercises
        .init(
            name: "Biceps Curl (Machine)",
            muscleGroup: .biceps,
            secondaryMuscleGroup: .forearms,
            equipment: .machine,
            machineName: "Biceps Curl Machine",
            info: "Elbow flexion"
        ),
        .init(
            name: "Preacher Curl (Machine)",
            muscleGroup: .biceps,
            secondaryMuscleGroup: .forearms,
            equipment: .machine,
            machineName: "Preacher Curl Machine",
            info: "Isolated curl"
        ),
        
        // Biceps - Existing
        .init(
            name: "EZ Bar Curl",
            muscleGroup: .biceps,
            secondaryMuscleGroup: .forearms,
            equipment: .barbell
        ),
        .init(
            name: "Dumbbell Curl",
            muscleGroup: .biceps,
            secondaryMuscleGroup: .forearms,
            equipment: .dumbbell,
            info: "Standard bicep curl"
        ),
        .init(
            name: "Dumbbell Hammer Curl",
            muscleGroup: .biceps,
            secondaryMuscleGroup: .forearms,
            equipment: .dumbbell
        ),
        .init(
            name: "Suspension Bicep Curl",
            muscleGroup: .biceps,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        
        // ========== ARM EXERCISES (TRICEPS) ==========
        
        // 🆕 Machine Triceps Exercises
        .init(
            name: "Triceps Pushdown",
            muscleGroup: .triceps,
            secondaryMuscleGroup: .shoulders,
            equipment: .cable,
            machineName: "Cable Pushdown Station",
            info: "Elbow extension"
        ),
        .init(
            name: "Overhead Triceps Extension",
            muscleGroup: .triceps,
            secondaryMuscleGroup: .shoulders,
            equipment: .machine,
            machineName: "Overhead Triceps Extension Machine",
            info: "Long head focus"
        ),
        .init(
            name: "Triceps Dip (Machine)",
            muscleGroup: .triceps,
            secondaryMuscleGroup: .chest,
            equipment: .machine,
            machineName: "Assisted Dip Machine",
            info: "Compound triceps push"
        ),
        
        // Triceps - Existing
        .init(
            name: "Triceps Rope Pushdown",
            muscleGroup: .triceps,
            equipment: .cable
        ),
        .init(
            name: "Tricep Pushdown",
            muscleGroup: .triceps,
            equipment: .cable,
            info: "Alias for Triceps Pushdown"
        ),
        .init(
            name: "Overhead Dumbbell Triceps Extension",
            muscleGroup: .triceps,
            equipment: .dumbbell
        ),
        .init(
            name: "Bench Dip (feet on floor)",
            muscleGroup: .triceps,
            secondaryMuscleGroup: .chest,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        
        // ========== CORE EXERCISES ==========
        
        // 🆕 Machine Core Exercises
        .init(
            name: "Ab Crunch (Machine)",
            muscleGroup: .abs,
            equipment: .machine,
            machineName: "Ab Crunch Machine",
            info: "Trunk flexion"
        ),
        .init(
            name: "Rotary Torso",
            muscleGroup: .obliques,
            secondaryMuscleGroup: .abs,
            equipment: .machine,
            machineName: "Rotary Torso Machine",
            info: "Trunk rotation"
        ),
        .init(
            name: "Back Extension",
            muscleGroup: .lowerBack,
            secondaryMuscleGroup: .glutes,
            equipment: .machine,
            machineName: "Back Extension Machine",
            info: "Lumbar extension"
        ),
        .init(
            name: "Captain's Chair Knee Raise",
            muscleGroup: .abs,
            secondaryMuscleGroup: .hipFlexors,
            equipment: .machine,
            machineName: "Captain's Chair",
            info: "Hip flexion + abs"
        ),
        
        // Core - Bodyweight
        .init(
            name: "Front Plank",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Front Plank (hold)",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true,
            info: "Timed plank hold"
        ),
        .init(
            name: "Side Plank",
            muscleGroup: .obliques,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Dead Bug",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Bird Dog",
            muscleGroup: .abs,
            secondaryMuscleGroup: .lowerBack,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Pallof Press (cable/band)",
            muscleGroup: .abs,
            secondaryMuscleGroup: .obliques,
            equipment: .cable
        ),
        .init(
            name: "Swiss Ball Plank",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Hanging Knee Raise",
            muscleGroup: .abs,
            secondaryMuscleGroup: .hipFlexors,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Toe Touch Crunch",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Superman",
            muscleGroup: .lowerBack,
            secondaryMuscleGroup: .glutes,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Mountain Climber",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Burpee",
            muscleGroup: .abs,
            secondaryMuscleGroup: .chest,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Russian Twist",
            muscleGroup: .obliques,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Bicycle Crunch",
            muscleGroup: .abs,
            secondaryMuscleGroup: .obliques,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Plank Shoulder Tap",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Plank to Push-Up",
            muscleGroup: .abs,
            secondaryMuscleGroup: .chest,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "High Knee",
            muscleGroup: .abs,
            secondaryMuscleGroup: .hipFlexors,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Jumping Jack",
            muscleGroup: .abs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Farmer Carry",
            muscleGroup: .abs,
            secondaryMuscleGroup: .forearms,
            equipment: .dumbbell
        ),
        
        // ========== BODYWEIGHT / PUSH-UPS ==========
        .init(
            name: "Push-Up",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Incline Push-Up",
            muscleGroup: .chest,
            secondaryMuscleGroup: .triceps,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Diamond Push-Up",
            muscleGroup: .triceps,
            secondaryMuscleGroup: .chest,
            equipment: .bodyweight,
            isCalisthenic: true,
            info: "Tricep-focused push-up variation"
        ),
        
        // ========== ADDITIONAL EXERCISES ==========
        .init(
            name: "Reverse Snow Angel",
            muscleGroup: .back,
            secondaryMuscleGroup: .rearDelts,
            equipment: .bodyweight,
            isCalisthenic: true,
            info: "Upper back and rear delt activation"
        ),
        .init(
            name: "Band Pull-Apart",
            muscleGroup: .back,
            secondaryMuscleGroup: .rearDelts,
            equipment: .bodyweight,
            isCalisthenic: true,
            info: "Rear delt and upper back exercise with resistance band"
        ),
        .init(
            name: "Scapular Retraction",
            muscleGroup: .back,
            secondaryMuscleGroup: .traps,
            equipment: .bodyweight,
            isCalisthenic: true,
            info: "Shoulder blade movement exercise for posture"
        ),
        
        // ========== LEGACY EXERCISES (For Backward Compatibility) ==========
        // These maintain the old .arms, .legs, .core muscle groups for old workout logs
        .init(
            name: "Arm Curls (Legacy)",
            muscleGroup: .arms,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Leg Exercises (Legacy)",
            muscleGroup: .legs,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
        .init(
            name: "Core Work (Legacy)",
            muscleGroup: .core,
            equipment: .bodyweight,
            isCalisthenic: true
        ),
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
            // Include both old (.arms) and new (.triceps) muscle groups for backward compatibility
            return base.filter { 
                [.chest, .shoulders, .arms, .triceps].contains($0.muscleGroup) 
            }

        case .pull:
            // Include both old (.arms) and new (.biceps) muscle groups for backward compatibility
            return base.filter { 
                [.back, .arms, .biceps].contains($0.muscleGroup) 
            }

        case .legs:
            // Include both old (.legs) and new (.quads, .hamstrings, .calves) for backward compatibility
            return base.filter { 
                [.legs, .glutes, .quads, .hamstrings, .calves, .innerThigh].contains($0.muscleGroup) 
            }

        case .full:
            // Include expanded muscle groups for full body
            return base.filter { 
                [.chest, .back, .legs, .shoulders, .quads, .hamstrings].contains($0.muscleGroup) 
            }

        case .calisthenics:
            return base.filter { $0.isCalisthenic }

        case .muscleGroups:
            // Expand legacy muscle selections to include modern equivalents
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

    static var coreExercises: [ExerciseTemplate] {
        // Include both old (.core) and new (.abs, .obliques, .lowerBack) for backward compatibility
        all.filter {
            [.core, .abs, .obliques, .lowerBack, .hipFlexors].contains($0.muscleGroup)
        }
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

    // MARK: - Silent Auto-Migration

    /// The main muscle groups we track in analytics/radar charts (9 groups for clean visualization)
    static let trackedMuscleGroups: [MuscleGroup] = [
        .chest, .back, .shoulders,
        .biceps, .triceps,
        .quads, .hamstrings, .glutes,
        .abs
    ]

    /// Automatically modernizes legacy exercises without user intervention
    /// Call this when loading exercises from storage to ensure they use current muscle groups
    static func autoMigrate(_ exercise: ExerciseTemplate) -> ExerciseTemplate {
        if let modernized = exercise.modernized() {
            return modernized
        }
        return exercise
    }

    /// Batch auto-migrate multiple exercises
    static func autoMigrate(_ exercises: [ExerciseTemplate]) -> [ExerciseTemplate] {
        exercises.map { autoMigrate($0) }
    }
}
