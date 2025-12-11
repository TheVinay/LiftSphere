import SwiftUI
import SwiftData

struct NewWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Existing workouts so we can repeat last Push/Pull
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]

    @State private var mode: WorkoutMode = .push
    @State private var goal: Goal = .hypertrophy
    @State private var bodyweightOnly: Bool = false

    @State private var warmupMinutes: Double = 5
    @State private var coreMinutes: Double = 5
    @State private var stretchMinutes: Double = 5

    @State private var selectedMuscles: Set<MuscleGroup> = []
    @State private var generatedPlan: GeneratedWorkoutPlan?

    // Editable workout name
    @State private var workoutName: String = ""

    // NEW: unified quick-template dropdown
    private enum QuickTemplateChoice: String, CaseIterable, Identifiable {
        case none = "None"
        case vinayPush = "Back-friendly Push (Vinay)"
        case vinayPull = "Back-friendly Pull (Vinay)"
        case amarissDay1 = "Amariss Day 1"
        case amarissDay2 = "Amariss Day 2"
        case amarissDay3 = "Amariss Day 3"
        case amarissDay4 = "Amariss Day 4"

        var id: Self { self }
        var label: String { rawValue }
    }

    @State private var quickTemplateChoice: QuickTemplateChoice = .none

    var body: some View {
        NavigationStack {
            Form {
                // QUICK TEMPLATES DROPDOWN (replaces the two flat sections)
                Section("Quick templates") {
                    Picker("Quick template", selection: $quickTemplateChoice) {
                        ForEach(QuickTemplateChoice.allCases) { choice in
                            Text(choice.label).tag(choice)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: quickTemplateChoice) { choice in
                        applyQuickTemplate(choice)
                    }
                }

                // WORKOUT NAME
                Section("Workout name") {
                    TextField("Name", text: $workoutName)
                }

                // REPEAT PREVIOUS
                Section("Repeat previous") {
                    Button("Use last Push workout") {
                        applyLastWorkout(containing: "Push")
                    }
                    .disabled(lastWorkout(containing: "Push") == nil)

                    Button("Use last Pull workout") {
                        applyLastWorkout(containing: "Pull")
                    }
                    .disabled(lastWorkout(containing: "Pull") == nil)
                }

                // GENERATOR OPTIONS
                Section("Generator options") {
                    Picker("Mode", selection: $mode) {
                        ForEach(WorkoutMode.allCases) { m in
                            Text(m.displayName).tag(m)
                        }
                    }

                    Picker("Goal", selection: $goal) {
                        ForEach(Goal.allCases) { g in
                            Text(g.displayName).tag(g)
                        }
                    }

                    Toggle("Bodyweight only", isOn: $bodyweightOnly)

                    HStack {
                        Text("Warmup: \(Int(warmupMinutes)) min")
                        Slider(value: $warmupMinutes, in: 0...15, step: 1)
                    }

                    HStack {
                        Text("Core: \(Int(coreMinutes)) min")
                        Slider(value: $coreMinutes, in: 0...20, step: 1)
                    }

                    HStack {
                        Text("Stretching: \(Int(stretchMinutes)) min")
                        Slider(value: $stretchMinutes, in: 0...20, step: 1)
                    }

                    if mode == .muscleGroups {
                        MuscleGroupMultiSelector(selected: $selectedMuscles)
                    }

                    Button("Generate suggestion") {
                        let plan = WorkoutGenerator.generate(
                            mode: mode,
                            goal: goal,
                            selectedMuscles: selectedMuscles,
                            calisthenicsOnly: bodyweightOnly,
                            warmupMinutes: Int(warmupMinutes),
                            coreMinutes: Int(coreMinutes),
                            stretchMinutes: Int(stretchMinutes)
                        )
                        generatedPlan = plan
                        workoutName = defaultName(for: plan.name)
                    }
                    .foregroundColor(.blue)
                }

                // SUGGESTED WORKOUT
                if let plan = generatedPlan {
                    Section("Suggested main exercises") {
                        ForEach(plan.mainExercises, id: \.name) { ex in
                            Text(ex.name)
                        }
                    }

                    Section("Accessory / core (optional)") {
                        ForEach(plan.coreExercises, id: \.name) { ex in
                            Text(ex.name)
                        }
                    }

                    Section("Stretches") {
                        ForEach(plan.stretches, id: \.self) { s in
                            Text(s)
                        }
                    }
                }
            }
            .navigationTitle("New workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(generatedPlan == nil)
                }
            }
        }
    }

    // MARK: - NEW helper to route dropdown choice

    private func applyQuickTemplate(_ choice: QuickTemplateChoice) {
        switch choice {
        case .none:
            return
        case .vinayPush:
            applyVinayTemplate(.backFriendlyPush)
        case .vinayPull:
            applyVinayTemplate(.backFriendlyPull)
        case .amarissDay1:
            applyAmarissTemplate(.day1)
        case .amarissDay2:
            applyAmarissTemplate(.day2)
        case .amarissDay3:
            applyAmarissTemplate(.day3)
        case .amarissDay4:
            applyAmarissTemplate(.day4)
        }
    }

    // MARK: - Naming helper

    private func defaultName(for base: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMM-dd"
        let day = formatter.string(from: Date())
        return "\(day)-\(base)"
    }

    // MARK: - Save

    private func saveWorkout() {
        guard let plan = generatedPlan else {
            dismiss()
            return
        }

        let finalName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        let workout = Workout(
            date: Date(),
            name: finalName.isEmpty ? plan.name : finalName,
            warmupMinutes: plan.warmupMinutes,
            coreMinutes: plan.coreMinutes,
            stretchMinutes: plan.stretchMinutes,
            mainExercises: plan.mainExercises.map { $0.name },
            coreExercises: plan.coreExercises.map { $0.name },
            stretches: plan.stretches,
            sets: []
        )

        context.insert(workout)
        try? context.save()
        dismiss()
    }

    // MARK: - Repeat helpers

    private func lastWorkout(containing keyword: String) -> Workout? {
        workouts.first { $0.name.localizedCaseInsensitiveContains(keyword) }
    }

    private func applyLastWorkout(containing keyword: String) {
        guard let source = lastWorkout(containing: keyword) else { return }

        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let main = find(source.mainExercises)
        let core = find(source.coreExercises)

        generatedPlan = GeneratedWorkoutPlan(
            name: source.name,
            mainExercises: main,
            coreExercises: core,
            stretches: source.stretches,
            warmupMinutes: source.warmupMinutes,
            coreMinutes: source.coreMinutes,
            stretchMinutes: source.stretchMinutes
        )

        workoutName = defaultName(for: source.name)
    }

    // MARK: - Vinay Templates

    private enum VinayTemplate {
        case backFriendlyPush
        case backFriendlyPull
    }

    private func applyVinayTemplate(_ template: VinayTemplate) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let core: [ExerciseTemplate] = find([
            "Front Plank",
            "Side Plank",
            "Bird Dog"
        ])

        switch template {
        case .backFriendlyPush:
            let main = find([
                "Seated Dumbbell Shoulder Press",
                "Machine Chest Press",
                "Cable Chest Fly",
                "Cable Lateral Raise",
                "Triceps Rope Pushdown",
                "Overhead Dumbbell Triceps Extension",
                "Push-Up"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Back-friendly Push (Vinay)",
                mainExercises: main,
                coreExercises: core,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Vinay Push")

        case .backFriendlyPull:
            let main = find([
                "Lat Pulldown",
                "Seated Cable Row",
                "Chest-Supported Row",
                "Face Pull",
                "EZ Bar Curl",
                "Dumbbell Hammer Curl",
                "Assisted Pull-Up"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Back-friendly Pull (Vinay)",
                mainExercises: main,
                coreExercises: core,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Vinay Pull")
        }
    }

    // MARK: - Amariss Templates

    private enum AmarissTemplate {
        case day1, day2, day3, day4
    }

    private func applyAmarissTemplate(_ template: AmarissTemplate) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        switch template {
        case .day1:
            let main = find([
                "Assisted Pull-Up",
                "Seated Cable Row",
                "Rope Lat Prayer"
            ])

            let accessory = find([
                "Bird Dog",
                "Pallof Press",
                "Swiss Ball Plank"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Amariss Day 1 – Core & Pull",
                mainExercises: main,
                coreExercises: accessory,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Amariss Day 1")

        case .day2:
            let main = find([
                "Leg Press",
                "Bulgarian Split Squat",
                "Glute Bridge"
            ])

            let accessory = find([
                "Seated Leg Curl",
                "Calf Raise",
                "Farmer Carry"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Amariss Day 2 – Lower & Glutes",
                mainExercises: main,
                coreExercises: accessory,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Amariss Day 2")

        case .day3:
            let main = find([
                "Row Machine",
                "Hanging Knee Raise"
            ])

            let accessory = find([
                "Side Plank",
                "Toe Touch Crunch"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Amariss Day 3 – Row & Core",
                mainExercises: main,
                coreExercises: accessory,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Amariss Day 3")

        case .day4:
            let main = find([
                "Incline Dumbbell Press (Neutral)",
                "Machine Shoulder Press",
                "Cable Fly"
            ])

            let accessory = find([
                "Face Pull",
                "Plank to Push-Up",
                "Dead Bug"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Amariss Day 4 – Push & Posture",
                mainExercises: main,
                coreExercises: accessory,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Amariss Day 4")
        }
    }
}

// MARK: - Muscle group selector (true multi-select)

struct MuscleGroupMultiSelector: View {
    @Binding var selected: Set<MuscleGroup>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target muscles")
                .font(.headline)

            ForEach(MuscleGroup.allCases) { group in
                Toggle(isOn: binding(for: group)) {
                    Text(group.displayName)
                }
            }
        }
    }

    private func binding(for group: MuscleGroup) -> Binding<Bool> {
        Binding(
            get: { selected.contains(group) },
            set: { isOn in
                if isOn {
                    selected.insert(group)
                } else {
                    selected.remove(group)
                }
            }
        )
    }
}

#Preview {
    NewWorkoutView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
