import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var context

    @Bindable var workout: Workout
    let exerciseName: String

    // All sets across all workouts (for PR & global history)
    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

    // Local input state
    @State private var weightText: String = ""
    @State private var repsText: String = ""

    // PR banner state
    @State private var prMessage: String? = nil

    // MARK: - Derived sets

    private var setsForExercise: [SetEntry] {
        allSets.filter { $0.exerciseName == exerciseName }
    }

    private var todaySets: [SetEntry] {
        workout.sets.filter { $0.exerciseName == exerciseName }
    }

    // MARK: - Global bests (before adding new set)

    private var bestWeightSoFar: Double {
        setsForExercise.map(\.weight).max() ?? 0
    }

    private var best1RMSoFar: Double {
        setsForExercise
            .map { estimated1RM(weight: $0.weight, reps: $0.reps) }
            .max() ?? 0
    }

    // MARK: - Body

    var body: some View {
        List {
            // Progressive Overload Indicator
            if let lastWorkoutData = getLastWorkoutComparison() {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: lastWorkoutData.icon)
                                .foregroundColor(lastWorkoutData.color)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Last Workout")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(lastWorkoutData.message)
                                    .font(.subheadline.weight(.semibold))
                            }
                            
                            Spacer()
                        }
                        
                        // Show best set from last workout
                        if let bestSet = lastWorkoutData.bestSet {
                            HStack {
                                Text("Target to beat:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Text("\(formatWeight(bestSet.weight)) × \(bestSet.reps)")
                                    .font(.caption.bold())
                                    .foregroundColor(lastWorkoutData.color)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(lastWorkoutData.color.opacity(0.1))
                )
            }
            
            // PR banner
            if let msg = prMessage {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                            .symbolEffect(.bounce, value: prMessage)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Personal Record!")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                            Text(msg)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow.opacity(0.15))
                )
            }

            // Add set
            Section("Add set") {
                Text(exerciseName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Weight", text: $weightText)
                    .keyboardType(.decimalPad)

                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)

                Button("Add set") {
                    addSet()
                }
                .disabled(weightText.isEmpty || repsText.isEmpty)
            }

            // Today
            Section("This workout") {
                if todaySets.isEmpty {
                    Text("No sets logged yet.")
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

            // All-time history
            Section("All sets (all workouts)") {
                if setsForExercise.isEmpty {
                    Text("No sets logged yet.")
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

    // MARK: - Add set + PR detection

    private func addSet() {
        guard let weight = Double(weightText),
              let reps = Int(repsText),
              reps > 0 else { return }

        // PR detection BEFORE save
        let new1RM = estimated1RM(weight: weight, reps: reps)

        var newPRMessages: [String] = []

        if weight > bestWeightSoFar {
            newPRMessages.append("Heaviest weight")
        }

        if new1RM > best1RMSoFar {
            newPRMessages.append("Estimated 1RM")
        }

        // Save set
        let newSet = SetEntry(
            exerciseName: exerciseName,
            weight: weight,
            reps: reps
        )

        workout.sets.append(newSet)
        context.insert(newSet)
        try? context.save()

        // Show PR banner if needed
        if !newPRMessages.isEmpty {
            prMessage = "New PR! " + newPRMessages.joined(separator: " • ")

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    prMessage = nil
                }
            }
        }

        weightText = ""
        repsText = ""
    }

    // MARK: - Helpers

    private func estimated1RM(weight: Double, reps: Int) -> Double {
        weight * (1 + Double(reps) / 30.0)
    }

    private func formatWeight(_ w: Double) -> String {
        String(format: "%.1f", w)
    }
    
    // MARK: - Progressive Overload
    
    private struct LastWorkoutData {
        let message: String
        let icon: String
        let color: Color
        let bestSet: SetEntry?
    }
    
    private func getLastWorkoutComparison() -> LastWorkoutData? {
        // Find the last workout (before today's) that had this exercise
        let previousWorkouts = allSets
            .filter { $0.exerciseName == exerciseName }
            .filter { !calendar.isDate($0.timestamp, inSameDayAs: Date()) }
        
        guard !previousWorkouts.isEmpty else { return nil }
        
        // Get the best set from the last workout
        let lastWorkoutBestSet = previousWorkouts.first // Already sorted by timestamp desc
        
        guard let lastBest = lastWorkoutBestSet else { return nil }
        
        // Compare with today's best set (if any)
        if let todayBest = todaySets.max(by: { a, b in
            if a.weight == b.weight {
                return a.reps < b.reps
            }
            return a.weight < b.weight
        }) {
            // We have logged sets today, compare them
            if todayBest.weight > lastBest.weight || (todayBest.weight == lastBest.weight && todayBest.reps > lastBest.reps) {
                return LastWorkoutData(
                    message: "You beat your last workout! 💪",
                    icon: "arrow.up.circle.fill",
                    color: .green,
                    bestSet: lastBest
                )
            } else if todayBest.weight == lastBest.weight && todayBest.reps == lastBest.reps {
                return LastWorkoutData(
                    message: "Matched your last workout",
                    icon: "arrow.right.circle.fill",
                    color: .blue,
                    bestSet: lastBest
                )
            } else {
                return LastWorkoutData(
                    message: "Try to beat your last workout",
                    icon: "arrow.down.circle.fill",
                    color: .orange,
                    bestSet: lastBest
                )
            }
        } else {
            // No sets logged today yet, show target
            return LastWorkoutData(
                message: "Target for today",
                icon: "target",
                color: .blue,
                bestSet: lastBest
            )
        }
    }
    
    private var calendar: Calendar {
        Calendar.current
    }
}

#Preview {
    let w = Workout(
        date: Date(),
        name: "Demo Workout",
        mainExercises: ["Lat Pulldown"],
        sets: []
    )

    return NavigationStack {
        ExerciseHistoryView(workout: w, exerciseName: "Lat Pulldown")
    }
    .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
