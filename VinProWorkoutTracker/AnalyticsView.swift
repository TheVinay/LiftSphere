import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {

    // MARK: - Data
    @Query(sort: \Workout.date, order: .forward) private var workouts: [Workout]
    @Query(sort: \SetEntry.timestamp, order: .forward) private var sets: [SetEntry]

    
    // Secondary muscle weighting factor (used only if present)
    private let secondaryWeight: Double = 0.35

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
            // 🔍 UNCOMMENT THIS LINE TO SEE EXERCISE MAPPING DEBUG INFO
            // .onAppear { debugUnmappedExercises() }
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
                    VStack(alignment: .leading, spacing: 20) {
                        // Filters
                        HStack {
                            Picker("", selection: $selectedRange) {
                                ForEach(TimeRange.allCases) { Text($0.rawValue).tag($0) }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)

                            Spacer()

                            Picker("", selection: $selectedMetric) {
                                ForEach(MetricType.allCases) { Text($0.rawValue).tag($0) }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }

                        // Radar chart
                        let currentValues = distributionValues()
                        let prevValues = previousDistributionValues()
                        let maxVal = max(
                            currentValues.values.max() ?? 1,
                            prevValues.values.max() ?? 1
                        )
                        
                        RadarChartView(
                            values: currentValues,
                            previousValues: prevValues,
                            maxValue: maxVal,
                            selectedMuscle: $selectedMuscle
                        )
                        .frame(height: 260)
                        .id("\(selectedRange.rawValue)-\(selectedMetric.rawValue)-\(sets.count)")
                        
                        Divider()
                        
                        // Stats grid
                        muscleStatsGrid
                        
                        Divider()
                        
                        // Training insights
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .foregroundStyle(.blue)
                                Text("Training Insights")
                                    .font(.subheadline.weight(.semibold))
                            }
                            
                            Text(coachMessage())
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        
                        // Undertrained muscles (if any)
                        let undertrained = undertrainedMuscles()
                        if !undertrained.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                    Text("Needs Attention")
                                        .font(.subheadline.weight(.semibold))
                                }
                                
                                Text("Muscles that need more attention based on recent training")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    // Use the already calculated values from above
                                    ForEach(undertrained) { muscle in
                                        let severity = severity(for: muscle, values: currentValues)

                                        HStack {
                                            Image(systemName: "circle.fill")
                                                .font(.system(size: 6))
                                                .foregroundStyle(severity.color)

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
                    .animation(.easeInOut(duration: 0.2), value: selectedRange)
                    .animation(.easeInOut(duration: 0.2), value: selectedMetric)
                    .animation(.easeInOut(duration: 0.2), value: selectedMuscle)
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

                CollapsibleSection(
                    title: "Muscle Activation",
                    subtitle: "Last 30 days"
                ) {
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
    
    private func applyExerciseContribution(
        _ exercise: ExerciseTemplate,
        set: SetEntry,
        dict: inout [MuscleGroup: Double]
    ) {
        let base: Double = selectedMetric == .volume
            ? set.weight * Double(set.reps)
            : 1

        // Primary muscle always gets full weight
        dict[exercise.muscleGroup, default: 0] += base

        // Secondary muscle gets partial weight (if available)
        if let secondary = exercise.secondaryMuscleGroup {
            dict[secondary, default: 0] += base * secondaryWeight
        }
    }
    
    /// Attempts to infer muscle group and create a temporary exercise template from exercise name
    /// This is a fallback for when the exact exercise isn't found in the library
    private func inferExerciseFromName(_ name: String) -> ExerciseTemplate? {
        let nameLower = name.lowercased()
        
        // Biceps patterns
        if nameLower.contains("curl") && !nameLower.contains("leg") && !nameLower.contains("hamstring") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .biceps,
                equipment: .dumbbell,
                secondaryMuscleGroup: .forearms
            )
        }
        
        // Triceps patterns
        if nameLower.contains("tricep") || nameLower.contains("pushdown") || 
           nameLower.contains("overhead extension") || nameLower.contains("skull crusher") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .triceps,
                equipment: .dumbbell
            )
        }
        
        // Chest patterns
        if nameLower.contains("press") && (nameLower.contains("chest") || nameLower.contains("bench")) {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .chest,
                equipment: .barbell,
                secondaryMuscleGroup: .triceps
            )
        }
        
        if nameLower.contains("fly") || nameLower.contains("flye") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .chest,
                equipment: .dumbbell
            )
        }
        
        // Back patterns
        if nameLower.contains("row") || nameLower.contains("pulldown") || 
           nameLower.contains("pull-up") || nameLower.contains("pullup") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .back,
                equipment: .cable,
                secondaryMuscleGroup: .biceps
            )
        }
        
        if nameLower.contains("deadlift") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .back,
                equipment: .barbell,
                secondaryMuscleGroup: .hamstrings
            )
        }
        
        // Shoulder patterns
        if (nameLower.contains("press") || nameLower.contains("raise")) && 
           (nameLower.contains("shoulder") || nameLower.contains("lateral") || nameLower.contains("front")) {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .shoulders,
                equipment: .dumbbell
            )
        }
        
        // Leg patterns
        if nameLower.contains("squat") || nameLower.contains("leg press") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .quads,
                equipment: .barbell,
                secondaryMuscleGroup: .glutes
            )
        }
        
        if nameLower.contains("lunge") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .quads,
                equipment: .bodyweight,
                secondaryMuscleGroup: .glutes
            )
        }
        
        if (nameLower.contains("leg") && nameLower.contains("curl")) || nameLower.contains("hamstring") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .hamstrings,
                equipment: .machine
            )
        }
        
        if nameLower.contains("calf") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .calves,
                equipment: .machine
            )
        }
        
        // Glute patterns
        if nameLower.contains("glute") || nameLower.contains("hip thrust") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .glutes,
                equipment: .barbell
            )
        }
        
        // Core patterns
        if nameLower.contains("crunch") || nameLower.contains("sit") || 
           nameLower.contains("plank") || nameLower.contains("ab") {
            return ExerciseTemplate(
                name: name,
                muscleGroup: .abs,
                equipment: .bodyweight
            )
        }
        
        // If we can't infer, return nil (better to skip than guess wrong)
        return nil
    }
    
    /// Finds an exercise from the library with flexible matching
    /// Tries exact match first, then case-insensitive, then trimmed/normalized
    private func findExercise(named name: String) -> ExerciseTemplate? {
        // 1. Exact match (fastest)
        if let exact = ExerciseLibrary.all.first(where: { $0.name == name }) {
            return exact
        }
        
        // 2. Case-insensitive match
        let nameLower = name.lowercased()
        if let caseInsensitive = ExerciseLibrary.all.first(where: { $0.name.lowercased() == nameLower }) {
            return caseInsensitive
        }
        
        // 3. Trimmed and normalized (remove extra spaces, special characters)
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "  ", with: " ")
        
        if let trimmed = ExerciseLibrary.all.first(where: { 
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "  ", with: " ") == normalized 
        }) {
            return trimmed
        }
        
        // 4. Try without parentheses/descriptions (e.g., "Bicep Curl (Machine)" -> "Bicep Curl")
        let withoutParens = name.components(separatedBy: "(").first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? name
        
        if let matched = ExerciseLibrary.all.first(where: { 
            $0.name.components(separatedBy: "(").first?
                .trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == withoutParens.lowercased()
        }) {
            return matched
        }
        
        // Not found - will fall back to inference
        return nil
    }
    
    #if DEBUG
    /// Diagnostic function to check which exercises in your sets aren't being found
    /// Call this temporarily to debug exercise mapping issues
    private func debugUnmappedExercises() {
        let uniqueExercises = Set(sets.map { $0.exerciseName })
        
        print("=== EXERCISE MAPPING DEBUG ===")
        print("Total unique exercises in sets: \(uniqueExercises.count)")
        
        var foundExact = 0
        var foundFlexible = 0
        var foundInferred = 0
        var notFound = 0
        
        for exercise in uniqueExercises.sorted() {
            if ExerciseLibrary.all.contains(where: { $0.name == exercise }) {
                foundExact += 1
                print("✅ EXACT: \(exercise)")
            } else if let found = findExercise(named: exercise) {
                foundFlexible += 1
                print("🔄 FLEXIBLE: \(exercise) -> \(found.name)")
            } else if let inferred = inferExerciseFromName(exercise) {
                foundInferred += 1
                print("🔍 INFERRED: \(exercise) -> \(inferred.muscleGroup.displayName)")
            } else {
                notFound += 1
                print("❌ NOT FOUND: \(exercise)")
            }
        }
        
        print("\n=== SUMMARY ===")
        print("Exact matches: \(foundExact)")
        print("Flexible matches: \(foundFlexible)")
        print("Inferred: \(foundInferred)")
        print("Not found: \(notFound)")
        print("Coverage: \(Int(Double(foundExact + foundFlexible + foundInferred) / Double(uniqueExercises.count) * 100))%")
    }
    #endif


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

                // Header bar
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            if let subtitle {
                                Text(subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

                if isExpanded {
                    content()
                        .padding()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
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
        // Use tracked muscle groups for consistency
        let average = total / Double(ExerciseLibrary.trackedMuscleGroups.count)
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

        return VStack(spacing: 16) {
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

        // Use only tracked muscle groups for consistency
        let average = total / Double(ExerciseLibrary.trackedMuscleGroups.count)

        return ExerciseLibrary.trackedMuscleGroups.filter { muscle in
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
        VStack(alignment: .leading, spacing: 12) {
            // Day labels (S M T W T F S)
            HStack(spacing: 4) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            let days = last28Days()
            let active = Set(workouts.map { calendar.startOfDay(for: $0.date) })
            let today = calendar.startOfDay(for: Date())
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { day in
                    let isActive = active.contains(day)
                    let isToday = calendar.isDate(day, inSameDayAs: today)
                    let dayOfMonth = calendar.component(.day, from: day)
                    let isFirstOfWeek = calendar.component(.weekday, from: day) == 1
                    
                    ZStack {
                        // Base square
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isActive ? .green : .gray.opacity(0.15))
                            .frame(height: 28)
                        
                        // Today indicator
                        if isToday {
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(.blue, lineWidth: 2)
                        }
                        
                        // Date number (only on Sundays)
                        if isFirstOfWeek {
                            Text("\(dayOfMonth)")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(isActive ? .white : .secondary)
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.green)
                        .frame(width: 12, height: 12)
                    Text("Workout")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.gray.opacity(0.15))
                        .frame(width: 12, height: 12)
                    Text("Rest")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(.blue, lineWidth: 1.5)
                        .frame(width: 12, height: 12)
                    Text("Today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats
            let workoutDays = active.filter { days.contains($0) }.count
            let percentage = (Double(workoutDays) / Double(days.count)) * 100
            
            HStack {
                Text("\(workoutDays)/28 days")
                    .font(.subheadline.weight(.medium))
                
                Spacer()
                
                Text("\(Int(percentage))% active")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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

    // MARK: - Muscle Heatmap

    private var muscleHeatmapCard: some View {
        VStack(spacing: 12) {
            Text("Tap muscle groups to highlight them in distribution chart")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let volumes = muscleVolumes(days: 30)
            let maxVal = volumes.values.max() ?? 1

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(MuscleGroup.modernGroups) { group in
                    let val = volumes[group] ?? 0
                    let intensity = max(0.15, val / maxVal)

                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(intensity))
                                .frame(height: 50)
                            
                            // Show percentage value
                            let total = volumes.values.reduce(0, +)
                            let percentage = total > 0 ? Int((val / total) * 100) : 0
                            Text("\(percentage)%")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.9))
                        }

                        Text(group.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        selectedMuscle = selectedMuscle == group ? nil : group
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
            if let ex = findExercise(named: set.exerciseName) {
                // Auto-migrate legacy exercises before calculating distribution
                let migratedEx = ExerciseLibrary.autoMigrate(ex)
                let base = set.weight * Double(set.reps)
                dict[migratedEx.muscleGroup, default: 0] += base
                if let secondary = migratedEx.secondaryMuscleGroup {
                    dict[secondary, default: 0] += base * secondaryWeight
                }
            } else {
                // FALLBACK: If exercise not found in library, try to infer muscle group from name
                if let inferredExercise = inferExerciseFromName(set.exerciseName) {
                    let base = set.weight * Double(set.reps)
                    dict[inferredExercise.muscleGroup, default: 0] += base
                    if let secondary = inferredExercise.secondaryMuscleGroup {
                        dict[secondary, default: 0] += base * secondaryWeight
                    }
                }
            }
        }
        return dict
    }

    // MARK: - Streak Card

    private var streakData: StreakData {
        calculateStreakData()
    }
    
    private var streakCard: some View {
        VStack(spacing: 16) {
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
                            .foregroundStyle(streakData.currentStreak > 0 ? .primary : .secondary)
                        
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
                        .foregroundStyle(.yellow)
                    
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
                        .foregroundStyle(.blue)
                    
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
                        .foregroundStyle(.green)
                    
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
                        .foregroundStyle(.secondary)
                    
                    Text("Last workout: \(formatLastWorkoutDate(lastWorkout))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
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
        VStack(spacing: 12) {
            // Filters
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

            // Radar chart
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
        .padding()
    }
    
    private var undertrainedAlertCard: some View {
        let undertrained = undertrainedMuscles()

        return Group {
            if !undertrained.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Muscles that need more attention based on recent training")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        let values = distributionValues()

                        ForEach(undertrained) { muscle in
                            let severity = severity(for: muscle, values: values)

                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(severity.color)

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
                .padding()
            }
        }
    }


    private func balanceScore() -> Int {
        let values = distributionValues()
        guard !values.isEmpty else { return 100 }

        let total = values.values.reduce(0, +)
        // Use only tracked muscle groups for balance calculation
        let avg = total / Double(ExerciseLibrary.trackedMuscleGroups.count)
        guard avg > 0 else { return 100 }

        let deviation = values.values.reduce(0) { sum, value in
            sum + abs(value - avg) / avg
        } / Double(ExerciseLibrary.trackedMuscleGroups.count)

        return max(0, Int(100 - deviation * 100))
    }

    private func mostUndertrainedMuscle() -> MuscleGroup? {
        let values = distributionValues()
        guard !values.isEmpty else { return nil }

        let total = values.values.reduce(0, +)
        // Use only tracked muscle groups
        let avg = total / Double(ExerciseLibrary.trackedMuscleGroups.count)

        // Only consider tracked muscle groups
        let trackedValues = values.filter { ExerciseLibrary.trackedMuscleGroups.contains($0.key) }
        
        return trackedValues
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
            if let ex = findExercise(named: set.exerciseName) {
                // Auto-migrate legacy exercises before calculating distribution
                let migratedEx = ExerciseLibrary.autoMigrate(ex)
                applyExerciseContribution(migratedEx, set: set, dict: &dict)
            } else {
                // FALLBACK: If exercise not found in library, try to infer muscle group from name
                if let inferredExercise = inferExerciseFromName(set.exerciseName) {
                    applyExerciseContribution(inferredExercise, set: set, dict: &dict)
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
            if let ex = findExercise(named: set.exerciseName) {
                // Auto-migrate legacy exercises before calculating distribution
                let migratedEx = ExerciseLibrary.autoMigrate(ex)
                applyExerciseContribution(migratedEx, set: set, dict: &dict)
            } else {
                // FALLBACK: If exercise not found in library, try to infer muscle group from name
                if let inferredExercise = inferExerciseFromName(set.exerciseName) {
                    applyExerciseContribution(inferredExercise, set: set, dict: &dict)
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
        
        // Add this to force refresh when data changes
        private var chartID: String {
            let valuesHash = values.map { "\($0.key.rawValue):\($0.value)" }.joined(separator: ",")
            let prevHash = previousValues.map { "\($0.key.rawValue):\($0.value)" }.joined(separator: ",")
            return "\(valuesHash)|\(prevHash)|\(maxValue)"
        }

        var body: some View {
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 - 20
                // Use the tracked muscle groups from ExerciseLibrary for consistency
                let muscles = ExerciseLibrary.trackedMuscleGroups

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
                        .foregroundStyle(
                            selectedMuscle == muscles[i] ? .blue : .secondary
                        )
                        .position(
                            x: center.x + cos(angle) * (radius + 32),
                            y: center.y + sin(angle) * (radius + 32)
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
            .id(chartID)
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
        .id("\(selectedRange.rawValue)-\(selectedMetric.rawValue)-\(selectedMuscle?.rawValue ?? "all")-\(sets.count)")
    }

    private func aggregateStats() -> (workouts: Int, sets: Int, volume: Double, duration: String) {

        let relevantSets = sets.filter { set in
            guard let cutoff = selectedRange.cutoff(calendar: calendar) else { return true }
            guard set.timestamp >= cutoff else { return false }

            guard let selectedMuscle else { return true }

            // Try to find exercise in library first
            if let exercise = findExercise(named: set.exerciseName) {
                // Auto-migrate before checking muscle group
                let migratedEx = ExerciseLibrary.autoMigrate(exercise)

                if migratedEx.muscleGroup == selectedMuscle { return true }
                if let secondary = migratedEx.secondaryMuscleGroup, secondary == selectedMuscle { return true }
                return false
            } else {
                // FALLBACK: Try to infer muscle group from name
                if let inferredEx = inferExerciseFromName(set.exerciseName) {
                    if inferredEx.muscleGroup == selectedMuscle { return true }
                    if let secondary = inferredEx.secondaryMuscleGroup, secondary == selectedMuscle { return true }
                }
                return false
            }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundStyle(.blue)
                Text("Training Insights")
                    .font(.subheadline.weight(.semibold))
            }
            
            Text(coachMessage())
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding()
    }


    // MARK: - Overview / Charts

    private var summaryCard: some View {
        let volume = sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }

        return VStack(spacing: 12) {
            HStack {
                statBox("Workouts", "\(workouts.count)")
                Spacer()
                statBox("Sets", "\(sets.count)")
                Spacer()
                statBox("Volume", "\(Int(volume))")
            }
        }
        .padding()
    }

    private var volumeOverTimeCard: some View {
        VStack(spacing: 8) {
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

        return VStack(spacing: 12) {
            Text("Ranked by total volume lifted")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
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
            .buttonStyle(.plain)

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

