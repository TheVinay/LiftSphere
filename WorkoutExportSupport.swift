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

// MARK: - CSV Export

struct CSVExporter {
    /// Export all workouts to CSV format
    static func exportToCSV(workouts: [Workout]) -> String {
        var csv = "Date,Workout Name,Exercise,Set Number,Weight,Reps,Volume,Duration (Warmup),Duration (Core),Duration (Stretch)\n"
        
        for workout in workouts {
            let dateString = ISO8601DateFormatter().string(from: workout.date)
            
            if workout.sets.isEmpty {
                // Workout with no sets
                csv += "\(dateString),\"\(workout.name)\",No Sets,0,0,0,0,\(workout.warmupMinutes),\(workout.coreMinutes),\(workout.stretchMinutes)\n"
            } else {
                // Group sets by exercise
                let groupedSets = Dictionary(grouping: workout.sets) { $0.exerciseName }
                
                for (exerciseName, sets) in groupedSets.sorted(by: { $0.key < $1.key }) {
                    for (index, set) in sets.enumerated() {
                        let volume = set.weight * Double(set.reps)
                        csv += "\(dateString),\"\(workout.name)\",\"\(exerciseName)\",\(index + 1),\(set.weight),\(set.reps),\(volume),\(workout.warmupMinutes),\(workout.coreMinutes),\(workout.stretchMinutes)\n"
                    }
                }
            }
        }
        
        return csv
    }
    
    /// Export summary statistics to CSV
    static func exportSummaryCSV(workouts: [Workout]) -> String {
        var csv = "Date,Workout Name,Total Sets,Total Volume,Completed,Archived,Warmup (min),Core (min),Stretch (min)\n"
        
        for workout in workouts {
            let dateString = ISO8601DateFormatter().string(from: workout.date)
            let totalSets = workout.sets.count
            let totalVolume = workout.totalVolume
            let completed = workout.isCompleted ? "Yes" : "No"
            let archived = workout.isArchived ? "Yes" : "No"
            
            csv += "\(dateString),\"\(workout.name)\",\(totalSets),\(totalVolume),\(completed),\(archived),\(workout.warmupMinutes),\(workout.coreMinutes),\(workout.stretchMinutes)\n"
        }
        
        return csv
    }
}

// MARK: - Export Manager

struct ExportManager {
    enum ExportFormat {
        case json
        case detailedCSV
        case summaryCSV
    }
    
    /// Create a temporary file URL for export
    static func createExportFile(
        workouts: [Workout],
        format: ExportFormat
    ) throws -> URL {
        let fileName: String
        let fileContent: Data
        
        switch format {
        case .json:
            fileName = "liftsphere_workouts_\(Date().timeIntervalSince1970).json"
            let exportFile = WorkoutExportFile(
                exportedAt: Date(),
                workouts: workouts.map { ExportedWorkout(from: $0) }
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            fileContent = try encoder.encode(exportFile)
            
        case .detailedCSV:
            fileName = "liftsphere_detailed_\(Date().timeIntervalSince1970).csv"
            let csvString = CSVExporter.exportToCSV(workouts: workouts)
            guard let data = csvString.data(using: .utf8) else {
                throw ExportError.encodingFailed
            }
            fileContent = data
            
        case .summaryCSV:
            fileName = "liftsphere_summary_\(Date().timeIntervalSince1970).csv"
            let csvString = CSVExporter.exportSummaryCSV(workouts: workouts)
            guard let data = csvString.data(using: .utf8) else {
                throw ExportError.encodingFailed
            }
            fileContent = data
        }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        try fileContent.write(to: fileURL)
        return fileURL
    }
    
    enum ExportError: LocalizedError {
        case encodingFailed
        case noWorkouts
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to encode workout data"
            case .noWorkouts:
                return "No workouts to export"
            }
        }
    }
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
