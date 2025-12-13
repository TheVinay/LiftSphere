import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {

    // MARK: - Data
    @Query(sort: \Workout.date, order: .forward) private var workouts: [Workout]
    @Query(sort: \SetEntry.timestamp, order: .forward) private var sets: [SetEntry]

    private let calendar = Calendar.current

    // MARK: - Controls
    @State private var selectedRange: TimeRange = .days30
    @State private var selectedMetric: MetricType = .volume
    @State private var selectedMuscle: MuscleGroup? = nil
    


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    weeklySummaryCard
                    summaryCard
                    streaksCard
                    muscleDistributionCard
                    muscleStatsGrid
                    undertrainedAlertCard
                    consistencyCalendarCard
                    muscleHeatmapCard
                    coachRecommendationCard

                    if !workouts.isEmpty {
                        volumeOverTimeCard
                    }

                    if !sets.isEmpty {
                        topExercisesCard
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Time Range / Metric

    enum TimeRange: String, CaseIterable, Identifiable {
        case days7  = "Last 7 days"
        case days15 = "Last 15 days"
        case days30 = "Last 30 days"
        case days90 = "Last 90 days"
        case all    = "All time"

        var id: String { rawValue }

        func cutoff(calendar: Calendar) -> Date? {
            switch self {
            case .days7:  return calendar.date(byAdding: .day, value: -7, to: Date())
            case .days15: return calendar.date(byAdding: .day, value: -15, to: Date())
            case .days30: return calendar.date(byAdding: .day, value: -30, to: Date())
            case .days90: return calendar.date(byAdding: .day, value: -90, to: Date())
            case .all:    return nil
            }
        }
    }

    enum MetricType: String, CaseIterable, Identifiable {
        case volume = "Volume"
        case sets = "Sets"
        var id: String { rawValue }
    }

    // MARK: - Weekly Summary

    private var weeklySummaryCard: some View {
        let thisWeek = weekStats(offset: 0)
        let lastWeek = weekStats(offset: -1)

        let delta: String = {
            guard lastWeek.volume > 0 else { return "–" }
            let pct = (thisWeek.volume - lastWeek.volume) / lastWeek.volume * 100
            return String(format: "%+.0f%%", pct)
        }()

        return analyticsCard(title: "Weekly Summary", subtitle: "This week vs last week") {
            HStack {
                statBox("Workouts", "\(thisWeek.workouts)")
                Spacer()
                statBox("Volume", "\(Int(thisWeek.volume))")
                Spacer()
                statBox("Δ Volume", delta)
            }
        }
    }
    
    private func undertrainedMuscles(
        thresholdRatio: Double = 0.6
    ) -> [MuscleGroup] {

        let values = distributionValues()
        guard !values.isEmpty else { return [] }

        let total = values.values.reduce(0, +)
        guard total > 0 else { return [] }

        let average = total / Double(MuscleGroup.allCases.count)

        return MuscleGroup.allCases.filter { muscle in
            let value = values[muscle] ?? 0
            return value < average * thresholdRatio
        }
    }


    private struct WeekStats {
        let workouts: Int
        let volume: Double
    }

    private func weekStats(offset: Int) -> WeekStats {
        let start = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
            from: calendar.date(byAdding: .weekOfYear, value: offset, to: Date())!)
        )!

        let end = calendar.date(byAdding: .day, value: 7, to: start)!

        let weekWorkouts = workouts.filter { $0.date >= start && $0.date < end }
        let weekSets = sets.filter { $0.timestamp >= start && $0.timestamp < end }

        let volume = weekSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

        return WeekStats(workouts: weekWorkouts.count, volume: volume)
    }

    // MARK: - Streaks

    private var streaksCard: some View {
        analyticsCard(title: "Streaks & Activity") {
            HStack {
                statBox("Current", "\(currentStreak()) days")
                Spacer()
                statBox("Longest", "\(longestStreak())")
                Spacer()
                statBox("This month", "\(workoutsInCurrentMonth())")
            }
        }
    }

    private func currentStreak() -> Int {
        let sorted = workouts.sorted { $0.date > $1.date }
        guard !sorted.isEmpty else { return 0 }

        var streak = 1
        for i in 1..<sorted.count {
            let gap = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: sorted[i].date),
                to: calendar.startOfDay(for: sorted[i - 1].date)
            ).day ?? 99

            if gap == 1 { streak += 1 } else { break }
        }
        return streak
    }

    private func longestStreak() -> Int {
        guard workouts.count > 1 else { return workouts.isEmpty ? 0 : 1 }

        let sorted = workouts.sorted { $0.date > $1.date }
        var longest = 1
        var current = 1

        for i in 1..<sorted.count {
            let gap = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: sorted[i].date),
                to: calendar.startOfDay(for: sorted[i - 1].date)
            ).day ?? 99

            if gap == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    private func workoutsInCurrentMonth() -> Int {
        workouts.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
        }.count
    }

    // MARK: - Consistency

    private var consistencyCalendarCard: some View {
        analyticsCard(title: "Consistency (Last 28 Days)") {
            let days = last28Days()
            let active = Set(workouts.map { calendar.startOfDay(for: $0.date) })

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(active.contains(day) ? .green : .gray.opacity(0.2))
                        .frame(width: 22, height: 22)
                }
            }
        }
    }

    private func last28Days() -> [Date] {
        (0..<28).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: Date())
                .map { calendar.startOfDay(for: $0) }
        }.reversed()
    }

    // MARK: - Muscle Heatmap

    private var muscleHeatmapCard: some View {
        analyticsCard(title: "Muscle Activation (30 Days)") {
            let volumes = muscleVolumes(days: 30)
            let maxVal = volumes.values.max() ?? 1

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(MuscleGroup.allCases) { group in
                    let val = volumes[group] ?? 0
                    let intensity = max(0.15, val / maxVal)

                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(intensity))
                            .frame(height: 50)

                        Text(group.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func muscleVolumes(days: Int) -> [MuscleGroup: Double] {
        let cutoff = calendar.date(byAdding: .day, value: -days, to: Date())!
        let recent = sets.filter { $0.timestamp >= cutoff }

        var dict: [MuscleGroup: Double] = [:]
        for set in recent {
            if let ex = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName }) {
                dict[ex.muscleGroup, default: 0] += set.weight * Double(set.reps)
            }
        }
        return dict
    }

    // MARK: - Muscle Distribution

    private var muscleDistributionCard: some View {
        analyticsCard(title: "Muscle Distribution") {
            VStack(spacing: 12) {
                HStack {
                    Picker("", selection: $selectedRange) {
                        ForEach(TimeRange.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    Picker("", selection: $selectedMetric) {
                        ForEach(MetricType.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }

                RadarChartView(
                    values: distributionValues(),
                    previousValues: previousDistributionValues(),
                    maxValue: max(
                        distributionValues().values.max() ?? 1,
                        previousDistributionValues().values.max() ?? 1
                    ),
                    selectedMuscle: $selectedMuscle
                )

                .frame(height: 260)
            }
        }
    }
    
    private var undertrainedAlertCard: some View {
        let undertrained = undertrainedMuscles()

        return Group {
            if !undertrained.isEmpty {
                analyticsCard(
                    title: "Undertrained Muscles",
                    subtitle: "Based on recent \(selectedMetric.rawValue.lowercased())"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(undertrained) { muscle in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)

                                Text(muscle.displayName)
                                    .font(.body)

                                Spacer()

                                Text("Low")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                selectedMuscle = muscle
                            }
                        }
                    }
                }
            }
        }
    }


    
    private func nearestMuscle(from size: CGSize, muscles: [MuscleGroup]) -> MuscleGroup? {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let location = CGPoint(x: center.x, y: 0) // tap already inside polygon

        let angle = atan2(location.y - center.y, location.x - center.x)

        let normalized = angle < -(.pi / 2)
            ? angle + 2 * .pi
            : angle

        let index = Int(
            round((normalized + .pi / 2) / (2 * .pi) * Double(muscles.count))
        ) % muscles.count

        return muscles[index]
    }

    
    
    
    
    
    

    private func distributionValues() -> [MuscleGroup: Double] {
        let relevantSets: [SetEntry]
        if let cutoff = selectedRange.cutoff(calendar: calendar) {
            relevantSets = sets.filter { $0.timestamp >= cutoff }
        } else {
            relevantSets = sets
        }

        var dict: [MuscleGroup: Double] = [:]
        for set in relevantSets {
            if let ex = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName }) {
                if selectedMetric == .volume {
                    dict[ex.muscleGroup, default: 0] += set.weight * Double(set.reps)
                } else {
                    dict[ex.muscleGroup, default: 0] += 1
                }
            }
        }
        return dict
    }

    // MARK: - Radar Chart View (FIXED)
    private func previousDistributionValues() -> [MuscleGroup: Double] {
        
        let duration: Int
        switch selectedRange {
        case .days7:  duration = 7
        case .days15: duration = 15
        case .days30: duration = 30
        case .days90: duration = 90
        case .all:    return [:]
        }

        let previousStart = calendar.date(byAdding: .day, value: -duration * 2, to: Date())!
        let previousEnd   = calendar.date(byAdding: .day, value: -duration, to: Date())!

        let previousSets = sets.filter {
            $0.timestamp >= previousStart && $0.timestamp < previousEnd
        }

        var dict: [MuscleGroup: Double] = [:]
        for set in previousSets {
            if let ex = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName }) {
                if selectedMetric == .volume {
                    dict[ex.muscleGroup, default: 0] += set.weight * Double(set.reps)
                } else {
                    dict[ex.muscleGroup, default: 0] += 1
                }
            }
        }

        return dict
    }


    private struct RadarChartView: View {
        let values: [MuscleGroup: Double]
        let previousValues: [MuscleGroup: Double]
        let maxValue: Double
        @Binding var selectedMuscle: MuscleGroup?

        var body: some View {
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 - 20
                let muscles = MuscleGroup.allCases

                ZStack {
                    
                    if !previousValues.isEmpty {
                        Path { path in
                            for i in muscles.indices {
                                let angle = angleFor(index: i, count: muscles.count)
                                let value = previousValues[muscles[i]] ?? 0
                                let scaled = CGFloat(value / maxValue) * radius

                                let point = CGPoint(
                                    x: center.x + cos(angle) * scaled,
                                    y: center.y + sin(angle) * scaled
                                )

                                i == 0 ? path.move(to: point) : path.addLine(to: point)
                            }
                            path.closeSubpath()
                        }
                        .stroke(Color.gray.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }

                    
                    ForEach(muscles.indices, id: \.self) { i in
                        let angle = angleFor(index: i, count: muscles.count)
                        let end = CGPoint(
                            x: center.x + cos(angle) * radius,
                            y: center.y + sin(angle) * radius
                        )

                        Path {
                            $0.move(to: center)
                            $0.addLine(to: end)
                        }
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)

                        Text("""
                        \(muscles[i].displayName)
                        \(percentage(for: muscles[i]))%
                        """)
                        .font(.caption)
                        .multilineTextAlignment(.center)

                            .font(.caption)
                            .foregroundStyle(
                                selectedMuscle == muscles[i] ? .blue : .secondary
                            )
                            .position(
                                x: center.x + cos(angle) * (radius + 16),
                                y: center.y + sin(angle) * (radius + 16)
                            )
                            .onTapGesture {
                                selectedMuscle =
                                    selectedMuscle == muscles[i] ? nil : muscles[i]
                            }
                    }

                    
                    
                    ForEach(muscles.indices, id: \.self) { i in
                        let muscle = muscles[i]

                        let angle = angleFor(index: i, count: muscles.count)
                        let nextAngle = angleFor(index: (i + 1) % muscles.count, count: muscles.count)

                        let value = values[muscle] ?? 0
                        let nextValue = values[muscles[(i + 1) % muscles.count]] ?? 0

                        let scaled = CGFloat(value / maxValue) * radius
                        let nextScaled = CGFloat(nextValue / maxValue) * radius

                        Path { path in
                            path.move(to: center)
                            path.addLine(
                                to: CGPoint(
                                    x: center.x + cos(angle) * scaled,
                                    y: center.y + sin(angle) * scaled
                                )
                            )
                            path.addLine(
                                to: CGPoint(
                                    x: center.x + cos(nextAngle) * nextScaled,
                                    y: center.y + sin(nextAngle) * nextScaled
                                )
                            )
                            path.closeSubpath()
                        }
                        .fill(
                            Color.blue.opacity(
                                selectedMuscle == nil || selectedMuscle == muscle ? 0.45 : 0.12
                            )
                        )
                        .overlay(
                            Path { path in
                                path.move(to: center)
                                path.addLine(
                                    to: CGPoint(
                                        x: center.x + cos(angle) * scaled,
                                        y: center.y + sin(angle) * scaled
                                    )
                                )
                                path.addLine(
                                    to: CGPoint(
                                        x: center.x + cos(nextAngle) * nextScaled,
                                        y: center.y + sin(nextAngle) * nextScaled
                                    )
                                )
                                path.closeSubpath()
                            }
                            .stroke(Color.blue, lineWidth: 1.5)
                        )
                        .animation(.easeInOut(duration: 0.25), value: selectedMuscle)
                        .contentShape(Path { path in
                            path.move(to: center)
                            path.addLine(
                                to: CGPoint(
                                    x: center.x + cos(angle) * radius,
                                    y: center.y + sin(angle) * radius
                                )
                            )
                            path.addLine(
                                to: CGPoint(
                                    x: center.x + cos(nextAngle) * radius,
                                    y: center.y + sin(nextAngle) * radius
                                )
                            )
                            path.closeSubpath()
                        })
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    selectedMuscle =
                                        (selectedMuscle == muscle) ? nil : muscle
                                }
                        )
                    }

                    
                    
                    



                    
                }
            }
        }

        private func angleFor(index: Int, count: Int) -> CGFloat {
            CGFloat(Double(index) / Double(count) * 2 * .pi - .pi / 2)
        }
        
        
        private func percentage(for muscle: MuscleGroup) -> Int {
            let total = values.values.reduce(0, +)
            guard total > 0 else { return 0 }
            return Int((values[muscle, default: 0] / total) * 100)
        }

        
        
        private func nearestMuscle(
            tap: CGPoint,
            size: CGSize,
            muscles: [MuscleGroup]
        ) -> MuscleGroup {

            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            let angle = atan2(
                tap.y - center.y,
                tap.x - center.x
            )

            // Rotate so 0 starts at top
            let adjusted = angle + .pi / 2
            let normalized = adjusted < 0 ? adjusted + 2 * .pi : adjusted

            let slice = 2 * .pi / Double(muscles.count)
            let index = Int(normalized / slice) % muscles.count

            return muscles[index]
        }

        
        
    }


    // MARK: - Stats Grid

    private var muscleStatsGrid: some View {
        let stats = aggregateStats()

        return LazyVGrid(columns: [GridItem(), GridItem()]) {
            statTile("Workouts", "\(stats.workouts)")
            statTile("Duration", stats.duration)
            statTile("Volume", "\(Int(stats.volume))")
            statTile("Sets", "\(stats.sets)")
        }
        .animation(.easeInOut(duration: 0.25), value: selectedMuscle)
        .animation(.easeInOut(duration: 0.25), value: selectedRange)
        .animation(.easeInOut(duration: 0.25), value: selectedMetric)
    }

    private func aggregateStats() -> (workouts: Int, sets: Int, volume: Double, duration: String) {

        let relevantSets = sets.filter { set in
            guard let cutoff = selectedRange.cutoff(calendar: calendar) else { return true }
            guard set.timestamp >= cutoff else { return false }

            guard let selectedMuscle else { return true }

            guard
                let exercise = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName })
            else {
                return false
            }

            return exercise.muscleGroup == selectedMuscle
        }

        let relevantWorkouts = workouts.filter {
            guard let cutoff = selectedRange.cutoff(calendar: calendar) else { return true }
            return $0.date >= cutoff
        }

        let volume = relevantSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        let duration = "\(relevantWorkouts.count)h"

        return (
            relevantWorkouts.count,
            relevantSets.count,
            volume,
            duration
        )
    }


    // MARK: - Coach

    private var coachRecommendationCard: some View {
        analyticsCard(title: "Coach Vin Suggests") {
            Text("💪 Keep building momentum. You’re on a solid path.")
        }
    }

    // MARK: - Overview / Charts

    private var summaryCard: some View {
        let volume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

        return analyticsCard(title: "Overview") {
            HStack {
                statBox("Workouts", "\(workouts.count)")
                Spacer()
                statBox("Sets", "\(sets.count)")
                Spacer()
                statBox("Volume", "\(Int(volume))")
            }
        }
    }

    private var volumeOverTimeCard: some View {
        analyticsCard(title: "Volume Over Time") {
            Chart(workouts) {
                LineMark(
                    x: .value("Date", $0.date),
                    y: .value("Volume", $0.totalVolume)
                )
            }
            .frame(height: 220)
        }
    }

    private var topExercisesCard: some View {
        let rows = Dictionary(grouping: sets, by: { $0.exerciseName })
            .map { ($0.key, $0.value.reduce(0) { $0 + ($1.weight * Double($1.reps)) }) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)

        return analyticsCard(title: "Top Exercises") {
            Chart(rows, id: \.0) {
                BarMark(
                    x: .value("Volume", $0.1),
                    y: .value("Exercise", $0.0)
                )
            }
            .frame(height: 200)
        }
    }

    // MARK: - UI Helpers

    private func analyticsCard<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if let subtitle {
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            content()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.18), .purple.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statBox(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func statTile(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(value).font(.title2.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
