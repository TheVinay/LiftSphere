import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Timeline Provider

struct WorkoutWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorkoutWidgetEntry {
        WorkoutWidgetEntry(
            date: Date(),
            workoutCount: 0,
            weekVolume: 0,
            todayWorkout: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WorkoutWidgetEntry) -> Void) {
        let entry = WorkoutWidgetEntry(
            date: Date(),
            workoutCount: 12,
            weekVolume: 5420,
            todayWorkout: "Push Day"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WorkoutWidgetEntry>) -> Void) {
        Task {
            let entry = await fetchWorkoutData()
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
            completion(timeline)
        }
    }
    
    private func fetchWorkoutData() async -> WorkoutWidgetEntry {
        // In a real widget, you'd fetch from a shared App Group container
        // For now, returning placeholder data
        return WorkoutWidgetEntry(
            date: Date(),
            workoutCount: 0,
            weekVolume: 0,
            todayWorkout: nil
        )
    }
}

// MARK: - Widget Entry

struct WorkoutWidgetEntry: TimelineEntry {
    let date: Date
    let workoutCount: Int
    let weekVolume: Int
    let todayWorkout: String?
}

// MARK: - Widget Views

struct WorkoutWidgetSmallView: View {
    let entry: WorkoutWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Spacer()
            }
            
            Spacer()
            
            if let workout = entry.todayWorkout {
                Text(workout)
                    .font(.headline)
                    .lineLimit(2)
            } else {
                Text("No workout today")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(entry.workoutCount) total")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct WorkoutWidgetMediumView: View {
    let entry: WorkoutWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Icon and workout
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                if let workout = entry.todayWorkout {
                    Text(workout)
                        .font(.headline)
                } else {
                    Text("Rest Day")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Text("LiftSphere")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Right side - Stats
            VStack(alignment: .trailing, spacing: 12) {
                statView(title: "Workouts", value: "\(entry.workoutCount)")
                statView(title: "Week Volume", value: formatVolume(entry.weekVolume))
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func statView(title: String, value: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func formatVolume(_ volume: Int) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", Double(volume) / 1000)
        }
        return "\(volume)"
    }
}

struct WorkoutWidgetLargeView: View {
    let entry: WorkoutWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Spacer()
                
                Text("LiftSphere")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Today's workout
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                if let workout = entry.todayWorkout {
                    Text(workout)
                        .font(.title2.bold())
                } else {
                    Text("Rest Day")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Stats grid
            HStack(spacing: 16) {
                statCard(title: "Total Workouts", value: "\(entry.workoutCount)")
                statCard(title: "Week Volume", value: "\(entry.weekVolume)")
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Widget Configuration

struct WorkoutWidget: Widget {
    let kind: String = "WorkoutWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkoutWidgetProvider()) { entry in
            WorkoutWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Workout Stats")
        .description("View your workout progress at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WorkoutWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WorkoutWidgetEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            WorkoutWidgetSmallView(entry: entry)
        case .systemMedium:
            WorkoutWidgetMediumView(entry: entry)
        case .systemLarge:
            WorkoutWidgetLargeView(entry: entry)
        default:
            WorkoutWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct LiftSphereWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutWidget()
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    WorkoutWidget()
} timeline: {
    WorkoutWidgetEntry(date: Date(), workoutCount: 12, weekVolume: 5420, todayWorkout: "Push Day")
    WorkoutWidgetEntry(date: Date(), workoutCount: 0, weekVolume: 0, todayWorkout: nil)
}

#Preview(as: .systemMedium) {
    WorkoutWidget()
} timeline: {
    WorkoutWidgetEntry(date: Date(), workoutCount: 12, weekVolume: 5420, todayWorkout: "Push Day")
}

#Preview(as: .systemLarge) {
    WorkoutWidget()
} timeline: {
    WorkoutWidgetEntry(date: Date(), workoutCount: 12, weekVolume: 5420, todayWorkout: "Push Day")
}
