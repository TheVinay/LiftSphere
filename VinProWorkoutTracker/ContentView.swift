import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    private let calendar = Calendar.current

    
    // Settings
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true

    @State private var showingNewWorkout = false
    @State private var showingQuickRepeat = false
    @State private var selectedWorkoutToRepeat: Workout?

    
    // Export / import
    @State private var shareItem: ShareItem?
    @State private var isImporting = false
    @State private var importError: String?

    // Delete confirmation
    @State private var pendingDelete: Workout?

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Workout")
                }
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
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.blue)
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

    @ViewBuilder
    private func workoutRow(_ workout: Workout) -> some View {
        NavigationLink {
            WorkoutDetailView(workout: workout)
        } label: {
            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.headline)

                    Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if workout.totalVolume > 0 {
                        Text("Volume \(Int(workout.totalVolume))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if workout.isCompleted {
                    Text("✓")
                        .font(.caption2.bold())
                        .padding(6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                        )
                        .foregroundColor(.green)
                }
            }
            .opacity(workout.isArchived ? 0.45 : 1.0)
        }

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
        
        workout.isCompleted.toggle()
        try? context.save()
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


