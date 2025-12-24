import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var workout: Workout

    // All sets across ALL workouts (for last/best)
    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]
    
    @State private var showingRenameSheet = false
    @State private var pdfToShare: Data?

    var body: some View {
        List {
            // MARK: - View / edit today's plan
            Section("View/Edit Today's Plan") {
                // Primary work editor
                NavigationLink {
                    PrimaryPlanEditorView(workout: workout)
                } label: {
                    HStack {
                        Text("Primary work")
                        Spacer()
                        if !workout.mainExercises.isEmpty {
                            Text("\(workout.mainExercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Accessory / optional editor (unchanged behavior)
                NavigationLink {
                    AccessoryEditorView(workout: workout)
                } label: {
                    HStack {
                        Text("Accessory / optional")
                        Spacer()
                        if !workout.coreExercises.isEmpty {
                            Text("\(workout.coreExercises.count) exercises")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // MARK: - Log & history
            Section("Log & history") {
                ForEach(exercisesForLog, id: \.self) { exercise in
                    NavigationLink {
                        ExerciseHistoryView(workout: workout, exerciseName: exercise)
                    } label: {
                        ExerciseLogRow(exerciseName: exercise, allSets: allSets)
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingRenameSheet = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button {
                        shareWorkout()
                    } label: {
                        Label("Share as PDF", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingRenameSheet) {
            RenameWorkoutSheet(workout: workout, isPresented: $showingRenameSheet)
        }
        .sheet(item: Binding(
            get: { pdfToShare.map { PDFShareItem(data: $0, workout: workout) } },
            set: { pdfToShare = $0?.data }
        )) { item in
            ShareSheet(items: [item.fileURL])
        }
        .onDisappear {
            // Persist any edits to plan
            try? context.save()
        }
    }

    /// Exercises for THIS workout, ordered:
    /// 1. Primary (mainExercises)
    /// 2. Accessory / optional (coreExercises)
    /// 3. Any other exercises that have sets in this workout
    private var exercisesForLog: [String] {
        var ordered: [String] = []
        var seen = Set<String>()

        // Primary work in order
        for name in workout.mainExercises where !name.trimmingCharacters(in: .whitespaces).isEmpty {
            if !seen.contains(name) {
                ordered.append(name)
                seen.insert(name)
            }
        }

        // Accessory work in order
        for name in workout.coreExercises where !name.trimmingCharacters(in: .whitespaces).isEmpty {
            if !seen.contains(name) {
                ordered.append(name)
                seen.insert(name)
            }
        }

        // Any exercises that have sets in this workout but aren’t listed above
        let setNames = Set(workout.sets.map { $0.exerciseName })
        let extras = setNames.subtracting(seen)

        ordered.append(contentsOf: extras.sorted())
        return ordered
    }
    
    // MARK: - Share Function
    
    private func shareWorkout() {
        do {
            let pdfData = try PDFExporter.createPDF(for: [workout])
            pdfToShare = pdfData
        } catch {
            print("Failed to create PDF: \(error)")
        }
    }
}

// MARK: - PDF Share Helper

private struct PDFShareItem: Identifiable {
    let id = UUID()
    let data: Data
    let workout: Workout
    
    var fileURL: URL {
        let fileName = "Workout_\(workout.name.replacingOccurrences(of: " ", with: "_"))_\(Date().timeIntervalSince1970).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? data.write(to: tempURL)
        return tempURL
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Log row

private struct ExerciseLogRow: View {
    let exerciseName: String
    let allSets: [SetEntry]

    // Most recent set across all workouts
    private var lastSet: SetEntry? {
        allSets.first { $0.exerciseName == exerciseName }
    }

    // Heaviest set across all workouts
    private var bestSet: SetEntry? {
        let sets = allSets.filter { $0.exerciseName == exerciseName }
        return sets.max { a, b in
            if a.weight == b.weight {
                return a.reps < b.reps
            } else {
                return a.weight < b.weight
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exerciseName)
                .font(.headline)

            if let last = lastSet {
                Text("Last: \(formatSet(last)) • \(last.timestamp.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No sets logged yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let best = bestSet {
                Text("Best: \(formatSet(best))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatSet(_ set: SetEntry) -> String {
        let w = String(format: "%.1f", set.weight)
        return "\(w) x \(set.reps)"
    }
}

// MARK: - Primary work editor

private struct PrimaryPlanEditorView: View {
    @Bindable var workout: Workout
    @State private var showingExercisePicker = false

    var body: some View {
        Form {
            Section("Primary work") {
                ForEach(workout.mainExercises.indices, id: \.self) { index in
                    HStack {
                        Text(workout.mainExercises[index])
                        Spacer()
                        Button(role: .destructive) {
                            workout.mainExercises.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add exercise", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Primary work")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet(
                isPresented: $showingExercisePicker,
                onSelect: { exerciseName in
                    workout.mainExercises.append(exerciseName)
                }
            )
        }
    }
}

// MARK: - Accessory / optional editor

private struct AccessoryEditorView: View {
    @Bindable var workout: Workout
    @State private var showingExercisePicker = false

    var body: some View {
        Form {
            Section("Accessory / optional") {
                ForEach(workout.coreExercises.indices, id: \.self) { index in
                    HStack {
                        Text(workout.coreExercises[index])
                        Spacer()
                        Button(role: .destructive) {
                            workout.coreExercises.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    showingExercisePicker = true
                } label: {
                    Label("Add accessory exercise", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Accessory work")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet(
                isPresented: $showingExercisePicker,
                onSelect: { exerciseName in
                    workout.coreExercises.append(exerciseName)
                }
            )
        }
    }
}

// MARK: - Exercise Picker Sheet

private struct ExercisePickerSheet: View {
    @Binding var isPresented: Bool
    let onSelect: (String) -> Void
    
    @State private var searchText = ""
    @State private var selectedMuscleFilter: MuscleGroup?
    
    private var filteredExercises: [ExerciseTemplate] {
        var exercises = ExerciseLibrary.all
        
        // Filter by muscle group if selected
        if let muscle = selectedMuscleFilter {
            exercises = exercises.filter { $0.muscleGroup == muscle }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            exercises = exercises.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return exercises.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Muscle group filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedMuscleFilter == nil,
                                action: { selectedMuscleFilter = nil }
                            )
                            
                            ForEach(MuscleGroup.allCases) { muscle in
                                FilterChip(
                                    title: muscle.displayName,
                                    isSelected: selectedMuscleFilter == muscle,
                                    action: { selectedMuscleFilter = muscle }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                
                // Exercise list
                Section {
                    ForEach(filteredExercises, id: \.name) { exercise in
                        Button {
                            onSelect(exercise.name)
                            isPresented = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 8) {
                                        Text(exercise.muscleGroup.displayName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(exercise.equipment.rawValue.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rename Workout Sheet

private struct RenameWorkoutSheet: View {
    @Bindable var workout: Workout
    @Binding var isPresented: Bool
    @State private var editedName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Name") {
                    TextField("Name", text: $editedName)
                }
            }
            .navigationTitle("Rename Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        workout.name = editedName
                        isPresented = false
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                editedName = workout.name
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let demoWorkout = Workout(
        date: Date(),
        name: "Back-friendly Push (Vinay)",
        warmupMinutes: 5,
        coreMinutes: 0,
        stretchMinutes: 5,
        mainExercises: [
            "Machine Chest Press",
            "Seated Dumbbell Shoulder Press",
            "Cable Lateral Raise",
            "Cable Chest Fly",
            "Triceps Rope Pushdown",
            "Overhead Dumbbell Triceps Extension",
            "Push-Up"
        ],
        coreExercises: ["Bird Dog", "Face Pull"],
        stretches: [],
        sets: []
    )

    return NavigationStack {
        WorkoutDetailView(workout: demoWorkout)
    }
    .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
