import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {

    // MARK: - Data
    @Query(sort: \Workout.date, order: .forward) private var workouts: [Workout]
    @Query(sort: \SetEntry.timestamp, order: .forward) private var sets: [SetEntry]

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    weeklySummaryCard
                    streaksCard
                    consistencyCalendarCard
                    muscleHeatmapCard
                    coachRecommendationCard

                    summaryCard
                    if !workouts.isEmpty { volumeOverTimeCard }
                    if !sets.isEmpty { topExercisesCard }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // ----------------------------------------------------------------------
    // MARK: - WEEKLY SUMMARY (NEW)
    // ----------------------------------------------------------------------

    private var weeklySummaryCard: some View {
        let thisWeek = weekStats(offset: 0)
        let lastWeek = weekStats(offset: -1)

        let volumeDeltaPct: String = {
            guard lastWeek.volume > 0 else { return "–" }
            let delta = (thisWeek.volume - lastWeek.volume) / lastWeek.volume * 100
            return String(format: "%+.0f%%", delta)
        }()

        return analyticsCard(title: "Weekly Summary",
                             subtitle: "This week vs last week") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    statBox("Workouts", "\(thisWeek.workouts)")
                    Spacer()
                    statBox("Volume", "\(Int(thisWeek.volume))")
                    Spacer()
                    statBox("Δ Volume", volumeDeltaPct)
                }

                if let muscle = thisWeek.topMuscle {
                    Text("Focus muscle: \(muscle.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private struct WeekStats {
        let workouts: Int
        let volume: Double
        let topMuscle: MuscleGroup?
    }

    private func weekStats(offset: Int) -> WeekStats {
        let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
            from: calendar.date(byAdding: .weekOfYear, value: offset, to: Date())!)
        )!

        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        let weekWorkouts = workouts.filter {
            $0.date >= startOfWeek && $0.date < endOfWeek
        }

        let weekSets = sets.filter {
            $0.timestamp >= startOfWeek && $0.timestamp < endOfWeek
        }

        var muscleVolume: [MuscleGroup: Double] = [:]

        for set in weekSets {
            if let template = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName }) {
                muscleVolume[template.muscleGroup, default: 0] += set.weight * Double(set.reps)
            }
        }

        let topMuscle = muscleVolume.max(by: { $0.value < $1.value })?.key
        let totalVolume = weekSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

        return WeekStats(
            workouts: weekWorkouts.count,
            volume: totalVolume,
            topMuscle: topMuscle
        )
    }

    // ----------------------------------------------------------------------
    // MARK: - STREAKS
    // ----------------------------------------------------------------------

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
            let gap = calendar.dateComponents([.day],
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
            let gap = calendar.dateComponents([.day],
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

    // ----------------------------------------------------------------------
    // MARK: - CONSISTENCY CALENDAR
    // ----------------------------------------------------------------------

    private var consistencyCalendarCard: some View {
        analyticsCard(title: "Consistency (Last 28 Days)") {
            let days = last28Days()
            let activeDays = Set(workouts.map { calendar.startOfDay(for: $0.date) })

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(activeDays.contains(day)
                              ? Color.green.opacity(0.85)
                              : Color.gray.opacity(0.2))
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

    // ----------------------------------------------------------------------
    // MARK: - MUSCLE HEATMAP
    // ----------------------------------------------------------------------

    private var muscleHeatmapCard: some View {
        analyticsCard(title: "Muscle Activation (30 Days)") {
            let volumes = muscleVolumesLast30Days()
            let maxVal = volumes.values.max() ?? 1

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(MuscleGroup.allCases) { group in
                    let value = volumes[group] ?? 0
                    let intensity = max(0.1, value / maxVal)

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

    private func muscleVolumesLast30Days() -> [MuscleGroup: Double] {
        let cutoff = calendar.date(byAdding: .day, value: -30, to: Date())!
        let recent = sets.filter { $0.timestamp >= cutoff }

        var dict: [MuscleGroup: Double] = [:]
        for set in recent {
            if let template = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName }) {
                dict[template.muscleGroup, default: 0] += set.weight * Double(set.reps)
            }
        }
        return dict
    }

    // ----------------------------------------------------------------------
    // MARK: - COACH VIN (ENHANCED)
    // ----------------------------------------------------------------------

    private var coachRecommendationCard: some View {
        analyticsCard(title: "Coach Vin Suggests") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(coachMessages(), id: \.self) { msg in
                    HStack(alignment: .top) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text(msg)
                            .font(.subheadline)
                    }
                }
            }
        }
    }

    private func coachMessages() -> [String] {
        var messages: [String] = []

        let streak = currentStreak()
        if streak >= 7 {
            messages.append("🟡 You’ve trained \(streak) days straight. Consider a light or recovery day.")
        } else if streak >= 4 {
            messages.append("🔥 Strong consistency with a \(streak)-day streak.")
        }

        if let last = workouts.last?.date {
            let gap = calendar.dateComponents([.day], from: last, to: Date()).day ?? 0
            if gap >= 3 {
                messages.append("💡 It’s been \(gap) days since your last workout. A short session could restart momentum.")
            }
        }

        let muscleVolume = muscleVolumesLast30Days()
        if let dominant = muscleVolume.max(by: { $0.value < $1.value })?.key {
            messages.append("⚖️ \(dominant.displayName) is dominating recent volume. Balance with other muscle groups.")
        }

        if workouts.count >= 3 {
            let last3 = workouts.suffix(3).map { $0.totalVolume }
            if last3.count == 3 && last3[2] > last3[1] * 1.35 {
                messages.append("⚠️ Sharp volume spike detected. A deload or mobility day may help recovery.")
            }
        }

        if messages.isEmpty {
            messages.append("💪 Keep building momentum. You’re on a solid path.")
        }

        return messages
    }

    // ----------------------------------------------------------------------
    // MARK: - EXISTING CARDS
    // ----------------------------------------------------------------------

    private var summaryCard: some View {
        let totalVolume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

        return analyticsCard(title: "Overview") {
            HStack {
                statBox("Workouts", "\(workouts.count)")
                Spacer()
                statBox("Sets", "\(sets.count)")
                Spacer()
                statBox("Volume", "\(Int(totalVolume))")
            }
        }
    }

    private var volumeOverTimeCard: some View {
        analyticsCard(title: "Volume Over Time") {
            Chart(workoutVolumePoints()) { pt in
                LineMark(x: .value("Date", pt.date),
                         y: .value("Volume", pt.volume))
            }
            .frame(height: 220)
        }
    }

    private var topExercisesCard: some View {
        let rows = topExercisesByVolume(limit: 5)

        return analyticsCard(title: "Top Exercises") {
            Chart(rows) { row in
                BarMark(x: .value("Volume", row.volume),
                        y: .value("Exercise", row.name))
            }
            .frame(height: CGFloat(rows.count) * 32 + 40)
        }
    }

    // ----------------------------------------------------------------------
    // MARK: - HELPERS
    // ----------------------------------------------------------------------

    private func analyticsCard<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if let subtitle = subtitle {
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            content()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.18), Color.purple.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
    }

    private func statBox(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }

    private struct VolumePoint: Identifiable {
        let id = UUID()
        let date: Date
        let volume: Double
    }

    private func workoutVolumePoints() -> [VolumePoint] {
        workouts.map {
            VolumePoint(date: $0.date, volume: $0.totalVolume)
        }
    }

    private struct ExerciseVolumeRow: Identifiable {
        let id = UUID()
        let name: String
        let volume: Double
    }

    private func topExercisesByVolume(limit: Int) -> [ExerciseVolumeRow] {
        let grouped = Dictionary(grouping: sets, by: { $0.exerciseName })
        return grouped.map { name, sets in
            ExerciseVolumeRow(
                name: name,
                volume: sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            )
        }
        .sorted { $0.volume > $1.volume }
        .prefix(limit)
        .map { $0 }
    }
}
