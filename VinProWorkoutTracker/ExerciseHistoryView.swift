import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var context

    @Bindable var workout: Workout
    let exerciseName: String

    // All sets across all workouts (for PR & global history)
    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

    // Local input state for adding a set
    @State private var weightText: String = ""
    @State private var repsText: String = ""

    // Global last/best for quick-fill buttons
    private var lastGlobalSet: SetEntry? {
        allSets.first { $0.exerciseName == exerciseName }
    }

    private var bestGlobalSet: SetEntry? {
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
        let setsForExercise = allSets.filter { $0.exerciseName == exerciseName }
        let todaySets = workout.sets.filter { $0.exerciseName == exerciseName }

        List {
            // Add set
            Section("Add set") {
                Text(exerciseName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Weight", text: $weightText)
                    .keyboardType(.decimalPad)

                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)

                // Quick-fill bar
                if lastGlobalSet != nil || bestGlobalSet != nil {
                    HStack {
                        if let last = lastGlobalSet {
                            Button("Last \(formatWeight(last.weight))") {
                                weightText = formatWeight(last.weight)
                            }
                        }
                        if let best = bestGlobalSet {
                            Button("Best \(formatWeight(best.weight))") {
                                weightText = formatWeight(best.weight)
                            }
                        }

                        Button("-5") {
                            adjustWeight(by: -5)
                        }
                        Button("+5") {
                            adjustWeight(by: 5)
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }

                Button("Add set") {
                    addSet()
                }
                .disabled(weightText.isEmpty || repsText.isEmpty)
            }

            // Today in this workout
            Section("This workout") {
                if todaySets.isEmpty {
                    Text("No sets logged yet for \(exerciseName) in this workout.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(todaySets.sorted(by: { $0.timestamp > $1.timestamp })) { set in
                        HStack {
                            Text(set.timestamp.formatted(date: .omitted, time: .shortened))
                            Spacer()
                            Text("\(formatWeight(set.weight)) x \(set.reps)")
                        }
                    }
                }
            }

            // All-time PR and history
            let best = bestSet(sets: setsForExercise)
            if let best = best {
                Section("Personal record") {
                    Text("Best: \(formatWeight(best.weight)) x \(best.reps)")
                }
            }

            Section("All sets (all workouts)") {
                if setsForExercise.isEmpty {
                    Text("No sets logged yet for \(exerciseName).")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(setsForExercise) { set in
                        HStack {
                            Text(set.timestamp.formatted(date: .abbreviated, time: .shortened))
                            Spacer()
                            Text("\(formatWeight(set.weight)) x \(set.reps)")
                        }
                    }
                }
            }
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bestSet(sets: [SetEntry]) -> SetEntry? {
        sets.max { a, b in
            if a.weight == b.weight {
                return a.reps < b.reps
            } else {
                return a.weight < b.weight
            }
        }
    }

    private func addSet() {
        guard let weight = Double(weightText),
              let reps = Int(repsText) else { return }

        let newSet = SetEntry(
            exerciseName: exerciseName,
            weight: weight,
            reps: reps
        )

        // Attach to this workout and context
        workout.sets.append(newSet)
        context.insert(newSet)
        try? context.save()

        weightText = ""
        repsText = ""
    }

    private func formatWeight(_ w: Double) -> String {
        String(format: "%.1f", w)
    }

    private func adjustWeight(by delta: Double) {
        let current: Double
        if let val = Double(weightText) {
            current = val
        } else if let last = lastGlobalSet?.weight {
            current = last
        } else {
            current = 0
        }

        let newVal = max(0, current + delta)
        weightText = formatWeight(newVal)
    }
}

#Preview {
    let w = Workout(
        date: Date(),
        name: "Demo Workout",
        warmupMinutes: 5,
        coreMinutes: 5,
        stretchMinutes: 5,
        mainExercises: ["Dumbbell Hammer Curl"],
        coreExercises: [],
        stretches: [],
        sets: []
    )

    return NavigationStack {
        ExerciseHistoryView(workout: w, exerciseName: "Dumbbell Hammer Curl")
    }
    .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
