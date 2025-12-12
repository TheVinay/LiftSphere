import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]

    // Export / import state
    @State private var shareItem: ShareItem?
    @State private var isImporting = false
    @State private var importError: String?

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    Text("No workouts yet")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name)
                                        .font(.headline)

                                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Text("Volume: \(Int(workout.totalVolume))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            // MARK: - Trailing swipe (Mail-style)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {

                                // Full swipe = Duplicate
                                Button {
                                    repeatWorkout(workout)
                                } label: {
                                    VStack {
                                        Image(systemName: "doc.on.doc")
                                        Text("Duplicate")
                                            .font(.caption2)
                                    }
                                }
                                .tint(.blue)

                                // Delete
                                Button(role: .destructive) {
                                    deleteWorkout(workout)
                                } label: {
                                    VStack {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                            .font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        exportWorkouts()
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
                Button("OK", role: .cancel) { }
            } message: {
                Text(importError ?? "Unknown error")
            }
        }
    }

    // MARK: - Row actions

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

    // MARK: - Export

    private func exportWorkouts() {
        do {
            let export = WorkoutExportFile(
                exportedAt: Date(),
                workouts: workouts.map { ExportedWorkout(from: $0) }
            )

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(export)

            let filename = "WorkoutExport-\(Int(Date().timeIntervalSince1970)).json"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
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
            let imported = try decoder.decode(WorkoutExportFile.self, from: data)

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

// MARK: - Export models

private struct WorkoutExportFile: Codable {
    let exportedAt: Date
    let workouts: [ExportedWorkout]
}

private struct ExportedWorkout: Codable {
    let date: Date
    let name: String
    let warmupMinutes: Int
    let coreMinutes: Int
    let stretchMinutes: Int
    let mainExercises: [String]
    let coreExercises: [String]
    let stretches: [String]
    let sets: [ExportedSet]

    init(from workout: Workout) {
        date = workout.date
        name = workout.name
        warmupMinutes = workout.warmupMinutes
        coreMinutes = workout.coreMinutes
        stretchMinutes = workout.stretchMinutes
        mainExercises = workout.mainExercises
        coreExercises = workout.coreExercises
        stretches = workout.stretches
        sets = workout.sets.map {
            ExportedSet(
                exerciseName: $0.exerciseName,
                weight: $0.weight,
                reps: $0.reps,
                timestamp: $0.timestamp
            )
        }
    }
}

private struct ExportedSet: Codable {
    let exerciseName: String
    let weight: Double
    let reps: Int
    let timestamp: Date
}

// MARK: - Share sheet

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
