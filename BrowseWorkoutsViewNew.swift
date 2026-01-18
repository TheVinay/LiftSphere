import SwiftUI
import SwiftData

/// Browse and select from preset workout programs with drill-down navigation.
struct BrowseWorkoutsViewNew: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // Custom templates from database
    @Query(sort: \CustomWorkoutTemplate.createdDate, order: .reverse)
    private var customTemplates: [CustomWorkoutTemplate]
    
    // All workout programs
    private var programs: [WorkoutProgram] {
        [
            pushPullProgram,
            pplProgram,
            amarissProgram,
            broSplitProgram,
            strongLiftsProgram,
            madcowProgram,
            hotelWorkoutProgram,
            tabataProgram
        ]
    }
    
    var body: some View {
        NavigationStack {
            List {
                // PRESET PROGRAMS
                Section("Workout Programs") {
                    ForEach(programs) { program in
                        NavigationLink {
                            ProgramDetailView(
                                program: program,
                                context: context,
                                dismiss: dismiss
                            )
                        } label: {
                            ProgramRow(program: program)
                        }
                    }
                }
                
                // CUSTOM TEMPLATES
                if !customTemplates.isEmpty {
                    Section("My Templates") {
                        ForEach(customTemplates) { template in
                            NavigationLink {
                                CustomTemplateDetailView(
                                    template: template,
                                    context: context,
                                    dismiss: dismiss
                                )
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.title2)
                                        .foregroundStyle(.yellow)
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(template.name)
                                            .font(.headline)
                                        
                                        Text("\(template.mainExercises.count) exercises")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Browse Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Program Definitions
    
    private var pushPullProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Push/Pull",
            icon: "figure.strengthtraining.traditional",
            days: [
                ProgramDay(
                    name: "Day 1 - Pull",
                    description: "Back, biceps, and rear delts",
                    exercises: [
                        "Dumbbell Row",
                        "Lat Pulldown",
                        "Cable Rear Delt Fly",
                        "Dumbbell Curl",
                        "Dumbbell Hammer Curl"
                    ],
                    coreExercises: ["Front Plank", "Side Plank", "Bird Dog"],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 2 - Push",
                    description: "Chest, shoulders, and triceps",
                    exercises: [
                        "Seated Dumbbell Shoulder Press",
                        "Machine Chest Press",
                        "Cable Chest Fly",
                        "Dumbbell Lateral Raise",
                        "Triceps Rope Pushdown"
                    ],
                    coreExercises: ["Front Plank", "Side Plank", "Bird Dog"],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 3 - Legs",
                    description: "Quads, hamstrings, and glutes",
                    exercises: [
                        "Leg Press",
                        "Leg Extension",
                        "Leg Curl",
                        "Calf Raise on Leg Press",
                        "Goblet Squat"
                    ],
                    coreExercises: ["Front Plank", "Side Plank", "Bird Dog"],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var pplProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Push/Pull/Legs (PPL)",
            icon: "dumbbell.fill",
            days: [
                ProgramDay(
                    name: "Day 1 - Pull",
                    description: "Back and biceps focus",
                    exercises: [
                        "Lat Pulldown",
                        "Cable Row",
                        "Dumbbell Row",
                        "Face Pull",
                        "Dumbbell Curl"
                    ],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 2 - Push",
                    description: "Chest, shoulders, triceps",
                    exercises: [
                        "Bench Press",
                        "Incline Dumbbell Press",
                        "Overhead Press",
                        "Lateral Raise",
                        "Tricep Pushdown"
                    ],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 3 - Legs",
                    description: "Complete lower body",
                    exercises: [
                        "Barbell Squat",
                        "Romanian Deadlift",
                        "Leg Press",
                        "Leg Curl",
                        "Calf Raise"
                    ],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var amarissProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Back friendly core",
            icon: "person.fill",
            days: [
                ProgramDay(
                    name: "Day 1 - Core & Pull",
                    description: "Core strength and back",
                    exercises: ["Lat Pulldown", "Cable Row", "Dumbbell Row"],
                    coreExercises: ["Front Plank", "Side Plank", "Dead Bug"],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 10,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 2 - Lower & Glutes",
                    description: "Legs and glute focus",
                    exercises: ["Leg Press", "Romanian Deadlift", "Hip Thrust"],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 3 - Row & Core",
                    description: "Back rows and core stability",
                    exercises: ["Cable Row", "Dumbbell Row", "Face Pull"],
                    coreExercises: ["Bird Dog", "Dead Bug", "Front Plank"],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 10,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 4 - Push & Posture",
                    description: "Chest, shoulders, posture work",
                    exercises: ["Bench Press", "Shoulder Press", "Face Pull"],
                    coreExercises: ["Band Pull-Apart", "Scapular Retraction"],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var broSplitProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Bro Split",
            icon: "figure.arms.open",
            days: [
                ProgramDay(
                    name: "Day 1 - Chest",
                    description: "Chest isolation",
                    exercises: ["Bench Press", "Incline Dumbbell Press", "Cable Chest Fly", "Machine Chest Press"],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 2 - Back",
                    description: "Back isolation",
                    exercises: ["Lat Pulldown", "Cable Row", "Dumbbell Row", "Face Pull"],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 3 - Shoulders",
                    description: "Shoulder isolation",
                    exercises: ["Seated Dumbbell Shoulder Press", "Lateral Raise", "Cable Lateral Raise", "Face Pull"],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 4 - Legs",
                    description: "Leg isolation",
                    exercises: ["Leg Press", "Goblet Squat", "Leg Extension", "Leg Curl", "Bodyweight Squat"],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 5 - Arms",
                    description: "Biceps and triceps",
                    exercises: ["EZ Bar Curl", "Dumbbell Hammer Curl", "Triceps Rope Pushdown", "Overhead Dumbbell Triceps Extension"],
                    coreExercises: [],
                    stretches: ExerciseLibrary.stretchSuggestionsBase,
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var strongLiftsProgram: WorkoutProgram {
        WorkoutProgram(
            name: "StrongLifts 5×5",
            icon: "figure.strengthtraining.traditional",
            days: [
                ProgramDay(
                    name: "Workout A",
                    description: "Squat, bench, row - 5×5",
                    exercises: ["Barbell Squat", "Bench Press", "Bent Over Row"],
                    coreExercises: [],
                    stretches: ["Hip flexor stretch", "Quad stretch", "Hamstring stretch"],
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Workout B",
                    description: "Squat, press, deadlift - 5×5 + 1×5",
                    exercises: ["Barbell Squat", "Overhead Press", "Deadlift"],
                    coreExercises: [],
                    stretches: ["Hip flexor stretch", "Quad stretch", "Hamstring stretch"],
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var madcowProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Madcow 5×5",
            icon: "figure.strengthtraining.traditional",
            days: [
                ProgramDay(
                    name: "Monday - Volume",
                    description: "5×5 ramping sets",
                    exercises: ["Barbell Squat", "Bench Press", "Bent Over Row"],
                    coreExercises: [],
                    stretches: ["Hip flexor stretch", "Quad stretch", "Hamstring stretch"],
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Wednesday - Light",
                    description: "4×5 at 80% of Monday",
                    exercises: ["Barbell Squat", "Overhead Press", "Deadlift"],
                    coreExercises: [],
                    stretches: ["Hip flexor stretch", "Quad stretch", "Hamstring stretch"],
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Friday - Intensity",
                    description: "4×5 + 1×3 PR attempt",
                    exercises: ["Barbell Squat", "Bench Press", "Deadlift"],
                    coreExercises: [],
                    stretches: ["Hip flexor stretch", "Quad stretch", "Hamstring stretch"],
                    warmupMinutes: 5,
                    coreMinutes: 0,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var hotelWorkoutProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Hotel Workouts",
            icon: "bed.double.fill",
            days: [
                ProgramDay(
                    name: "Day 1 - Upper Push + Core",
                    description: "Chest, shoulders, triceps",
                    exercises: [
                        "Push-Up",
                        "Incline Push-Up",
                        "Bench Dip (feet on floor)",
                        "Pike Push-Up",
                        "Plank to Push-Up"
                    ],
                    coreExercises: [
                        "Front Plank",
                        "Dead Bug"
                    ],
                    stretches: [
                        "Child's pose",
                        "Hip flexor stretch"
                    ],
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 2 - Upper Pull + Core",
                    description: "Back, posture, arms",
                    exercises: [
                        "Superman",
                        "Reverse Snow Angel",
                        "Incline Push-Up",
                        "Diamond Push-Up"
                    ],
                    coreExercises: [
                        "Side Plank",
                        "Bird Dog"
                    ],
                    stretches: [
                        "Supine hamstring stretch",
                        "Figure-4 stretch",
                        "Child's pose"
                    ],
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                ),
                ProgramDay(
                    name: "Day 3 - Lower Body + Conditioning",
                    description: "Legs, glutes, conditioning",
                    exercises: [
                        "Bodyweight Squat",
                        "Split Squat",
                        "Bulgarian Split Squat",
                        "Lateral Lunge",
                        "Single Leg Glute Bridge",
                        "Mountain Climber"
                    ],
                    coreExercises: [
                        "Side Plank"
                    ],
                    stretches: [
                        "Quad stretch",
                        "Hip flexor stretch",
                        "Calf stretch"
                    ],
                    warmupMinutes: 5,
                    coreMinutes: 5,
                    stretchMinutes: 5
                )
            ]
        )
    }
    
    private var tabataProgram: WorkoutProgram {
        WorkoutProgram(
            name: "Tabata HIIT",
            icon: "timer",
            days: [
                ProgramDay(
                    name: "Core Crusher",
                    description: "4 min - 8 rounds × (20s work / 10s rest)",
                    exercises: [
                        "Mountain Climber",
                        "Russian Twist",
                        "Bicycle Crunch",
                        "Plank Shoulder Tap"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Child's pose",
                        "Cat-cow stretch",
                        "Supine twist"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Full Body Burn",
                    description: "4 min - All-out intensity",
                    exercises: [
                        "Burpee",
                        "Jump Squat",
                        "Push-Up",
                        "High Knee"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Quad stretch",
                        "Hip flexor stretch",
                        "Shoulder stretch"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Leg Destroyer",
                    description: "4 min - Lower body blast",
                    exercises: [
                        "Jump Squat",
                        "Lunge Jump",
                        "Bodyweight Squat",
                        "Single Leg Glute Bridge"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Quad stretch",
                        "Hamstring stretch",
                        "Calf stretch",
                        "Figure-4 stretch"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Upper Body Blast",
                    description: "4 min - Push power",
                    exercises: [
                        "Push-Up",
                        "Pike Push-Up",
                        "Plank to Push-Up",
                        "Bench Dip (feet on floor)"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Chest stretch",
                        "Shoulder stretch",
                        "Tricep stretch"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Cardio Crusher",
                    description: "4 min - Maximum heart rate",
                    exercises: [
                        "High Knee",
                        "Butt Kick",
                        "Jumping Jack",
                        "Mountain Climber"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Quad stretch",
                        "Hip flexor stretch",
                        "Hamstring stretch"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Total Body Tabata",
                    description: "4 min - Everything",
                    exercises: [
                        "Burpee",
                        "Mountain Climber",
                        "Jump Squat",
                        "Push-Up"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Child's pose",
                        "Downward dog",
                        "Hip flexor stretch",
                        "Quad stretch"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Ab Ripper",
                    description: "4 min - Core endurance",
                    exercises: [
                        "Bicycle Crunch",
                        "Front Plank (hold)",
                        "Russian Twist",
                        "Dead Bug"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Child's pose",
                        "Cat-cow stretch",
                        "Supine twist"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                ),
                ProgramDay(
                    name: "Power Builder",
                    description: "4 min - Explosive strength",
                    exercises: [
                        "Jump Squat",
                        "Burpee",
                        "Lunge Jump",
                        "Plank to Push-Up"
                    ],
                    coreExercises: [],
                    stretches: [
                        "Quad stretch",
                        "Hip flexor stretch",
                        "Chest stretch",
                        "Shoulder stretch"
                    ],
                    warmupMinutes: 3,
                    coreMinutes: 4,
                    stretchMinutes: 3
                )
            ]
        )
    }
}

// MARK: - Program Row

private struct ProgramRow: View {
    let program: WorkoutProgram
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: program.icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(program.name)
                    .font(.headline)
                
                Text("\(program.days.count) day\(program.days.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Program Detail View

private struct ProgramDetailView: View {
    let program: WorkoutProgram
    let context: ModelContext
    let dismiss: DismissAction
    
    @State private var workoutName: String = ""
    @State private var selectedDay: ProgramDay?
    @State private var expandedDay: ProgramDay?
    
    var body: some View {
        List {
            // WORKOUT NAME
            Section {
                TextField("Workout name", text: $workoutName)
                    .font(.body)
            } header: {
                Text("Workout Name")
            } footer: {
                Text("This will be the name of your created workout")
                    .font(.caption)
            }
            
            // SELECT DAY
            Section("Select Day") {
                ForEach(program.days) { day in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedDay?.id == day.id },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedDay = day
                                    selectedDay = day
                                    updateWorkoutName(for: day)
                                } else {
                                    expandedDay = nil
                                }
                            }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            // Main exercises
                            if !day.exercises.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Main Exercises")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    
                                    ForEach(day.exercises, id: \.self) { exercise in
                                        HStack(spacing: 8) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .foregroundColor(.blue)
                                            Text(exercise)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                            }
                            
                            // Core/accessory exercises
                            if !day.coreExercises.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Accessory")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    
                                    ForEach(day.coreExercises, id: \.self) { exercise in
                                        HStack(spacing: 8) {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .foregroundColor(.orange)
                                            Text(exercise)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(day.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(day.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Selected indicator
                            if selectedDay?.id == day.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if let day = selectedDay {
                        createWorkout(for: day)
                    }
                }
                .disabled(selectedDay == nil)
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            let datePart = formatter.string(from: Date())
            let defaultDayName = program.days.first?.name ?? "Workout"
            workoutName = "\(datePart) - \(defaultDayName)"
        }
    }
    
    // Update workout name when day is selected
    private func updateWorkoutName(for day: ProgramDay) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        let datePart = formatter.string(from: Date())
        workoutName = "\(datePart) - \(day.name)"
    }
    
    private func createWorkout(for day: ProgramDay) {
        // All programs now have pre-defined exercises
        let exercises = day.exercises
        let coreExercises = day.coreExercises
        
        let finalName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let workout = Workout(
            date: Date(),
            name: finalName.isEmpty ? day.name : finalName,
            warmupMinutes: day.warmupMinutes,
            coreMinutes: day.coreMinutes,
            stretchMinutes: day.stretchMinutes,
            mainExercises: exercises,
            coreExercises: coreExercises,
            stretches: day.stretches,
            notes: "",
            sets: []
        )
        
        context.insert(workout)
        try? context.save()
        dismiss()
    }
}

// MARK: - Custom Template Detail View

private struct CustomTemplateDetailView: View {
    let template: CustomWorkoutTemplate
    let context: ModelContext
    let dismiss: DismissAction
    
    @State private var workoutName: String = ""
    
    var body: some View {
        List {
            // WORKOUT NAME
            Section {
                TextField("Workout name", text: $workoutName)
                    .font(.body)
            } header: {
                Text("Workout Name")
            }
            
            // EXERCISES
            Section("Exercises") {
                ForEach(template.mainExercises, id: \.self) { exercise in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.blue)
                        Text(exercise)
                            .font(.subheadline)
                    }
                }
            }
            
            // CREATE BUTTON
            Section {
                Button {
                    createWorkout()
                } label: {
                    HStack {
                        Spacer()
                        Text("Create Workout")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            let datePart = formatter.string(from: Date())
            workoutName = "\(datePart) - \(template.name)"
        }
    }
    
    private func createWorkout() {
        let finalName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let workout = Workout(
            date: Date(),
            name: finalName.isEmpty ? template.name : finalName,
            warmupMinutes: template.warmupMinutes,
            coreMinutes: template.coreMinutes,
            stretchMinutes: template.stretchMinutes,
            mainExercises: template.mainExercises,
            coreExercises: template.coreExercises,
            stretches: template.stretches,
            notes: "",
            sets: []
        )
        
        context.insert(workout)
        try? context.save()
        dismiss()
    }
}

// MARK: - Data Models

struct WorkoutProgram: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let days: [ProgramDay]
}

struct ProgramDay: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let exercises: [String]
    let coreExercises: [String]
    let stretches: [String]
    let warmupMinutes: Int
    let coreMinutes: Int
    let stretchMinutes: Int
}

#Preview {
    BrowseWorkoutsViewNew()
        .modelContainer(for: [Workout.self, SetEntry.self, CustomWorkoutTemplate.self], inMemory: true)
}
