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
            Group {
                if workouts.isEmpty && sets.isEmpty {
                    analyticsEmptyState
                } else {
                    analyticsContent
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Empty State
    
    private var analyticsEmptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Data Yet")
                    .font(.title2.bold())
                
                Text("Complete workouts and log sets to see your analytics and progress charts")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Content
    
    private var analyticsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                //If you want uncollapsed
                //streakCard
                //muscleDistributionCard
                //muscleStatsGrid
                //coachRecommendationCard
                //undertrainedAlertCard
                // weeklySummaryCard
                //summaryCard
                //consistencyCalendarCard
                //muscleHeatmapCard
                
                // STREAK SECTION - First for motivation!
                CollapsibleSection(
                    title: "Workout Streak",
                    subtitle: "Keep the momentum going!"
                ) {
                    streakCard
                }
                
                collapsibleSection(
                    title: "Muscle Distribution & Balance",
                    initiallyExpanded: true
                ) {
                    VStack(spacing: 16) {
                        muscleDistributionCard
                        muscleStatsGrid
                        coachRecommendationCard
                        undertrainedAlertCard
                    }
                }

                
                

                
                CollapsibleSection(
                    title: "Weekly Summary",
                    subtitle: "This week vs last week"
                ) {
                    weeklySummaryCard
                }

                CollapsibleSection(title: "Consistency") {
                    consistencyCalendarCard
                }

                CollapsibleSection(title: "Muscle Activation") {
                    muscleHeatmapCard
                }

                if !workouts.isEmpty {
                    CollapsibleSection(title: "Volume Over Time") {
                        volumeOverTimeCard
                    }
                }

                if !sets.isEmpty {
                    CollapsibleSection(title: "Top Exercises") {
                        topExercisesCard
                    }
                }

            
                
    
                //if !workouts.isEmpty {
                //    volumeOverTimeCard
                //}

                //if !sets.isEmpty {
                //    topExercisesCard
                //}
            }
            .padding()
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

    
    private func collapsibleSection<Content: View>(
        title: String,
        subtitle: String? = nil,
        initiallyExpanded: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {

        CollapsibleSectionView(
            title: title,
            subtitle: subtitle,
            initiallyExpanded: initiallyExpanded,
            content: content
        )
    }

    private struct CollapsibleSectionView<Content: View>: View {
        let title: String
        let subtitle: String?
        let initiallyExpanded: Bool
        let content: () -> Content

        @State private var isExpanded: Bool

        init(
            title: String,
            subtitle: String?,
            initiallyExpanded: Bool,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.title = title
            self.subtitle = subtitle
            self.initiallyExpanded = initiallyExpanded
            self.content = content
            _isExpanded = State(initialValue: initiallyExpanded)
        }

        var body: some View {
            VStack(spacing: 0) {

                // 👉 THIS is the tappable bar you like
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)

                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.blue.opacity(0.18), .purple.opacity(0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isExpanded.toggle()
                    }
                }

                if isExpanded {
                    content()
                        .padding()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    
    private enum UndertrainingSeverity {
        case mild
        case moderate
        case severe

        var color: Color {
            switch self {
            case .mild: return .yellow
            case .moderate: return .orange
            case .severe: return .red
            }
        }

        var label: String {
            switch self {
            case .mild: return "Low"
            case .moderate: return "Very Low"
            case .severe: return "Critical"
            }
        }
    }

    
    
    private func severity(
        for muscle: MuscleGroup,
        values: [MuscleGroup: Double]
    ) -> UndertrainingSeverity {

        let total = values.values.reduce(0, +)
        let average = total / Double(MuscleGroup.allCases.count)
        let value = values[muscle] ?? 0
        let ratio = average == 0 ? 0 : value / average

        switch ratio {
        case ..<0.4: return .severe
        case ..<0.6: return .moderate
        default:     return .mild
        }
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

    // MARK: - Streak Card

    private var streakCard: some View {
        let streakData = calculateStreakData()
        
        return VStack(spacing: 16) {
            // Current Streak - Large Display
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            streakData.currentStreak > 0 
                            ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        )
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(streakData.currentStreak)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(streakData.currentStreak > 0 ? .primary : .secondary)
                        
                        Text(streakData.currentStreak == 1 ? "Day" : "Days")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(streakData.currentStreak > 0 ? "Current Streak" : "No Active Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            // Stats Grid
            HStack(spacing: 12) {
                // Longest Streak
                VStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    Text("\(streakData.longestStreak)")
                        .font(.title2.bold())
                    
                    Text("Longest")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(10)
                
                // This Month
                VStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(streakData.workoutsThisMonth)")
                        .font(.title2.bold())
                    
                    Text("This Month")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(10)
                
                // This Week
                VStack(spacing: 6) {
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("\(streakData.workoutsThisWeek)")
                        .font(.title2.bold())
                    
                    Text("This Week")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(10)
            }
            
            // Last Workout Info
            if let lastWorkout = streakData.lastWorkoutDate {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.secondary)
                    
                    Text("Last workout: \(formatLastWorkoutDate(lastWorkout))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
    
    // MARK: - Streak Calculations
    
    private struct StreakData {
        var currentStreak: Int
        var longestStreak: Int
        var workoutsThisWeek: Int
        var workoutsThisMonth: Int
        var lastWorkoutDate: Date?
    }
    
    private func calculateStreakData() -> StreakData {
        guard !workouts.isEmpty else {
            return StreakData(currentStreak: 0, longestStreak: 0, workoutsThisWeek: 0, workoutsThisMonth: 0, lastWorkoutDate: nil)
        }
        
        // Get unique workout dates (ignore time)
        let workoutDates = workouts
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        let uniqueDates = Array(Set(workoutDates)).sorted(by: >)
        
        // Calculate current streak
        var currentStreak = 0
        let today = calendar.startOfDay(for: Date())
        
        if let mostRecent = uniqueDates.first {
            let daysSinceLastWorkout = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
            
            // Only count as active if workout was today or yesterday
            if daysSinceLastWorkout <= 1 {
                var checkDate = mostRecent
                for date in uniqueDates {
                    if calendar.isDate(date, inSameDayAs: checkDate) {
                        currentStreak += 1
                        checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
                    } else if calendar.dateComponents([.day], from: date, to: checkDate).day ?? 0 > 1 {
                        break
                    }
                }
            }
        }
        
        // Calculate longest streak
        var longestStreak = 0
        var tempStreak = 0
        var previousDate: Date?
        
        for date in uniqueDates.reversed() {
            if let prev = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                if daysDiff == 1 {
                    tempStreak += 1
                } else {
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            previousDate = date
        }
        longestStreak = max(longestStreak, tempStreak)
        
        // This week
        let startOfWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: today)
        let weekStart = calendar.date(from: startOfWeek) ?? today
        let workoutsThisWeek = workouts.filter { $0.date >= weekStart }.count
        
        // This month
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        let workoutsThisMonth = workouts.filter { $0.date >= startOfMonth }.count
        
        return StreakData(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            workoutsThisWeek: workoutsThisWeek,
            workoutsThisMonth: workoutsThisMonth,
            lastWorkoutDate: workouts.last?.date
        )
    }
    
    private func formatLastWorkoutDate(_ date: Date) -> String {
        let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: Date())).day ?? 0
        
        if daysDiff == 0 {
            return "Today"
        } else if daysDiff == 1 {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
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
                        let values = distributionValues()

                        ForEach(undertrained) { muscle in
                            let severity = severity(for: muscle, values: values)

                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(severity.color)

                                Text(muscle.displayName)
                                    .font(.body)

                                Spacer()

                                Text(severity.label)
                                    .font(.caption)
                                    .foregroundStyle(severity.color)
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


    private func balanceScore() -> Int {
        let values = distributionValues()
        guard !values.isEmpty else { return 100 }

        let total = values.values.reduce(0, +)
        let avg = total / Double(MuscleGroup.allCases.count)
        guard avg > 0 else { return 100 }

        let deviation = values.values.reduce(0) { sum, value in
            sum + abs(value - avg) / avg
        } / Double(MuscleGroup.allCases.count)

        return max(0, Int(100 - deviation * 100))
    }

    private func mostUndertrainedMuscle() -> MuscleGroup? {
        let values = distributionValues()
        guard !values.isEmpty else { return nil }

        let total = values.values.reduce(0, +)
        let avg = total / Double(MuscleGroup.allCases.count)

        return values
            .min { ($0.value / avg) < ($1.value / avg) }?
            .key
    }

    private func coachMessage() -> String {
        let score = balanceScore()

        guard let muscle = mostUndertrainedMuscle() else {
            return "Your training looks well balanced. Keep up the consistent work."
        }

        if score >= 85 {
            return "Your muscle group balance score is \(score)%. Training is well distributed across muscle groups. Keep maintaining this balance."
        }

        let metricText = selectedMetric == .volume ? "training volume" : "set count"

        return """
        Your muscle group balance score is \(score)%.
        Increasing \(muscle.displayName.lowercased()) \(metricText) will help improve overall balance.
        """
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
            Text(coachMessage())
                .font(.body)
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

private struct CollapsibleSection<Content: View>: View {
    let title: String
    let subtitle: String?
    @State private var expanded = false
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut) {
                    expanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(title).font(.headline)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }

            if expanded {
                content
            }
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
}

