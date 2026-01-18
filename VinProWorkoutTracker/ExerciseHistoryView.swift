import SwiftUI
import SwiftData
import UIKit

struct ExerciseHistoryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var workout: Workout
    let exerciseName: String
    
    // HealthKit manager for bodyweight pre-fill
    @State private var healthKitManager = HealthKitManager()
    
    // Weight unit preference
    @AppStorage("weightUnit") private var weightUnit: String = "lbs"

    // All sets across all workouts (for PR & global history)
    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

    // Local input state
    @State private var weightText: String = ""
    @State private var repsText: String = ""

    // PR banner state
    @State private var prMessage: String? = nil
    
    // Expandable exercise info section
    @State private var isExerciseInfoExpanded: Bool = false
    
    // Expandable all sets history
    @State private var isAllSetsExpanded: Bool = false
    
    // Edit mode
    @State private var editingSet: SetEntry? = nil
    @State private var editWeight: String = ""
    @State private var editReps: String = ""
    
    // 1RM tracking
    @State private var showLog1RM: Bool = false
    @State private var oneRMWeight: String = ""

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
    
    // MARK: - 1RM Tracking
    
    private var tested1RM: SetEntry? {
        setsForExercise.filter { $0.isOneRepMax }.max(by: { $0.weight < $1.weight })
    }
    
    private var estimated1RM: Double {
        best1RMSoFar
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

                TextField("Weight (\(weightUnit))", text: $weightText)
                    .keyboardType(.decimalPad)

                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)

                Button("Add set") {
                    addSet()
                }
                .foregroundStyle(.blue)
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            startEditing(set)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteSet(set)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                repeatSet(set)
                            } label: {
                                Label("Repeat", systemImage: "arrow.counterclockwise")
                            }
                            .tint(.green)
                            
                            Button {
                                startEditing(set)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
            
            // 1RM Section (moved below "This workout")
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("1 Rep Max")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 16) {
                                // Estimated
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Estimated")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text(estimated1RM > 0 ? "\(formatWeight(estimated1RM)) lbs" : "—")
                                        .font(.subheadline.bold())
                                }
                                
                                // Tested
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Tested")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    if let tested = tested1RM {
                                        Text("\(formatWeight(tested.weight)) lbs")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [.orange, .red],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    } else {
                                        Text("—")
                                            .font(.subheadline.bold())
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            showLog1RM = true
                            oneRMWeight = tested1RM != nil ? String(tested1RM!.weight) : ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    // Show date of tested 1RM if available
                    if let tested = tested1RM {
                        Text("Logged \(tested.timestamp.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            // All-time history (Collapsible)
            Section {
                DisclosureGroup(
                    isExpanded: $isAllSetsExpanded
                ) {
                    if setsForExercise.isEmpty {
                        Text("No sets logged yet.")
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(setsForExercise) { set in
                            HStack {
                                Text(set.timestamp.formatted(date: .abbreviated, time: .shortened))
                                Spacer()
                                Text("\(formatWeight(set.weight)) x \(set.reps)")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                startEditing(set)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteSet(set)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    startEditing(set)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Logged Workouts")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(setsForExercise.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Historical Data")
            }
            
            // Exercise Information (Expandable)
            Section {
                DisclosureGroup(
                    isExpanded: $isExerciseInfoExpanded
                ) {
                    VStack(spacing: 24) {
                        // Muscles
                        exerciseInfoCard(
                            icon: "figure.strengthtraining.traditional",
                            title: "Primary Muscles",
                            content: ExerciseDatabase.primaryMuscles(for: exerciseName) ?? "Not available"
                        )
                        
                        // How-To
                        if let instructions = ExerciseDatabase.instructions(for: exerciseName) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "book.closed")
                                        .font(.title2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Text("How to Perform")
                                        .font(.headline)
                                }
                                
                                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                        Text(instruction)
                                            .font(.body)
                                    }
                                }
                            }
                        }
                        
                        // Form Tips
                        if let tips = ExerciseDatabase.formTips(for: exerciseName) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "lightbulb")
                                        .font(.title2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Text("Form Tips")
                                        .font(.headline)
                                }
                                
                                ForEach(tips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .font(.body)
                                        Text(tip)
                                            .font(.body)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    Label("Exercise Information", systemImage: "info.circle")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
            } header: {
                Text("")
            }
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            preFillBodyweightIfNeeded()
        }
        .sheet(item: $editingSet) { set in
            NavigationStack {
                Form {
                    Section("Edit Set") {
                        TextField("Weight", text: $editWeight)
                            .keyboardType(.decimalPad)
                        
                        TextField("Reps", text: $editReps)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("Edit Set")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            editingSet = nil
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveEdit(set)
                        }
                        .disabled(editWeight.isEmpty || editReps.isEmpty)
                    }
                }
            }
        }
        .sheet(isPresented: $showLog1RM) {
            NavigationStack {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Log your actual 1 rep max test")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            TextField("Weight", text: $oneRMWeight)
                                .keyboardType(.decimalPad)
                                .font(.title2)
                        }
                    } header: {
                        Text("1 Rep Max Test")
                    } footer: {
                        Text("This will be saved as your tested 1RM, separate from estimated values.")
                    }
                }
                .navigationTitle(exerciseName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showLog1RM = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            log1RM()
                        }
                        .disabled(oneRMWeight.isEmpty)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    // MARK: - Edit & Delete Methods
    
    private func startEditing(_ set: SetEntry) {
        editWeight = String(set.weight)
        editReps = String(set.reps)
        editingSet = set
    }
    
    private func saveEdit(_ set: SetEntry) {
        guard let weight = Double(editWeight),
              let reps = Int(editReps),
              reps > 0 else { return }
        
        set.weight = weight
        set.reps = reps
        try? context.save()
        
        editingSet = nil
    }
    
    private func deleteSet(_ set: SetEntry) {
        // Remove from workout's sets array if it's part of this workout
        if let index = workout.sets.firstIndex(where: { $0.id == set.id }) {
            workout.sets.remove(at: index)
        }
        
        // Delete from context
        context.delete(set)
        try? context.save()
    }
    
    private func repeatSet(_ set: SetEntry) {
        // Create a new set with the same weight and reps
        let newSet = SetEntry(
            exerciseName: exerciseName,
            weight: set.weight,
            reps: set.reps
        )
        
        workout.sets.append(newSet)
        context.insert(newSet)
        try? context.save()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func log1RM() {
        guard let weight = Double(oneRMWeight), weight > 0 else { return }
        
        // Create a 1RM set entry (reps = 1, marked as 1RM test)
        let oneRMSet = SetEntry(
            exerciseName: exerciseName,
            weight: weight,
            reps: 1,
            isOneRepMax: true
        )
        
        workout.sets.append(oneRMSet)
        context.insert(oneRMSet)
        try? context.save()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Close sheet
        showLog1RM = false
        oneRMWeight = ""
        
        // Show PR banner if it's a new PR
        if weight > (tested1RM?.weight ?? 0) {
            prMessage = "New 1RM PR! 🔥"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    prMessage = nil
                }
            }
        }
    }
    
    // MARK: - Exercise Info Card Helper
    
    @ViewBuilder
    private func exerciseInfoCard(icon: String, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(content)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        String(format: "%.1f \(weightUnit)", w)
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
    
    // MARK: - Bodyweight Pre-Fill
    
    /// Pre-fills weight field with user's bodyweight from HealthKit if:
    /// 1. Weight field is currently empty
    /// 2. Exercise uses bodyweight (equipment == .bodyweight)
    /// 3. User has weight data in HealthKit
    private func preFillBodyweightIfNeeded() {
        // Only pre-fill if weight field is empty
        guard weightText.isEmpty else { return }
        
        // Check if this exercise uses bodyweight
        guard let exercise = ExerciseLibrary.all.first(where: { $0.name == exerciseName }),
              exercise.usesBodyweight else {
            return
        }
        
        // Pre-fill with user's weight from HealthKit
        if let userWeight = healthKitManager.weight {
            weightText = String(format: "%.1f", userWeight)
            print("🏋️ Pre-filled bodyweight: \(userWeight) kg for \(exerciseName)")
        }
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
