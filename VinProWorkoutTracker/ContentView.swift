import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    // Settings
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true

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
                ForEach(visibleWorkouts) { workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.name).font(.headline)
                                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Volume: \(Int(workout.totalVolume))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if workout.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .opacity(workout.isArchived ? 0.45 : 1.0)
                    }

                    // TRAILING
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

                    // LEADING
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {

                        Button {
                            shareSingleWorkout(workout)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(.green)

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
            .navigationTitle("Workouts")
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
