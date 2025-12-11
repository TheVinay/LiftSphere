import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var workout: Workout

    // All sets across ALL workouts (for last/best)
    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

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
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
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

    var body: some View {
        Form {
            Section("Primary work") {
                ForEach(workout.mainExercises.indices, id: \.self) { index in
                    HStack {
                        TextField("Exercise", text: $workout.mainExercises[index])
                        Button(role: .destructive) {
                            workout.mainExercises.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    workout.mainExercises.append("")
                } label: {
                    Label("Add exercise", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Primary work")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Accessory / optional editor (unchanged)

private struct AccessoryEditorView: View {
    @Bindable var workout: Workout

    var body: some View {
        Form {
            Section("Accessory / optional") {
                ForEach(workout.coreExercises.indices, id: \.self) { index in
                    HStack {
                        TextField("Exercise", text: $workout.coreExercises[index])
                        Button(role: .destructive) {
                            workout.coreExercises.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    workout.coreExercises.append("")
                } label: {
                    Label("Add accessory exercise", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Accessory work")
        .navigationBarTitleDisplayMode(.inline)
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
