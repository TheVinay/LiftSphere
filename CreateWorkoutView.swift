import SwiftUI
import SwiftData

/// Simplified workout creation view - fast path for creating workouts.
/// Users can save immediately (empty workout) or generate exercises using the generator.
struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // Workout properties
    @State private var workoutName: String = ""
    @State private var workoutNotes: String = ""
    
    // Generator options
    @State private var isGeneratorExpanded: Bool = true
    @State private var isMuscleSelectionExpanded: Bool = false
    @State private var goal: Goal = .hypertrophy
    @State private var bodyweightOnly: Bool = false
    @State private var machinesOnly: Bool = false
    @State private var freeWeightsOnly: Bool = false
    @State private var warmupMinutes: Double = 5
    @State private var coreMinutes: Double = 5
    @State private var stretchMinutes: Double = 5
    @State private var selectedMuscles: Set<MuscleGroup> = []
    
    // Generated plan (optional)
    @State private var generatedPlan: GeneratedWorkoutPlan?
    @State private var isExercisesExpanded: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                // WORKOUT NAME
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        TextField("Workout name", text: $workoutName)
                            .font(.body)
                    }
                } header: {
                    Text("Workout Name")
                } footer: {
                    Text("You can edit this later")
                        .font(.caption)
                }
                
                // GENERATOR SECTION
                Section {
                    VStack(spacing: 16) {
                        // Goal picker (inline segmented style)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Goal")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Picker("Goal", selection: $goal) {
                                ForEach(Goal.allCases) { g in
                                    Text(g.displayName).tag(g)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Equipment filters
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
                        
                        // Muscle selector (collapsible)
                        DisclosureGroup("Target Muscles (Optional)", isExpanded: $isMuscleSelectionExpanded) {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(MuscleGroup.allCases) { group in
                                    Toggle(isOn: binding(for: group)) {
                                        Text(group.displayName)
                                            .font(.subheadline)
                                    }
                                    .toggleStyle(.button)
                                    .tint(.blue)
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        // Generate button
                        Button {
                            generateWorkout()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Generate Workout")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                } footer: {
                    Text("Generate a workout plan, or save now and add exercises manually later")
                        .font(.caption)
                }
                
                // EXERCISES (Only shown if generated)
                if let plan = generatedPlan {
                    Section {
                        DisclosureGroup(isExpanded: $isExercisesExpanded) {
                            VStack(alignment: .leading, spacing: 12) {
                                if !plan.mainExercises.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "dumbbell.fill")
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                        Text("Main Exercises")
                                            .font(.headline)
                                    }
                                    .padding(.top, 4)
                                    
                                    ForEach(plan.mainExercises, id: \.name) { ex in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.blue, .purple],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 6, height: 6)
                                            Text(ex.name)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                
                                if !plan.coreExercises.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "figure.core.training")
                                            .font(.subheadline)
                                            .foregroundStyle(.orange)
                                        Text("Accessory / Core")
                                            .font(.headline)
                                    }
                                    .padding(.top, 8)
                                    
                                    ForEach(plan.coreExercises, id: \.name) { ex in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(Color.orange)
                                                .frame(width: 6, height: 6)
                                            Text(ex.name)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                
                                if !plan.stretches.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "figure.flexibility")
                                            .font(.subheadline)
                                            .foregroundStyle(.green)
                                        Text("Stretches")
                                            .font(.headline)
                                    }
                                    .padding(.top, 8)
                                    
                                    ForEach(plan.stretches, id: \.self) { s in
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 6, height: 6)
                                            Text(s)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "list.bullet.clipboard.fill")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Text("Exercises (\(plan.mainExercises.count + plan.coreExercises.count))")
                                    .font(.headline)
                            }
                        }
                    } header: {
                        Text("Generated Plan")
                    }
                }
                
                // NOTES (Optional)
                Section("Notes (Optional)") {
                    TextEditor(text: $workoutNotes)
                        .frame(minHeight: 80)
                    
                    Text("Add links from Facebook, YouTube, or notes about this workout")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
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
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .disabled(generatedPlan == nil)
                }
            }
            .onAppear {
                // Pre-fill workout name with today's date
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE, MMM d"
                workoutName = "\(formatter.string(from: Date())) - Workout"
            }
        }
    }
    
    // MARK: - Generate Workout
    
    private func generateWorkout() {
        let mode: WorkoutMode = selectedMuscles.isEmpty ? .full : .muscleGroups
        
        let plan = WorkoutGenerator.generate(
            mode: mode,
            goal: goal,
            selectedMuscles: selectedMuscles,
            calisthenicsOnly: bodyweightOnly,
            machinesOnly: machinesOnly,
            freeWeightsOnly: freeWeightsOnly,
            warmupMinutes: Int(warmupMinutes),
            coreMinutes: Int(coreMinutes),
            stretchMinutes: Int(stretchMinutes),
            context: context
        )
        
        generatedPlan = plan
        
        // Auto-expand exercises section
        withAnimation {
            isExercisesExpanded = true
        }
    }
    
    // MARK: - Save Workout
    
    private func saveWorkout() {
        let finalName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If user generated a plan, use it; otherwise create empty workout
        if let plan = generatedPlan {
            let workout = Workout(
                date: Date(),
                name: finalName.isEmpty ? "Workout" : finalName,
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
        } else {
            // Create empty workout - user will add exercises manually
            let workout = Workout(
                date: Date(),
                name: finalName.isEmpty ? "Workout" : finalName,
                warmupMinutes: Int(warmupMinutes),
                coreMinutes: Int(coreMinutes),
                stretchMinutes: Int(stretchMinutes),
                mainExercises: [],
                coreExercises: [],
                stretches: [],
                notes: workoutNotes,
                sets: []
            )
            
            context.insert(workout)
        }
        
        try? context.save()
        dismiss()
    }
    
    // MARK: - Muscle Selection Helper
    
    private func binding(for group: MuscleGroup) -> Binding<Bool> {
        Binding(
            get: { selectedMuscles.contains(group) },
            set: { isOn in
                if isOn {
                    selectedMuscles.insert(group)
                } else {
                    selectedMuscles.remove(group)
                }
            }
        )
    }
}

#Preview {
    CreateWorkoutView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
