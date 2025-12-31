import SwiftUI
import SwiftData

struct NewWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Existing workouts so we can repeat last Push/Pull
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]

    @State private var goal: Goal = .hypertrophy
    @State private var bodyweightOnly: Bool = false
    @State private var machinesOnly: Bool = false
    @State private var freeWeightsOnly: Bool = false

    @State private var warmupMinutes: Double = 5
    @State private var coreMinutes: Double = 5
    @State private var stretchMinutes: Double = 5

    @State private var selectedMuscles: Set<MuscleGroup> = []
    @State private var generatedPlan: GeneratedWorkoutPlan?

    // Editable workout name
    @State private var workoutName: String = ""
    
    // Notes field
    @State private var workoutNotes: String = ""
    
    // Collapsible sections
    @State private var isRecentWorkoutsExpanded: Bool = false
    @State private var isGeneratorOptionsExpanded: Bool = false
    @State private var isExercisesExpanded: Bool = true

    // NEW: Cascading template system
    private enum TemplateType: String, CaseIterable, Identifiable {
        case vinay = "Vin Pull/Push (Back friendly)"
        case ppl = "Push/Pull/Legs (PPL)"
        case amariss = "Amariss Personal Trainer"
        case broSplit = "Bro Split"
        case stronglifts = "StrongLifts 5×5"
        case madcow = "Madcow 5×5"
        case fullBody = "Full Body"
        case calisthenics = "Calisthenics"
        case custom = "Custom"

        var id: Self { self }
    }
    
    private enum VinayDay: String, CaseIterable, Identifiable {
        case pull = "Pull"
        case push = "Push"
        case legs = "Legs"
        var id: Self { self }
    }
    
    private enum PPLDay: String, CaseIterable, Identifiable {
        case pull = "Pull"
        case push = "Push"
        case legs = "Legs"
        var id: Self { self }
    }
    
    private enum AmarissDay: String, CaseIterable, Identifiable {
        case day1 = "Day 1"
        case day2 = "Day 2"
        case day3 = "Day 3"
        case day4 = "Day 4"
        var id: Self { self }
    }
    
    private enum BroSplitDay: String, CaseIterable, Identifiable {
        case chest = "Chest Day"
        case back = "Back Day"
        case shoulders = "Shoulder Day"
        case legs = "Leg Day"
        case arms = "Arm Day"
        var id: Self { self }
    }
    
    private enum StrongLiftsDay: String, CaseIterable, Identifiable {
        case workoutA = "Workout A"
        case workoutB = "Workout B"
        var id: Self { self }
    }
    
    private enum MadcowDay: String, CaseIterable, Identifiable {
        case mondayVolume = "Monday (Volume Day)"
        case wednesdayLight = "Wednesday (Light Day)"
        case fridayIntensity = "Friday (Intensity Day)"
        var id: Self { self }
    }

    @State private var selectedTemplateType: TemplateType = .vinay
    @State private var selectedVinayDay: VinayDay = .push
    @State private var selectedPPLDay: PPLDay = .push
    @State private var selectedAmarissDay: AmarissDay = .day1
    @State private var selectedBroSplitDay: BroSplitDay = .chest
    @State private var selectedStrongLiftsDay: StrongLiftsDay = .workoutA
    @State private var selectedMadcowDay: MadcowDay = .mondayVolume

    var body: some View {
        NavigationStack {
            Form {
                // QUICK TEMPLATES - Cascading Dropdowns
                Section("Quick templates") {
                    Picker("Template", selection: $selectedTemplateType) {
                        ForEach(TemplateType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .onChange(of: selectedTemplateType) {
                        // Auto-apply when template type changes
                        applySelectedTemplate()
                    }
                    
                    // Second dropdown based on selection
                    switch selectedTemplateType {
                    case .vinay:
                        Picker("Day", selection: $selectedVinayDay) {
                            ForEach(VinayDay.allCases) { day in
                                Text(day.rawValue).tag(day)
                            }
                        }
                        .onChange(of: selectedVinayDay) {
                            applySelectedTemplate()
                        }
                    case .ppl:
                        Picker("Day", selection: $selectedPPLDay) {
                            ForEach(PPLDay.allCases) { day in
                                Text(day.rawValue).tag(day)
                            }
                        }
                        .onChange(of: selectedPPLDay) {
                            applySelectedTemplate()
                        }
                    case .amariss:
                        Picker("Day", selection: $selectedAmarissDay) {
                            ForEach(AmarissDay.allCases) { day in
                                Text(day.rawValue).tag(day)
                            }
                        }
                        .onChange(of: selectedAmarissDay) {
                            applySelectedTemplate()
                        }
                    case .broSplit:
                        Picker("Day", selection: $selectedBroSplitDay) {
                            ForEach(BroSplitDay.allCases) { day in
                                Text(day.rawValue).tag(day)
                            }
                        }
                        .onChange(of: selectedBroSplitDay) {
                            applySelectedTemplate()
                        }
                    case .stronglifts:
                        Picker("Workout", selection: $selectedStrongLiftsDay) {
                            ForEach(StrongLiftsDay.allCases) { day in
                                Text(day.rawValue).tag(day)
                            }
                        }
                        .onChange(of: selectedStrongLiftsDay) {
                            applySelectedTemplate()
                        }
                    case .madcow:
                        Picker("Day", selection: $selectedMadcowDay) {
                            ForEach(MadcowDay.allCases) { day in
                                Text(day.rawValue).tag(day)
                            }
                        }
                        .onChange(of: selectedMadcowDay) {
                            applySelectedTemplate()
                        }
                    case .fullBody, .calisthenics:
                        // No second dropdown needed
                        EmptyView()
                    case .custom:
                        // Will show muscle selector below
                        EmptyView()
                    }
                }

                // WORKOUT NAME
                Section("Workout name") {
                    TextField("Name", text: $workoutName)
                }

                // RECENT WORKOUTS (Collapsible)
                DisclosureGroup("Recent workouts", isExpanded: $isRecentWorkoutsExpanded) {
                    Button("Use last Push workout") {
                        applyLastWorkout(containing: "Push")
                    }
                    .disabled(lastWorkout(containing: "Push") == nil)

                    Button("Use last Pull workout") {
                        applyLastWorkout(containing: "Pull")
                    }
                    .disabled(lastWorkout(containing: "Pull") == nil)
                }

                // GENERATOR OPTIONS (Collapsible)
                DisclosureGroup("Generator options", isExpanded: $isGeneratorOptionsExpanded) {
                    Picker("Goal", selection: $goal) {
                        ForEach(Goal.allCases) { g in
                            Text(g.displayName).tag(g)
                        }
                    }

                    Toggle("Bodyweight only", isOn: $bodyweightOnly)
                        .onChange(of: bodyweightOnly) { _, newValue in
                            if newValue {
                                machinesOnly = false
                                freeWeightsOnly = false
                            }
                        }
                    
                    Toggle("Machines only", isOn: $machinesOnly)
                        .onChange(of: machinesOnly) { _, newValue in
                            if newValue {
                                bodyweightOnly = false
                                freeWeightsOnly = false
                            }
                        }
                    
                    Toggle("Free weights only", isOn: $freeWeightsOnly)
                        .onChange(of: freeWeightsOnly) { _, newValue in
                            if newValue {
                                bodyweightOnly = false
                                machinesOnly = false
                            }
                        }

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

                    if selectedTemplateType == .custom {
                        MuscleGroupMultiSelector(selected: $selectedMuscles)
                    }

                    Button("Generate suggestion") {
                        generateWorkoutSuggestion()
                    }
                    .foregroundColor(.blue)
                }

                // EXERCISES (Collapsible)
                if let plan = generatedPlan {
                    DisclosureGroup("Exercises", isExpanded: $isExercisesExpanded) {
                        VStack(alignment: .leading, spacing: 12) {
                            if !plan.mainExercises.isEmpty {
                                Text("Main exercises")
                                    .font(.headline)
                                    .padding(.top, 4)
                                
                                ForEach(plan.mainExercises, id: \.name) { ex in
                                    Text("• \(ex.name)")
                                        .font(.subheadline)
                                }
                            }
                            
                            if !plan.coreExercises.isEmpty {
                                Text("Accessory / Core")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                ForEach(plan.coreExercises, id: \.name) { ex in
                                    Text("• \(ex.name)")
                                        .font(.subheadline)
                                }
                            }
                            
                            if !plan.stretches.isEmpty {
                                Text("Stretches")
                                    .font(.headline)
                                    .padding(.top, 8)
                                
                                ForEach(plan.stretches, id: \.self) { s in
                                    Text("• \(s)")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // NOTES SECTION
                Section("Notes (optional)") {
                    TextEditor(text: $workoutNotes)
                        .frame(minHeight: 100)
                    Text("Add links from Facebook, YouTube, or notes about this workout")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
            .onAppear {
                // Load initial template
                applySelectedTemplate()
            }
        }
    }

    // MARK: - Apply Selected Template
    
    private func applySelectedTemplate() {
        switch selectedTemplateType {
        case .vinay:
            applyVinayTemplate(selectedVinayDay)
        case .ppl:
            applyPPLTemplate(selectedPPLDay)
        case .amariss:
            applyAmarissTemplate(selectedAmarissDay)
        case .broSplit:
            applyBroSplitTemplate(selectedBroSplitDay)
        case .stronglifts:
            applyStrongLiftsTemplate(selectedStrongLiftsDay)
        case .madcow:
            applyMadcowTemplate(selectedMadcowDay)
        case .fullBody:
            applyFullBodyTemplate()
        case .calisthenics:
            applyCalisthenicsTemplate()
        case .custom:
            // Custom uses the muscle selector and generate button
            return
        }
    }
    
    // MARK: - Generate Suggestion
    
    private func generateWorkoutSuggestion() {
        let mode: WorkoutMode
        
        switch selectedTemplateType {
        case .vinay, .ppl:
            // Already handled by templates
            return
        case .custom:
            mode = .muscleGroups
        case .fullBody:
            mode = .full
        case .calisthenics:
            mode = .calisthenics
        case .amariss, .broSplit, .stronglifts, .madcow:
            // Already handled by templates
            return
        }
        
        let plan = WorkoutGenerator.generate(
            mode: mode,
            goal: goal,
            selectedMuscles: selectedMuscles,
            calisthenicsOnly: bodyweightOnly,
            machinesOnly: machinesOnly,
            freeWeightsOnly: freeWeightsOnly,
            warmupMinutes: Int(warmupMinutes),
            coreMinutes: Int(coreMinutes),
            stretchMinutes: Int(stretchMinutes)
        )
        generatedPlan = plan
        workoutName = defaultName(for: plan.name)
    }

    // MARK: - Naming helper

    private func defaultName(for base: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"  // e.g., "Mon, Dec 23"
        let day = formatter.string(from: Date())
        return "\(day) - \(base)"
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
            notes: workoutNotes,
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
        workoutNotes = source.notes
    }

    // MARK: - Vinay Templates

    private func applyVinayTemplate(_ day: VinayDay) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let core: [ExerciseTemplate] = find([
            "Front Plank",
            "Side Plank",
            "Bird Dog"
        ])

        switch day {
        case .push:
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
                name: "Vinay Push (Back-friendly)",
                mainExercises: main,
                coreExercises: core,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Vinay Push")

        case .pull:
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
                name: "Vinay Pull (Back-friendly)",
                mainExercises: main,
                coreExercises: core,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Vinay Pull")
            
        case .legs:
            let main = find([
                "Leg Press",
                "Goblet Squat",
                "Leg Extension",
                "Leg Curl"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Vinay Legs (Back-friendly)",
                mainExercises: main,
                coreExercises: core,
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Vinay Legs")
        }
    }
    
    // MARK: - PPL Templates
    
    private func applyPPLTemplate(_ day: PPLDay) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let core = ExerciseLibrary.coreExercises.shuffled().prefix(3)

        switch day {
        case .push:
            let main = find([
                "Flat Dumbbell Bench Press",
                "Incline Dumbbell Press",
                "Seated Dumbbell Shoulder Press",
                "Cable Lateral Raise",
                "Triceps Rope Pushdown",
                "Overhead Dumbbell Triceps Extension"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "PPL - Push Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "PPL Push")

        case .pull:
            let main = find([
                "Lat Pulldown",
                "Seated Cable Row",
                "Face Pull",
                "EZ Bar Curl",
                "Dumbbell Hammer Curl"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "PPL - Pull Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "PPL Pull")
            
        case .legs:
            let main = find([
                "Leg Press",
                "Goblet Squat",
                "Leg Extension",
                "Leg Curl"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "PPL - Leg Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "PPL Legs")
        }
    }

    // MARK: - Amariss Templates

    private func applyAmarissTemplate(_ day: AmarissDay) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        switch day {
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
    
    // MARK: - Bro Split Templates
    
    private func applyBroSplitTemplate(_ day: BroSplitDay) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let core = ExerciseLibrary.coreExercises.shuffled().prefix(3)

        switch day {
        case .chest:
            let main = find([
                "Flat Dumbbell Bench Press",
                "Incline Dumbbell Press",
                "Machine Chest Press",
                "Cable Chest Fly",
                "Push-Up"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Bro Split - Chest Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Chest Day")

        case .back:
            let main = find([
                "Lat Pulldown",
                "Seated Cable Row",
                "Chest-Supported Row",
                "Face Pull",
                "Assisted Pull-Up"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Bro Split - Back Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Back Day")
            
        case .shoulders:
            let main = find([
                "Seated Dumbbell Shoulder Press",
                "Cable Lateral Raise",
                "Face Pull"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Bro Split - Shoulder Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Shoulder Day")
            
        case .legs:
            let main = find([
                "Leg Press",
                "Goblet Squat",
                "Leg Extension",
                "Leg Curl",
                "Bodyweight Squat"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Bro Split - Leg Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Leg Day")
            
        case .arms:
            let main = find([
                "EZ Bar Curl",
                "Dumbbell Hammer Curl",
                "Triceps Rope Pushdown",
                "Overhead Dumbbell Triceps Extension",
                "Bench Dip (feet on floor)"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Bro Split - Arm Day",
                mainExercises: main,
                coreExercises: Array(core),
                stretches: ExerciseLibrary.stretchSuggestionsBase,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = defaultName(for: "Arm Day")
        }
    }
    
    // MARK: - StrongLifts 5×5 Templates
    
    private func applyStrongLiftsTemplate(_ day: StrongLiftsDay) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let stretches = [
            "Hip flexor stretch",
            "Quad stretch",
            "Hamstring stretch"
        ]

        switch day {
        case .workoutA:
            let main = find([
                "Barbell Squat",
                "Bench Press",
                "Bent Over Row"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "StrongLifts 5×5 - Workout A",
                mainExercises: main,
                coreExercises: [],
                stretches: stretches,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: 0,
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = "StrongLifts 5×5 - Workout A"
            workoutNotes = "5 sets × 5 reps for each exercise. Add 5 lbs (2.5kg) each workout if you complete all sets."

        case .workoutB:
            let main = find([
                "Barbell Squat",
                "Overhead Press",
                "Deadlift"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "StrongLifts 5×5 - Workout B",
                mainExercises: main,
                coreExercises: [],
                stretches: stretches,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: 0,
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = "StrongLifts 5×5 - Workout B"
            workoutNotes = "Squat & Overhead Press: 5×5. Deadlift: 1×5 (only one heavy set). Add 5 lbs (2.5kg) each workout."
        }
    }
    
    // MARK: - Madcow 5×5 Templates
    
    private func applyMadcowTemplate(_ day: MadcowDay) {
        func find(_ names: [String]) -> [ExerciseTemplate] {
            ExerciseLibrary.all.filter { names.contains($0.name) }
        }

        let stretches = [
            "Hip flexor stretch",
            "Quad stretch",
            "Hamstring stretch"
        ]

        switch day {
        case .mondayVolume:
            let main = find([
                "Barbell Squat",
                "Bench Press",
                "Bent Over Row"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Madcow 5×5 - Monday (Volume Day)",
                mainExercises: main,
                coreExercises: [],
                stretches: stretches,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: 0,
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = "Madcow 5×5 - Monday (Volume)"
            workoutNotes = "5×5 ramping sets (12.5%, 25%, 50%, 75%, 100% of 5RM). Week-to-week progression."

        case .wednesdayLight:
            let main = find([
                "Barbell Squat",
                "Overhead Press",
                "Deadlift"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Madcow 5×5 - Wednesday (Light Day)",
                mainExercises: main,
                coreExercises: [],
                stretches: stretches,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: 0,
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = "Madcow 5×5 - Wednesday (Light)"
            workoutNotes = "4×5 at 80% of Monday's weight. Recovery day - lighter volume."

        case .fridayIntensity:
            let main = find([
                "Barbell Squat",
                "Bench Press",
                "Deadlift"
            ])

            generatedPlan = GeneratedWorkoutPlan(
                name: "Madcow 5×5 - Friday (Intensity Day)",
                mainExercises: main,
                coreExercises: [],
                stretches: stretches,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: 0,
                stretchMinutes: Int(stretchMinutes)
            )

            workoutName = "Madcow 5×5 - Friday (Intensity)"
            workoutNotes = "4×5 ramping sets, then 1×3 at new PR weight (105% of Monday). Top set should be a new 3RM."
        }
    }
    
    // MARK: - Full Body Template
    
    private func applyFullBodyTemplate() {
        let plan = WorkoutGenerator.generate(
            mode: .full,
            goal: goal,
            selectedMuscles: [],
            calisthenicsOnly: bodyweightOnly,
            machinesOnly: machinesOnly,
            freeWeightsOnly: freeWeightsOnly,
            warmupMinutes: Int(warmupMinutes),
            coreMinutes: Int(coreMinutes),
            stretchMinutes: Int(stretchMinutes)
        )
        generatedPlan = plan
        workoutName = defaultName(for: "Full Body")
    }
    
    // MARK: - Calisthenics Template
    
    private func applyCalisthenicsTemplate() {
        let plan = WorkoutGenerator.generate(
            mode: .calisthenics,
            goal: goal,
            selectedMuscles: [],
            calisthenicsOnly: true,
            machinesOnly: false,
            freeWeightsOnly: false,
            warmupMinutes: Int(warmupMinutes),
            coreMinutes: Int(coreMinutes),
            stretchMinutes: Int(stretchMinutes)
        )
        generatedPlan = plan
        workoutName = defaultName(for: "Calisthenics")
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
