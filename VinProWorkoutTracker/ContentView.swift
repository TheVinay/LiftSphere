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
            List {

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

                // EARLIER
                let earlier = visibleWorkouts.filter {
                    !thisWeek.contains($0) && !lastWeek.contains($0)
                }

                if !earlier.isEmpty {
                    Section("Earlier") {
                        ForEach(earlier) { workout in
                            workoutRow(workout)
                        }
                    }
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
        workout.isCompleted.toggle()
        try? context.save()
    }

    private func toggleArchive(_ workout: Workout) {
        workout.isArchived.toggle()
        try? context.save()
    }

    private func repeatWorkout(_ workout: Workout) {
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
