import SwiftUI
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
    @State private var showingSocialShare = false
    @State private var shareSuccess = false
    @State private var showingSaveAsTemplate = false
    @State private var templateSaveSuccess = false

    var body: some View {
        List {
            // MARK: - Workout Summary Card
            Section {
                VStack(spacing: 16) {
                    // Workout Stats
                    HStack(spacing: 20) {
                        StatBadge(
                            icon: "dumbbell.fill",
                            value: "\(workout.sets.count)",
                            label: "Sets"
                        )
                        
                        StatBadge(
                            icon: "flame.fill",
                            value: formatVolume(workout.totalVolume),
                            label: "Volume"
                        )
                        
                        StatBadge(
                            icon: "figure.strengthtraining.traditional",
                            value: "\(exercisesForLog.count)",
                            label: "Exercises"
                        )
                    }
                    
                    // Completion Status
                    if workout.isCompleted {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Completed")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // MARK: - View / edit today's plan
            Section {
                // Primary work editor
                NavigationLink {
                    PrimaryPlanEditorView(workout: workout)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Primary Work")
                                .font(.subheadline.weight(.semibold))
                            if !workout.mainExercises.isEmpty {
                                Text("\(workout.mainExercises.count) exercises")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No exercises")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Accessory / optional editor
                NavigationLink {
                    AccessoryEditorView(workout: workout)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "figure.flexibility")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accessory Work")
                                .font(.subheadline.weight(.semibold))
                            if !workout.coreExercises.isEmpty {
                                Text("\(workout.coreExercises.count) exercises")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("No exercises")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Edit Plan")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .textCase(nil)
            }

            // MARK: - Log & history
            Section {
                if exercisesForLog.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        
                        Text("No exercises yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Add exercises to your workout plan above")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(exercisesForLog, id: \.self) { exercise in
                        NavigationLink {
                            ExerciseHistoryView(workout: workout, exerciseName: exercise)
                        } label: {
                            EnhancedExerciseLogRow(
                                exerciseName: exercise,
                                allSets: allSets,
                                workoutSets: workout.sets
                            )
                        }
                    }
                }
            } header: {
                Text("Log Sets & History")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .textCase(nil)
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
                        showingSaveAsTemplate = true
                    } label: {
                        Label("Save as Template", systemImage: "doc.badge.plus")
                    }
                    
                    Divider()
                    
                    Button {
                        shareWorkout()
                    } label: {
                        Label("Share as PDF", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        showingSocialShare = true
                    } label: {
                        Label("Share to Friends", systemImage: "person.2.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingRenameSheet) {
            RenameWorkoutSheet(workout: workout, isPresented: $showingRenameSheet)
        }
        .sheet(isPresented: $showingSaveAsTemplate) {
            SaveAsTemplateSheet(workout: workout, isPresented: $showingSaveAsTemplate, onSuccess: {
                templateSaveSuccess = true
            })
        }
        .sheet(item: Binding(
            get: { pdfToShare.map { PDFShareItem(data: $0, workout: workout) } },
            set: { pdfToShare = $0?.data }
        )) { item in
            ShareSheet(items: [item.fileURL])
        }
        .confirmationDialog("Share Workout", isPresented: $showingSocialShare) {
            Button("Share to Friends") {
                Task {
                    await shareToFriends()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Share this workout with your friends?")
        }
        .alert("Workout Shared!", isPresented: $shareSuccess) {
            Button("OK") { }
        } message: {
            Text("Your workout has been shared with friends.")
        }
        .alert("Template Saved!", isPresented: $templateSaveSuccess) {
            Button("OK") { }
        } message: {
            Text("Your workout has been saved as a custom template.")
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
    
    private func shareToFriends() async {
        let socialService = SocialService()
        do {
            try await socialService.shareWorkout(workout)
            shareSuccess = true
        } catch {
            print("Failed to share workout: \(error)")
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 10000 {
            return String(format: "%.1fK", volume / 1000)
        } else if volume >= 1000 {
            return String(format: "%.1fK", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Enhanced Exercise Log Row

private struct EnhancedExerciseLogRow: View {
    let exerciseName: String
    let allSets: [SetEntry]
    let workoutSets: [SetEntry]

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
    
    // Sets logged today for this exercise
    private var todaySets: [SetEntry] {
        workoutSets.filter { $0.exerciseName == exerciseName }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Exercise icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.15), .purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "dumbbell.fill")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(exerciseName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                
                // Stats row
                HStack(spacing: 12) {
                    // Today's sets
                    if !todaySets.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Text("\(todaySets.count) logged")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    // Last set
                    if let last = lastSet {
                        if !todaySets.isEmpty {
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Last: \(formatSet(last))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Best set
                    if let best = bestSet {
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "trophy.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text(formatSet(best))
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                // If no sets logged yet
                if todaySets.isEmpty && lastSet == nil {
                    Text("No sets logged yet")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func formatSet(_ set: SetEntry) -> String {
        let w = String(format: "%.1f", set.weight)
        return "\(w)kg × \(set.reps)"
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

// MARK: - Save as Template Sheet

private struct SaveAsTemplateSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let workout: Workout
    @Binding var isPresented: Bool
    let onSuccess: () -> Void
    
    @State private var templateName: String = ""
    @State private var selectedDay: String? = nil
    @State private var showNameExistsAlert = false
    
    @Query(sort: \CustomWorkoutTemplate.createdDate, order: .reverse)
    private var existingTemplates: [CustomWorkoutTemplate]
    
    private let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Template Name", text: $templateName)
                        .autocorrectionDisabled()
                } header: {
                    Text("Template Name")
                } footer: {
                    Text("Give your template a descriptive name (e.g., 'Upper Body A', 'Leg Day')")
                }
                
                Section {
                    Picker("Day of Week", selection: $selectedDay) {
                        Text("None").tag(nil as String?)
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day).tag(day as String?)
                        }
                    }
                } header: {
                    Text("Day (Optional)")
                } footer: {
                    Text("Optionally assign this template to a specific day of the week")
                }
            }
            .navigationTitle("Save as Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTemplate()
                    }
                    .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Template Name Exists", isPresented: $showNameExistsAlert) {
                Button("OK") { }
            } message: {
                Text("A template with this name already exists. Please choose a different name.")
            }
            .onAppear {
                // Pre-fill with workout name
                templateName = workout.name
            }
        }
    }
    
    private func saveTemplate() {
        let trimmedName = templateName.trimmingCharacters(in: .whitespaces)
        
        // Check if name already exists
        if existingTemplates.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            showNameExistsAlert = true
            return
        }
        
        // Create new template
        let template = CustomWorkoutTemplate(
            name: trimmedName,
            dayOfWeek: selectedDay,
            warmupMinutes: workout.warmupMinutes,
            coreMinutes: workout.coreMinutes,
            stretchMinutes: workout.stretchMinutes,
            mainExercises: workout.mainExercises,
            coreExercises: workout.coreExercises,
            stretches: workout.stretches
        )
        
        context.insert(template)
        try? context.save()
        
        onSuccess()
        isPresented = false
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
