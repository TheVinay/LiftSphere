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
                                VStack(alignment: .leading) {
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
                            .swipeActions {
                                Button {
                                    repeatWorkout(workout)
                                } label: {
                                    Label("Repeat", systemImage: "arrow.clockwise")
                                }
                                .tint(.blue)
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Export button
                    Button {
                        exportWorkouts()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    // Import button
                    Button {
                        isImporting = true
                    } label: {
                        Image(systemName: "tray.and.arrow.down")
                    }

                    // New workout
                    NavigationLink {
                        NewWorkoutView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            // Share sheet for export – only appears when shareURL is non-nil
            .sheet(item: $shareItem) { item in
                ActivityView(activityItems: [item.url])
            }
            // File importer for import
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

    // MARK: - Data actions

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            let w = workouts[index]
            context.delete(w)
        }
        try? context.save()
    }

    // Duplicate an existing workout as a new one for today (no sets)
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
            sets: [] // fresh run
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

            // Trigger share sheet
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
                        reps: s.reps
                    )
                    // Preserve original timestamp if your model allows it
                    newSet.timestamp = s.timestamp
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

        sets = workout.sets.map { s in
            ExportedSet(
                exerciseName: s.exerciseName,
                weight: s.weight,
                reps: s.reps,
                timestamp: s.timestamp
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

// MARK: - UIKit share sheet wrapper

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

// MARK: - Preview

private struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}


#Preview {
    ContentView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
