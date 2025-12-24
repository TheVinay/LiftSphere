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

// MARK: - PDF Export

import UIKit
import PDFKit

struct PDFExporter {
    static func createPDF(for workouts: [Workout]) throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "VinPro Workout Tracker",
            kCGPDFContextAuthor: "VinPro",
            kCGPDFContextTitle: "Workout Summary"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            for (index, workout) in workouts.enumerated() {
                context.beginPage()
                
                let titleFont = UIFont.boldSystemFont(ofSize: 24)
                let headingFont = UIFont.boldSystemFont(ofSize: 16)
                let bodyFont = UIFont.systemFont(ofSize: 12)
                let captionFont = UIFont.systemFont(ofSize: 10)
                
                var yPosition: CGFloat = 40
                let leftMargin: CGFloat = 40
                let rightMargin: CGFloat = 555
                let maxWidth = rightMargin - leftMargin
                
                // Title
                let titleText = workout.name
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.label
                ]
                titleText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
                yPosition += 35
                
                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                let dateText = dateFormatter.string(from: workout.date)
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: bodyFont,
                    .foregroundColor: UIColor.secondaryLabel
                ]
                dateText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: dateAttributes)
                yPosition += 30
                
                // Summary Box
                let summaryRect = CGRect(x: leftMargin, y: yPosition, width: maxWidth, height: 80)
                let summaryPath = UIBezierPath(roundedRect: summaryRect, cornerRadius: 8)
                UIColor.systemGray6.setFill()
                summaryPath.fill()
                
                let summaryY = yPosition + 15
                let summaryFont = UIFont.systemFont(ofSize: 11)
                let summaryAttributes: [NSAttributedString.Key: Any] = [
                    .font: summaryFont,
                    .foregroundColor: UIColor.label
                ]
                
                "Total Sets: \(workout.sets.count)".draw(at: CGPoint(x: leftMargin + 15, y: summaryY), withAttributes: summaryAttributes)
                "Total Volume: \(Int(workout.totalVolume))".draw(at: CGPoint(x: leftMargin + 15, y: summaryY + 20), withAttributes: summaryAttributes)
                "Duration: Warmup \(workout.warmupMinutes)m • Core \(workout.coreMinutes)m • Stretch \(workout.stretchMinutes)m".draw(at: CGPoint(x: leftMargin + 15, y: summaryY + 40), withAttributes: summaryAttributes)
                
                yPosition += 100
                
                // Main Exercises
                if !workout.mainExercises.isEmpty {
                    let mainHeading = "Main Exercises"
                    let headingAttributes: [NSAttributedString.Key: Any] = [
                        .font: headingFont,
                        .foregroundColor: UIColor.label
                    ]
                    mainHeading.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headingAttributes)
                    yPosition += 25
                    
                    for exercise in workout.mainExercises {
                        let bulletAttributes: [NSAttributedString.Key: Any] = [
                            .font: bodyFont,
                            .foregroundColor: UIColor.label
                        ]
                        "• \(exercise)".draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: bulletAttributes)
                        yPosition += 20
                        
                        // Show sets for this exercise
                        let exerciseSets = workout.sets.filter { $0.exerciseName == exercise }
                        if !exerciseSets.isEmpty {
                            for (index, set) in exerciseSets.enumerated() {
                                let setAttributes: [NSAttributedString.Key: Any] = [
                                    .font: captionFont,
                                    .foregroundColor: UIColor.secondaryLabel
                                ]
                                let setText = "  Set \(index + 1): \(String(format: "%.1f", set.weight)) kg × \(set.reps) reps"
                                setText.draw(at: CGPoint(x: leftMargin + 25, y: yPosition), withAttributes: setAttributes)
                                yPosition += 18
                            }
                            yPosition += 5
                        }
                    }
                    yPosition += 10
                }
                
                // Accessory Exercises
                if !workout.coreExercises.isEmpty {
                    let accessoryHeading = "Accessory / Core"
                    let headingAttributes: [NSAttributedString.Key: Any] = [
                        .font: headingFont,
                        .foregroundColor: UIColor.label
                    ]
                    accessoryHeading.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headingAttributes)
                    yPosition += 25
                    
                    for exercise in workout.coreExercises {
                        let bulletAttributes: [NSAttributedString.Key: Any] = [
                            .font: bodyFont,
                            .foregroundColor: UIColor.label
                        ]
                        "• \(exercise)".draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: bulletAttributes)
                        yPosition += 20
                        
                        // Show sets for accessory exercises too
                        let exerciseSets = workout.sets.filter { $0.exerciseName == exercise }
                        if !exerciseSets.isEmpty {
                            for (index, set) in exerciseSets.enumerated() {
                                let setAttributes: [NSAttributedString.Key: Any] = [
                                    .font: captionFont,
                                    .foregroundColor: UIColor.secondaryLabel
                                ]
                                let setText = "  Set \(index + 1): \(String(format: "%.1f", set.weight)) kg × \(set.reps) reps"
                                setText.draw(at: CGPoint(x: leftMargin + 25, y: yPosition), withAttributes: setAttributes)
                                yPosition += 18
                            }
                            yPosition += 5
                        }
                    }
                    yPosition += 10
                }
                
                // Stretches
                if !workout.stretches.isEmpty {
                    let stretchHeading = "Stretches"
                    let headingAttributes: [NSAttributedString.Key: Any] = [
                        .font: headingFont,
                        .foregroundColor: UIColor.label
                    ]
                    stretchHeading.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headingAttributes)
                    yPosition += 25
                    
                    for stretch in workout.stretches {
                        let bulletAttributes: [NSAttributedString.Key: Any] = [
                            .font: bodyFont,
                            .foregroundColor: UIColor.label
                        ]
                        "• \(stretch)".draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: bulletAttributes)
                        yPosition += 20
                    }
                    yPosition += 10
                }
                
                // Notes
                if !workout.notes.isEmpty {
                    let notesHeading = "Notes"
                    let headingAttributes: [NSAttributedString.Key: Any] = [
                        .font: headingFont,
                        .foregroundColor: UIColor.label
                    ]
                    notesHeading.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headingAttributes)
                    yPosition += 25
                    
                    let notesAttributes: [NSAttributedString.Key: Any] = [
                        .font: bodyFont,
                        .foregroundColor: UIColor.secondaryLabel
                    ]
                    let notesRect = CGRect(x: leftMargin + 10, y: yPosition, width: maxWidth - 20, height: 200)
                    workout.notes.draw(in: notesRect, withAttributes: notesAttributes)
                }
                
                // Footer
                let footerY = pageRect.height - 40
                let footerText = "Generated by VinPro Workout Tracker • Page \(index + 1) of \(workouts.count)"
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: captionFont,
                    .foregroundColor: UIColor.tertiaryLabel
                ]
                let footerSize = footerText.size(withAttributes: footerAttributes)
                let footerX = (pageRect.width - footerSize.width) / 2
                footerText.draw(at: CGPoint(x: footerX, y: footerY), withAttributes: footerAttributes)
            }
        }
        
        return data
    }
}

// MARK: - Export Manager

struct ExportManager {
    enum ExportFormat {
        case json
        case detailedCSV
        case summaryCSV
        case pdf
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
            
        case .pdf:
            fileName = "workout_\(Date().timeIntervalSince1970).pdf"
            fileContent = try PDFExporter.createPDF(for: workouts)
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
