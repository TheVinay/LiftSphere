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

                    streaksCard
                    consistencyCalendarCard
                    muscleHeatmapCard
                    coachRecommendationCard

                    // Existing cards
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
    // MARK: - FEATURE 7: STREAKS CARD
    // ----------------------------------------------------------------------

    private var streaksCard: some View {
        let streak = currentStreak()
        let longest = longestStreak()
        let workoutsThisMonth = workoutsInCurrentMonth()

        return analyticsCard(title: "Streaks & Activity") {
            HStack {
                statBox("Current streak", "\(streak) days")
                Spacer()
                statBox("Longest streak", "\(longest)")
                Spacer()
                statBox("This month", "\(workoutsThisMonth)")
            }
            .padding(.top, 4)
        }
    }

    // Calculate streak
    private func currentStreak() -> Int {
        guard !workouts.isEmpty else { return 0 }
        let sorted = workouts.sorted { $0.date > $1.date }

        var streak = 1
        for i in 1..<sorted.count {
            let dayGap = calendar.dateComponents([.day],
                from: calendar.startOfDay(for: sorted[i].date),
                to: calendar.startOfDay(for: sorted[i - 1].date)
            ).day ?? 99

            if dayGap == 1 { streak += 1 }
            else { break }
        }
        return streak
    }

    private func longestStreak() -> Int {
        guard workouts.count > 1 else { return workouts.isEmpty ? 0 : 1 }

        let sorted = workouts.sorted { $0.date > $1.date }
        var longest = 1
        var streak = 1

        for i in 1..<sorted.count {
            let dayGap = calendar.dateComponents([.day],
                from: calendar.startOfDay(for: sorted[i].date),
                to: calendar.startOfDay(for: sorted[i - 1].date)
            ).day ?? 99

            if dayGap == 1 {
                streak += 1
                longest = max(longest, streak)
            } else {
                streak = 1
            }
        }
        return longest
    }

    private func workoutsInCurrentMonth() -> Int {
        guard !workouts.isEmpty else { return 0 }
        let now = Date()
        return workouts.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
    }

    // ----------------------------------------------------------------------
    // MARK: - FEATURE 7 PART 2: CONSISTENCY CALENDAR (28 days)
    // ----------------------------------------------------------------------

    private var consistencyCalendarCard: some View {
        analyticsCard(title: "Consistency (Last 28 Days)") {
            let days = last28Days()
            let daysWithWorkouts = Set(workouts.map { calendar.startOfDay(for: $0.date) })

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { day in
                    let active = daysWithWorkouts.contains(day)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(active ? Color.green.opacity(0.9) : Color.gray.opacity(0.2))
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.top, 4)
        }
    }

    private func last28Days() -> [Date] {
        (0..<28).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: Date())
                .map { calendar.startOfDay(for: $0) }
        }.reversed()
    }

    // ----------------------------------------------------------------------
    // MARK: - FEATURE 11: MUSCLE ACTIVATION HEATMAP
    // ----------------------------------------------------------------------

    private var muscleHeatmapCard: some View {
        analyticsCard(title: "Muscle Activation Heatmap") {
            let volumes = muscleVolumesLast30Days()
            let maxVal = volumes.values.max() ?? 1

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
            ], spacing: 16) {
                ForEach(MuscleGroup.allCases) { group in
                    let value = volumes[group] ?? 0
                    let intensity = max(0.1, value / maxVal)

                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(Double(intensity)))
                            .frame(height: 50)

                        Text(group.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 6)
        }
    }

    // Sum volume per muscle group
    private func muscleVolumesLast30Days() -> [MuscleGroup: Double] {
        let cutoff = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        let recent = sets.filter { $0.timestamp >= cutoff }

        var dict: [MuscleGroup: Double] = [:]

        for set in recent {
            guard let template = ExerciseLibrary.all.first(where: { $0.name == set.exerciseName }) else { continue }
            let group = template.muscleGroup
            let vol = set.weight * Double(set.reps)
            dict[group, default: 0] += vol
        }

        return dict
    }

    // ----------------------------------------------------------------------
    // MARK: - FEATURE 12: AI COACH VIN
    // ----------------------------------------------------------------------

    private var coachRecommendationCard: some View {
        analyticsCard(title: "Coach Vin Suggests") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(coachMessages(), id: \.self) { msg in
                    HStack(alignment: .top) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text(msg)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    private func coachMessages() -> [String] {
        var messages: [String] = []

        // Streak-based
        let streak = currentStreak()
        if streak >= 5 {
            messages.append("🔥 You’re on a \(streak)-day streak—keep the momentum!")
        } else if streak == 0 {
            messages.append("👟 Time to start a new streak today.")
        }

        // Missing workouts
        if let last = workouts.last?.date {
            let gap = calendar.dateComponents([ .day ], from: last, to: Date()).day ?? 0
            if gap >= 3 {
                messages.append("💡 You haven’t trained in \(gap) days. A light session would reboot momentum.")
            }
        }

        // Muscle imbalance check
        let muscle = muscleVolumesLast30Days()
        if let maxMuscle = muscle.max(by: { $0.value < $1.value })?.key {
            messages.append("📌 Your most trained muscle group recently: \(maxMuscle.displayName). Consider balancing with other groups.")
        }

        // Volume spike warning
        if workouts.count >= 3 {
            let last3 = workouts.suffix(3).map { $0.totalVolume }
            if last3.count == 3,
               last3[2] > last3[1] * 1.35 {
                messages.append("⚠️ Volume jumped sharply yesterday. Consider a deload or mobility day.")
            }
        }

        if messages.isEmpty {
            messages.append("💪 Keep training! You're building a great foundation.")
        }

        return messages
    }

    // ----------------------------------------------------------------------
    // MARK: - Existing Cards (summary, volume, top exercises)
    // ----------------------------------------------------------------------

    private var summaryCard: some View {
        let totalVolume = sets.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }

        return analyticsCard(title: "Overview") {
            HStack {
                statBox("Workouts", "\(workouts.count)")
                Spacer()
                statBox("Sets Logged", "\(sets.count)")
                Spacer()
                statBox("Total Volume", "\(Int(totalVolume))")
            }
        }
    }

    private var volumeOverTimeCard: some View {
        let points = workoutVolumePoints()

        return analyticsCard(title: "Volume Over Time",
                             subtitle: "Total volume per workout") {
            if points.isEmpty {
                Text("Log a few workouts to see volume trends.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(points) { pt in
                    LineMark(x: .value("Date", pt.date),
                             y: .value("Volume", pt.volume))
                    PointMark(x: .value("Date", pt.date),
                              y: .value("Volume", pt.volume))
                }
                .frame(height: 220)
            }
        }
    }

    private var topExercisesCard: some View {
        let rows = topExercisesByVolume(limit: 5)

        return analyticsCard(title: "Top Exercises",
                             subtitle: "By total volume (weight × reps)") {
            if rows.isEmpty {
                Text("Log some sets to see your strongest lifts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(rows) { row in
                    BarMark(
                        x: .value("Volume", row.volume),
                        y: .value("Exercise", row.name)
                    )
                }
                .frame(height: max(160, CGFloat(rows.count) * 32))
            }
        }
    }

    // ----------------------------------------------------------------------
    // MARK: - Helpers
    // ----------------------------------------------------------------------

    private func analyticsCard<Content: View>(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    struct VolumePoint: Identifiable {
        let id = UUID()
        let date: Date
        let volume: Double
    }

    private func workoutVolumePoints() -> [VolumePoint] {
        workouts.sorted { $0.date < $1.date }.map {
            VolumePoint(date: $0.date, volume: $0.totalVolume)
        }
    }

    struct ExerciseVolumeRow: Identifiable {
        let id = UUID()
        let name: String
        let volume: Double
    }

    private func topExercisesByVolume(limit: Int) -> [ExerciseVolumeRow] {
        guard !sets.isEmpty else { return [] }

        let grouped = Dictionary(grouping: sets, by: { $0.exerciseName })

        return grouped.map { (name, groupSets) in
            ExerciseVolumeRow(
                name: name,
                volume: groupSets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            )
        }
        .sorted { $0.volume > $1.volume }
        .prefix(limit)
        .map { $0 }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
