import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    // Settings
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false

    // Export / import state
    @State private var shareItem: ShareItem?
    @State private var isImporting = false
    @State private var importError: String?

    // Filtered list
    private var visibleWorkouts: [Workout] {
        showArchivedWorkouts
            ? workouts
            : workouts.filter { !$0.isArchived }
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleWorkouts.isEmpty {
                    Text(showArchivedWorkouts
                         ? "No workouts"
                         : "No active workouts")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(visibleWorkouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.name)
                                            .font(.headline)

                                        Text(
                                            workout.date.formatted(
                                                date: .abbreviated,
                                                time: .shortened
                                            )
                                        )
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
                                            .imageScale(.large)
                                    }
                                }
                                .opacity(workout.isArchived ? 0.45 : 1.0)
                            }

                            // MARK: - Swipe RIGHT → LEFT (Primary)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {

                                // Complete / Undo
                                Button {
                                    toggleCompleted(workout)
                                } label: {
                                    Label(
                                        workout.isCompleted ? "Undo" : "Complete",
                                        systemImage: workout.isCompleted
                                            ? "arrow.uturn.backward"
                                            : "checkmark"
                                    )
                                }
                                .tint(.green)

                                // Duplicate
                                Button {
                                    repeatWorkout(workout)
                                } label: {
                                    Label("Duplicate", systemImage: "doc.on.doc")
                                }
                                .tint(.blue)

                                // Delete
                                Button(role: .destructive) {
                                    deleteWorkout(workout)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }

                            // MARK: - Swipe LEFT → RIGHT (Secondary)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {

                                // Share
                                Button {
                                    shareSingleWorkout(workout)
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(.green)

                                // Archive / Unarchive
                                Button {
                                    toggleArchive(workout)
                                } label: {
                                    Label(
                                        workout.isArchived ? "Unarchive" : "Archive",
                                        systemImage: workout.isArchived
                                            ? "tray.and.arrow.up"
                                            : "archivebox"
                                    )
                                }
                                .tint(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        exportAllWorkouts()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Button {
                        isImporting = true
                    } label: {
                        Image(systemName: "tray.and.arrow.down")
                    }

                    NavigationLink {
                        NewWorkoutView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(item: $shareItem) { item in
                ActivityView(activityItems: [item.url])
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json]
            ) { result in
                handleImport(result: result)
            }
            .alert("Import error", isPresented: Binding(
                get: { importError != nil },
                set: { _ in importError = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importError ?? "Unknown error")
            }
        }
    }

    // MARK: - Row actions

    private func toggleCompleted(_ workout: Workout) {
        workout.isCompleted.toggle()
        try? context.save()
    }

    private func toggleArchive(_ workout: Workout) {
        workout.isArchived.toggle()
        try? context.save()
    }

    private func deleteWorkout(_ workout: Workout) {
        context.delete(workout)
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

    // MARK: - Share (single)

    private func shareSingleWorkout(_ workout: Workout) {
        do {
            let export = WorkoutExportFile(
                exportedAt: Date(),
                workouts: [ExportedWorkout(from: workout)]
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(export)

            let filename =
                "Workout-\(workout.name)-\(Int(Date().timeIntervalSince1970)).json"

            let url =
                FileManager.default.temporaryDirectory
                    .appendingPathComponent(filename)

            try data.write(to: url, options: .atomic)
            shareItem = ShareItem(url: url)

        } catch {
            importError = "Failed to share workout: \(error.localizedDescription)"
        }
    }

    // MARK: - Export (all)

    private func exportAllWorkouts() {
        do {
            let export = WorkoutExportFile(
                exportedAt: Date(),
                workouts: workouts.map { ExportedWorkout(from: $0) }
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(export)

            let filename =
                "WorkoutExport-\(Int(Date().timeIntervalSince1970)).json"

            let url =
                FileManager.default.temporaryDirectory
                    .appendingPathComponent(filename)

            try data.write(to: url, options: .atomic)
            shareItem = ShareItem(url: url)

        } catch {
            importError = "Failed to export workouts: \(error.localizedDescription)"
        }
    }

    // MARK: - Import

    private func handleImport(result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let imported =
                try decoder.decode(WorkoutExportFile.self, from: data)

            for w in imported.workouts {
                let newWorkout = Workout(
                    date: w.date,
                    name: w.name,
                    warmupMinutes: w.warmupMinutes,
                    coreMinutes: w.coreMinutes,
                    stretchMinutes: w.stretchMinutes,
                    mainExercises: w.mainExercises,
                    coreExercises: w.coreExercises,
                    stretches: w.stretches,
                    sets: []
                )

                context.insert(newWorkout)

                for s in w.sets {
                    let newSet = SetEntry(
                        exerciseName: s.exerciseName,
                        weight: s.weight,
                        reps: s.reps,
                        timestamp: s.timestamp
                    )
                    newWorkout.sets.append(newSet)
                    context.insert(newSet)
                }
            }

            try context.save()

        } catch {
            importError = "Failed to import workouts: \(error.localizedDescription)"
        }
    }
}
