import SwiftUI
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HealthKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    private let calendar = Calendar.current
    
    // HealthKit manager
    @State private var healthKitManager = HealthKitManager()
    
    // Settings
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true

    @State private var showingNewWorkout = false
    @State private var showingQuickRepeat = false
    @State private var selectedWorkoutToRepeat: Workout?

    // Bulk selection
    @State private var isSelecting = false
    @State private var selectedWorkouts: Set<Workout.ID> = []
    
    // Export / import
    @State private var shareItem: ShareItem?
    @State private var isImporting = false
    @State private var importError: String?
    @State private var importSuccess: Int?

    // Delete confirmation
    @State private var pendingDelete: Workout?
    @State private var showingBulkDeleteConfirmation = false

    private var visibleWorkouts: [Workout] {
        showArchivedWorkouts ? workouts : workouts.filter { !$0.isArchived }
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleWorkouts.isEmpty {
                    emptyStateView
                } else {
                    workoutListView
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelecting {
                        Menu {
                            Button {
                                selectAll()
                            } label: {
                                Label("Select All", systemImage: "checkmark.circle")
                            }
                            
                            Button {
                                deselectAll()
                            } label: {
                                Label("Deselect All", systemImage: "circle")
                            }
                            
                            Divider()
                            
                            Button("Cancel", role: .cancel) {
                                isSelecting = false
                                selectedWorkouts.removeAll()
                            }
                        } label: {
                            Text("Edit")
                        }
                    } else {
                        Menu {
                            Button {
                                isImporting = true
                            } label: {
                                Label("Import Workouts", systemImage: "square.and.arrow.down")
                            }
                            
                            Button {
                                exportAllWorkouts()
                            } label: {
                                Label("Export All", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !visibleWorkouts.isEmpty {
                        Button(isSelecting ? "Done" : "Select") {
                            isSelecting.toggle()
                            if !isSelecting {
                                selectedWorkouts.removeAll()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isSelecting {
                        Button {
                            showingNewWorkout = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add Workout")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isSelecting && !selectedWorkouts.isEmpty {
                    bulkActionsToolbar
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert("Import Error", isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )) {
                Button("OK") { importError = nil }
            } message: {
                if let error = importError {
                    Text(error)
                }
            }
            .alert("Import Successful", isPresented: Binding(
                get: { importSuccess != nil },
                set: { if !$0 { importSuccess = nil } }
            )) {
                Button("OK") { importSuccess = nil }
            } message: {
                if let count = importSuccess {
                    Text("Successfully imported \(count) workout\(count == 1 ? "" : "s")")
                }
            }
            .sheet(item: $shareItem) { item in
                ActivityView(activityItems: [item.url])
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
            .sheet(isPresented: $showingQuickRepeat) {
                QuickRepeatSheet(
                    workouts: visibleWorkouts.prefix(10).map { $0 },
                    isPresented: $showingQuickRepeat,
                    onSelect: { workout in
                        repeatWorkout(workout)
                    }
                )
            }
            .alert("Delete Workout?",
                   isPresented: Binding(
                    get: { pendingDelete != nil },
                    set: { if !$0 { pendingDelete = nil } }
                   )
            ) {
                Button("Delete", role: .destructive) {
                    if let w = pendingDelete {
                        context.delete(w)
                        try? context.save()
                    }
                    pendingDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    pendingDelete = nil
                }
            } message: {
                Text("This workout will be permanently deleted.")
            }
            .alert("Delete \(selectedWorkouts.count) Workouts?",
                   isPresented: $showingBulkDeleteConfirmation
            ) {
                Button("Delete", role: .destructive) {
                    bulkDeleteSelected()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("These workouts will be permanently deleted.")
            }
        }
    }
    
    // MARK: - Bulk Actions Toolbar
    
    private var bulkActionsToolbar: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 8) {
                Text("\(selectedWorkouts.count) Selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 24) {
                    Button {
                        bulkArchiveSelected()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "archivebox")
                                .font(.title3)
                            Text("Archive")
                                .font(.caption)
                        }
                    }
                    .disabled(selectedWorkouts.isEmpty)
                    
                    Button {
                        bulkUnarchiveSelected()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "tray.and.arrow.up")
                                .font(.title3)
                            Text("Unarchive")
                                .font(.caption)
                        }
                    }
                    .disabled(selectedWorkouts.isEmpty)
                    
                    Button {
                        bulkExportSelected()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                            Text("Export")
                                .font(.caption)
                        }
                    }
                    .disabled(selectedWorkouts.isEmpty)
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        if confirmBeforeDelete {
                            showingBulkDeleteConfirmation = true
                        } else {
                            bulkDeleteSelected()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.title3)
                            Text("Delete")
                                .font(.caption)
                        }
                    }
                    .disabled(selectedWorkouts.isEmpty)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text(showArchivedWorkouts ? "No Archived Workouts" : "No Workouts Yet")
                    .font(.title2.bold())
                
                Text(showArchivedWorkouts ? 
                     "Your archived workouts will appear here" : 
                     "Tap the + button to create your first workout")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if !showArchivedWorkouts {
                Button {
                    showingNewWorkout = true
                } label: {
                    Label("Create Workout", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Workout List
    
    private var workoutListView: some View {
        List {
            // QUICK REPEAT SECTION
            Section {
                Button {
                    showingQuickRepeat = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Repeat")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Repeat a recent workout")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // THIS WEEK
            let thisWeek = visibleWorkouts.filter {
                calendar.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
            }

            if !thisWeek.isEmpty {
                Section("This Week") {
                    ForEach(thisWeek) { workout in
                        workoutRow(workout)
                    }
                }
            }

            // LAST WEEK
            let lastWeek = visibleWorkouts.filter {
                guard let lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else {
                    return false
                }
                return calendar.isDate($0.date, equalTo: lastWeekDate, toGranularity: .weekOfYear)
            }

            if !lastWeek.isEmpty {
                Section("Last Week") {
                    ForEach(lastWeek) { workout in
                        workoutRow(workout)
                    }
                }
            }

            // OLDER WORKOUTS - GROUPED BY MONTH
            let olderWorkouts = visibleWorkouts.filter {
                !thisWeek.contains($0) && !lastWeek.contains($0)
            }
            
            // Group by month
            let groupedByMonth = Dictionary(grouping: olderWorkouts) { workout -> String in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: workout.date)
            }
            
            // Sort months in descending order
            let sortedMonths = groupedByMonth.keys.sorted { month1, month2 in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                guard let date1 = formatter.date(from: month1),
                      let date2 = formatter.date(from: month2) else {
                    return false
                }
                return date1 > date2
            }
            
            // Display each month section
            ForEach(sortedMonths, id: \.self) { month in
                if let workoutsInMonth = groupedByMonth[month] {
                    Section(month) {
                        ForEach(workoutsInMonth) { workout in
                            workoutRow(workout)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 10000 {
            return String(format: "%.1fK", volume / 1000)
        } else if volume >= 1000 {
            return String(format: "%.1fK", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }

    @ViewBuilder
    private func workoutRow(_ workout: Workout) -> some View {
        let isSelected = selectedWorkouts.contains(workout.id)
        
        HStack(spacing: 12) {
            // Selection circle (like Mail app)
            if isSelecting {
                Button {
                    toggleSelection(for: workout)
                } label: {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            NavigationLink {
                WorkoutDetailView(workout: workout)
            } label: {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(workout.name)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if workout.totalVolume > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                Text("Volume \(formatVolume(workout.totalVolume))")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.orange.opacity(0.15))
                            )
                        }
                    }

                    Spacer()

                    if workout.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .opacity(workout.isArchived ? 0.45 : 1.0)
            }
            .disabled(isSelecting)
        }
        
        // Swipe actions only when NOT in selection mode
        .if(!isSelecting) { view in
            view
                // 👉 RIGHT SWIPE (Complete / Duplicate / Delete)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        toggleCompleted(workout)
                    } label: {
                        Label(
                            workout.isCompleted ? "Undo" : "Complete",
                            systemImage: workout.isCompleted ? "arrow.uturn.backward" : "checkmark"
                        )
                    }
                    .tint(.green)

                    Button {
                        repeatWorkout(workout)
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    .tint(.blue)

                    Button(role: .destructive) {
                        handleDelete(workout)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }

                // 👉 LEFT SWIPE (Archive / Unarchive)
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        toggleArchive(workout)
                    } label: {
                        Label(
                            workout.isArchived ? "Unarchive" : "Archive",
                            systemImage: workout.isArchived ? "tray.and.arrow.up" : "archivebox"
                        )
                    }
                    .tint(.gray)
                }
        }
    }



    
    private func handleDelete(_ workout: Workout) {
        if confirmBeforeDelete {
            pendingDelete = workout
        } else {
            context.delete(workout)
            try? context.save()
        }
    }

    private func toggleCompleted(_ workout: Workout) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let wasCompleted = workout.isCompleted
        workout.isCompleted.toggle()
        try? context.save()
        
        // Save to HealthKit when marking as completed
        if workout.isCompleted && !wasCompleted {
            Task {
                await saveWorkoutToHealthKit(workout)
            }
        }
    }
    
    // MARK: - HealthKit Integration
    
    private func saveWorkoutToHealthKit(_ workout: Workout) async {
        // Only save if HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit not available on this device")
            return
        }
        
        // Calculate total workout duration
        let totalDuration = TimeInterval(
            (workout.warmupMinutes + workout.coreMinutes + workout.stretchMinutes) * 60
        )
        
        // Add estimated time for sets (assume 2 minutes per set on average)
        let estimatedSetsTime = Double(workout.sets.count) * 120 // 2 minutes per set
        let totalWorkoutDuration = totalDuration + estimatedSetsTime
        
        print("📝 Attempting to save workout to HealthKit:")
        print("   Name: \(workout.name)")
        print("   Date: \(workout.date)")
        print("   Duration: \(totalWorkoutDuration / 60) minutes")
        print("   Volume: \(workout.totalVolume) lbs")
        print("   Sets: \(workout.sets.count)")
        
        do {
            try await healthKitManager.saveWorkout(
                name: workout.name,
                startDate: workout.date,
                duration: totalWorkoutDuration,
                totalVolume: workout.totalVolume
            )
            print("✅ Successfully saved workout to Apple Health!")
        } catch {
            // Log the actual error for debugging
            print("⚠️ Failed to save workout to HealthKit:")
            print("   Error: \(error)")
            print("   Description: \(error.localizedDescription)")
            
            // Check if it's a permission error
            if let hkError = error as? HKError {
                print("   HKError Code: \(hkError.code.rawValue)")
                if hkError.code == .errorAuthorizationDenied {
                    print("   → User needs to grant write permission in Health app")
                }
            }
        }
    }

    private func toggleArchive(_ workout: Workout) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        workout.isArchived.toggle()
        try? context.save()
    }

    private func repeatWorkout(_ workout: Workout) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let copy = Workout(
            date: Date(),
            name: workout.name,
            warmupMinutes: workout.warmupMinutes,
            coreMinutes: workout.coreMinutes,
            stretchMinutes: workout.stretchMinutes,
            mainExercises: workout.mainExercises,
            coreExercises: workout.coreExercises,
            stretches: workout.stretches,
            sets: []
        )
        context.insert(copy)
        try? context.save()
    }

    private func shareSingleWorkout(_ workout: Workout) {
        // unchanged – uses WorkoutExportSupport
    }
    
    // MARK: - Import/Export
    
    private func exportAllWorkouts() {
        do {
            let fileURL = try ExportManager.createExportFile(
                workouts: workouts,
                format: .json
            )
            shareItem = ShareItem(url: fileURL)
        } catch {
            importError = "Export failed: \(error.localizedDescription)"
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                // Read the file
                let data = try Data(contentsOf: url)
                
                // Decode JSON
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let exportFile = try decoder.decode(WorkoutExportFile.self, from: data)
                
                // Import workouts
                var importedCount = 0
                for exportedWorkout in exportFile.workouts {
                    let workout = Workout(
                        date: exportedWorkout.date,
                        name: exportedWorkout.name,
                        warmupMinutes: exportedWorkout.warmupMinutes,
                        coreMinutes: exportedWorkout.coreMinutes,
                        stretchMinutes: exportedWorkout.stretchMinutes,
                        mainExercises: exportedWorkout.mainExercises,
                        coreExercises: exportedWorkout.coreExercises,
                        stretches: exportedWorkout.stretches
                    )
                    
                    // Import sets
                    for exportedSet in exportedWorkout.sets {
                        let setEntry = SetEntry(
                            exerciseName: exportedSet.exerciseName,
                            weight: exportedSet.weight,
                            reps: exportedSet.reps,
                            timestamp: exportedSet.timestamp
                        )
                        workout.sets.append(setEntry)
                    }
                    
                    context.insert(workout)
                    importedCount += 1
                }
                
                try context.save()
                
                // Show success message
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                importSuccess = importedCount
                
            } catch {
                importError = "Failed to import: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            importError = "Failed to read file: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Bulk Selection Actions
    
    private func toggleSelection(for workout: Workout) {
        if selectedWorkouts.contains(workout.id) {
            selectedWorkouts.remove(workout.id)
        } else {
            selectedWorkouts.insert(workout.id)
        }
    }
    
    private func selectAll() {
        selectedWorkouts = Set(visibleWorkouts.map { $0.id })
    }
    
    private func deselectAll() {
        selectedWorkouts.removeAll()
    }
    
    private func bulkArchiveSelected() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        for workout in visibleWorkouts where selectedWorkouts.contains(workout.id) {
            workout.isArchived = true
        }
        
        try? context.save()
        
        // Exit selection mode
        isSelecting = false
        selectedWorkouts.removeAll()
    }
    
    private func bulkUnarchiveSelected() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        for workout in visibleWorkouts where selectedWorkouts.contains(workout.id) {
            workout.isArchived = false
        }
        
        try? context.save()
        
        // Exit selection mode
        isSelecting = false
        selectedWorkouts.removeAll()
    }
    
    private func bulkDeleteSelected() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        for workout in visibleWorkouts where selectedWorkouts.contains(workout.id) {
            context.delete(workout)
        }
        
        try? context.save()
        
        // Exit selection mode
        isSelecting = false
        selectedWorkouts.removeAll()
    }
    
    private func bulkExportSelected() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Get selected workouts
        let selectedWorkoutObjects = visibleWorkouts.filter { selectedWorkouts.contains($0.id) }
        
        guard !selectedWorkoutObjects.isEmpty else { return }
        
        // Show export format options
        Task {
            do {
                let fileURL = try ExportManager.createExportFile(
                    workouts: selectedWorkoutObjects,
                    format: .json
                )
                
                await MainActor.run {
                    shareItem = ShareItem(url: fileURL)
                    
                    // Exit selection mode
                    isSelecting = false
                    selectedWorkouts.removeAll()
                }
            } catch {
                await MainActor.run {
                    importError = "Export failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - View Extension for Conditional Modifiers

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
// MARK: - Quick Repeat Sheet

private struct QuickRepeatSheet: View {
    let workouts: [Workout]
    @Binding var isPresented: Bool
    let onSelect: (Workout) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(workouts) { workout in
                        Button {
                            onSelect(workout)
                            isPresented = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 8) {
                                        Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        if workout.totalVolume > 0 {
                                            Text("•")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("Vol: \(Int(workout.totalVolume))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    if !workout.mainExercises.isEmpty {
                                        Text("\(workout.mainExercises.count) exercises")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Select a workout to repeat")
                }
            }
            .navigationTitle("Quick Repeat")
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


