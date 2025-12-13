import SwiftUI
import Foundation
import UniformTypeIdentifiers

// MARK: - Export Models

struct WorkoutExportFile: Codable {
    let exportedAt: Date
    let workouts: [ExportedWorkout]
}

struct ExportedWorkout: Codable {
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

struct ExportedSet: Codable {
    let exerciseName: String
    let weight: Double
    let reps: Int
    let timestamp: Date
}

// MARK: - Share Support

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
