import SwiftUI
import SwiftData
import Charts

struct ExerciseInfoView: View {
    @Environment(\.modelContext) private var context
    
    let exerciseName: String

    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

    @State private var selectedTab: InfoTab = .about
    @State private var selectedAboutTab: AboutSubTab = .muscles
    @State private var range: TimeRange = .allTime

    enum InfoTab: String, CaseIterable, Identifiable {
        case about, history, charts, records

        var id: String { rawValue }

        var title: String {
            switch self {
            case .about:   return "About"
            case .history: return "History"
            case .charts:  return "Charts"
            case .records: return "Records"
            }
        }
    }
    
    enum AboutSubTab: String, CaseIterable, Identifiable {
        case muscles, howTo, tips
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .muscles: return "Muscles"
            case .howTo:   return "How-To"
            case .tips:    return "Tips"
            }
        }
    }

    enum TimeRange: String, CaseIterable, Identifiable {
        case week, month, year, allTime

        var id: String { rawValue }

        var title: String {
            switch self {
            case .week:    return "1W"
            case .month:   return "1M"
            case .year:    return "1Y"
            case .allTime: return "All"
            }
        }
    }

    var body: some View {
        let setsForExercise = filteredSets()

        VStack(spacing: 0) {
            // Tabs
            Picker("Tab", selection: $selectedTab) {
                ForEach(InfoTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Content
            switch selectedTab {
            case .about:
                aboutView
            case .history:
                historyView(sets: setsForExercise)
            case .charts:
                chartsView(sets: setsForExercise)
            case .records:
                recordsView(sets: setsForExercise)
            }
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - About

    private var aboutView: some View {
        VStack(spacing: 0) {
            // Exercise name with gradient
            Text(exerciseName)
                .font(.title.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.top, 16)
                .padding(.horizontal)
            
            // Simple text-based tabs with gradient underline
            HStack(spacing: 0) {
                ForEach(AboutSubTab.allCases) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedAboutTab = tab
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(tab.title)
                                .font(.subheadline.weight(selectedAboutTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedAboutTab == tab ? .primary : .secondary)
                            
                            // Gradient underline for active tab
                            if selectedAboutTab == tab {
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(height: 3)
                                .clipShape(Capsule())
                            } else {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            Divider()
                .padding(.top, 8)
            
            // Content based on selected sub-tab
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedAboutTab {
                    case .muscles:
                        musclesContent
                    case .howTo:
                        howToContent
                    case .tips:
                        tipsContent
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - About Sub-Content
    
    private var musclesContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let muscles = ExerciseDatabase.primaryMuscles(for: exerciseName, context: context) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Muscles")
                            .font(.headline)
                        Text(muscles)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Muscle information not available")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var howToContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let instructions = ExerciseDatabase.instructions(for: exerciseName, context: context) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to Perform")
                            .font(.headline)
                        
                        ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                Text(instruction)
                                    .font(.body)
                            }
                        }
                    }
                }
            } else {
                Text("Instructions not available")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var tipsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tips = ExerciseDatabase.formTips(for: exerciseName, context: context) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Form Tips")
                            .font(.headline)
                        
                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.body)
                                Text(tip)
                                    .font(.body)
                            }
                        }
                    }
                }
            } else {
                Text("Form tips not available")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - History

    private func historyView(sets: [SetEntry]) -> some View {
        List {
            if sets.isEmpty {
                Text("No sets logged yet for \(exerciseName).")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sets) { set in
                    HStack {
                        Text(set.timestamp.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                        Text("\(set.weight, specifier: "%.1f") x \(set.reps)")
                    }
                }
            }
        }
    }

    // MARK: - Charts

    private func chartsView(sets: [SetEntry]) -> some View {
        let bestPoints = bestSetTimeline(from: sets)
        let volumePoints = volumeTimeline(from: sets)

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Time range")
                        .font(.headline)
                    Spacer()
                    Picker("Range", selection: $range) {
                        ForEach(TimeRange.allCases) { r in
                            Text(r.title).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                }
                .padding(.horizontal)

                // Best set chart
                chartCard(title: "Best set", points: bestPoints, yLabel: "Weight")

                // Volume chart
                chartCard(title: "Total volume", points: volumePoints, yLabel: "Volume")
            }
            .padding(.bottom)
        }
    }

    private struct ChartPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    private func chartCard(title: String, points: [ChartPoint], yLabel: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            if points.isEmpty {
                Text("No data yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(points) { p in
                    LineMark(
                        x: .value("Date", p.date),
                        y: .value(yLabel, p.value)
                    )
                    PointMark(
                        x: .value("Date", p.date),
                        y: .value(yLabel, p.value)
                    )
                }
                .frame(height: 180)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    // MARK: - Records

    private func recordsView(sets: [SetEntry]) -> some View {
        let heaviest = sets.max(by: { $0.weight < $1.weight })
        let maxVolume = sets.max(by: { a, b in
            a.weight * Double(a.reps) < b.weight * Double(b.reps)
        })

        let best1RM = sets.compactMap { set -> Double? in
            guard set.reps > 0 else { return nil }
            // simple Epley formula
            return set.weight * (1 + Double(set.reps) / 30.0)
        }.max()

        return List {
            Section("Personal Records") {
                HStack {
                    Text("Heaviest weight")
                    Spacer()
                    if let s = heaviest {
                        Text("\(s.weight, specifier: "%.1f") x \(s.reps)")
                    } else {
                        Text("N/A").foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("Estimated 1RM")
                    Spacer()
                    if let val = best1RM {
                        Text(String(format: "%.1f", val))
                    } else {
                        Text("N/A").foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text("Max volume (set)")
                    Spacer()
                    if let s = maxVolume {
                        let vol = s.weight * Double(s.reps)
                        Text("\(Int(vol))")
                    } else {
                        Text("N/A").foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Data filtering

    private func filteredSets() -> [SetEntry] {
        let exerciseSets = allSets.filter { $0.exerciseName == exerciseName }
        let now = Date()
        let cal = Calendar.current

        switch range {
        case .allTime:
            return exerciseSets
        case .week:
            guard let from = cal.date(byAdding: .day, value: -7, to: now) else { return exerciseSets }
            return exerciseSets.filter { $0.timestamp >= from }
        case .month:
            guard let from = cal.date(byAdding: .month, value: -1, to: now) else { return exerciseSets }
            return exerciseSets.filter { $0.timestamp >= from }
        case .year:
            guard let from = cal.date(byAdding: .year, value: -1, to: now) else { return exerciseSets }
            return exerciseSets.filter { $0.timestamp >= from }
        }
    }

    private func bestSetTimeline(from sets: [SetEntry]) -> [ChartPoint] {
        let grouped = Dictionary(grouping: sets) { set in
            Calendar.current.startOfDay(for: set.timestamp)
        }

        var points: [ChartPoint] = []
        for (day, sets) in grouped {
            if let best = sets.max(by: { a, b in a.weight < b.weight }) {
                points.append(ChartPoint(date: day, value: best.weight))
            }
        }
        return points.sorted(by: { $0.date < $1.date })
    }

    private func volumeTimeline(from sets: [SetEntry]) -> [ChartPoint] {
        let grouped = Dictionary(grouping: sets) { set in
            Calendar.current.startOfDay(for: set.timestamp)
        }

        var points: [ChartPoint] = []
        for (day, sets) in grouped {
            let vol = sets.reduce(0) { $0 + $1.weight * Double($1.reps) }
            points.append(ChartPoint(date: day, value: vol))
        }
        return points.sorted(by: { $0.date < $1.date })
    }
}

#Preview {
    ExerciseInfoView(exerciseName: "Flat Dumbbell Bench Press")
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
