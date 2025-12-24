import SwiftUI
import SwiftData
import UIKit
import Charts

struct ProfileView: View {
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]

    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

    // Single source of truth for name + profile fields
    @AppStorage("displayName") private var storedDisplayName: String = ""
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("profile.bio") private var bio: String = ""
    @AppStorage("profile.link") private var link: String = ""
    @AppStorage("profile.followers") private var followers: Int = 0
    @AppStorage("profile.following") private var following: Int = 0

    @State private var showEditProfile = false
    @State private var showSettings = false
    
    // Collapsible sections
    @State private var isVolumeCardExpanded = true
    @State private var isTopExercisesExpanded = true
    @State private var isStreakCardExpanded = true
    @State private var isWeeklySummaryExpanded = true

    // MARK: - Name / avatar helpers

    private var displayName: String {
        // 1. Use stored display name if set
        if !storedDisplayName.isEmpty {
            return storedDisplayName
        }

        // 2. Fallback: derive from device name (strip "’s iPhone")
        let device = UIDevice.current.name
        if let range = device.range(of: "'s ") {
            return String(device[..<range.lowerBound])
        }
        return device
    }

    private var avatarInitial: String {
        displayName
            .trimmingCharacters(in: .whitespaces)
            .first
            .map { String($0).uppercased() } ?? "V"
    }

    // MARK: - Analytics helpers (for profile cards)

    // last 30 days for the little profile trend
    private var last30DaysCutoff: Date {
        Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? .distantPast
    }

    private var recentSets: [SetEntry] {
        allSets.filter { $0.timestamp >= last30DaysCutoff }
    }

    private var recentVolumePoints: [ChartPoint] {
        let grouped = Dictionary(grouping: recentSets) { set in
            Calendar.current.startOfDay(for: set.timestamp)
        }

        return grouped.map { (day, sets) in
            ChartPoint(
                date: day,
                value: sets.reduce(0) { $0 + $1.weight * Double($1.reps) }
            )
        }
        .sorted { $0.date < $1.date }
    }

    private struct ExerciseVolume: Identifiable {
        let id = UUID()
        let name: String
        let volume: Double
    }

    // all-time top exercises (kept simple for profile)
    private var topExercisesAllTime: [ExerciseVolume] {
        let grouped = Dictionary(grouping: allSets, by: { $0.exerciseName })
        let vols = grouped.map { (name, sets) in
            ExerciseVolume(
                name: name,
                volume: sets.reduce(0) { $0 + $1.weight * Double($1.reps) }
            )
        }
        return vols.sorted { $0.volume > $1.volume }.prefix(3).map { $0 }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // HEADER
                    HStack(alignment: .center, spacing: 20) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 72, height: 72)

                            Text(avatarInitial)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            // Name
                            Text(displayName.lowercased())
                                .font(.title2.weight(.semibold))

                            // Stats row
                            HStack(spacing: 24) {
                                statBlock(title: "Workouts", value: "\(workouts.count)")
                                statBlock(title: "Followers", value: "\(followers)")
                                statBlock(title: "Following", value: "\(following)")
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Optional bio / link
                    if !bio.isEmpty || !link.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            if !bio.isEmpty {
                                Text(bio)
                            }
                            if let url = URL(string: link), !link.isEmpty {
                                Link(link, destination: url)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // PROFILE ANALYTICS CARDS
                    VStack(spacing: 16) {
                        // Volume Card - Collapsible
                        collapsibleCard(
                            title: "Last 30 Days Volume",
                            isExpanded: $isVolumeCardExpanded
                        ) {
                            volumeCardContent
                        }
                        
                        // Weekly Summary Card - Collapsible
                        collapsibleCard(
                            title: "Weekly Summary",
                            isExpanded: $isWeeklySummaryExpanded
                        ) {
                            weeklySummaryCardContent
                        }
                        
                        // Top Exercises Card - Collapsible
                        collapsibleCard(
                            title: "Top Exercises (All Time)",
                            isExpanded: $isTopExercisesExpanded
                        ) {
                            topExercisesCardContent
                        }
                        
                        // Streak Card - Collapsible (moved to bottom)
                        collapsibleCard(
                            title: "Workout Streak",
                            isExpanded: $isStreakCardExpanded
                        ) {
                            streakCardContent
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                // Settings gear
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }

                // Pencil for Edit Profile
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                // No more bindings – EditProfileView reads @AppStorage directly
                EditProfileView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Analytics cards
    
    // Helper for collapsible card
    private func collapsibleCard<Content: View>(
        title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)
            
            if isExpanded.wrappedValue {
                content()
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // Streak Card Content
    private var streakCardContent: some View {
        let streakData = calculateStreakData()
        
        return VStack(spacing: 16) {
            // Current Streak
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        streakData.currentStreak > 0
                        ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(streakData.currentStreak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(streakData.currentStreak > 0 ? .primary : .secondary)
                    
                    Text(streakData.currentStreak == 1 ? "Day Streak" : "Days Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats Grid
            HStack(spacing: 12) {
                miniStatCard(icon: "trophy.fill", color: .yellow, value: "\(streakData.longestStreak)", label: "Best")
                miniStatCard(icon: "calendar", color: .blue, value: "\(streakData.workoutsThisMonth)", label: "This Month")
                miniStatCard(icon: "figure.run", color: .green, value: "\(streakData.workoutsThisWeek)", label: "This Week")
            }
        }
        .padding(.top, 4)
    }
    
    // Weekly Summary Content
    private var weeklySummaryCardContent: some View {
        let thisWeekWorkouts = workouts.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }
        
        let lastWeekWorkouts = workouts.filter {
            guard let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) else {
                return false
            }
            return Calendar.current.isDate($0.date, equalTo: lastWeekDate, toGranularity: .weekOfYear)
        }
        
        let thisWeekVolume = thisWeekWorkouts.reduce(0) { $0 + $1.totalVolume }
        let lastWeekVolume = lastWeekWorkouts.reduce(0) { $0 + $1.totalVolume }
        
        let volumeChange = lastWeekVolume > 0 ? ((thisWeekVolume - lastWeekVolume) / lastWeekVolume) * 100 : 0
        
        return VStack(spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(thisWeekWorkouts.count)")
                        .font(.title.bold())
                    Text("workouts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(thisWeekVolume))")
                        .font(.title.bold())
                    HStack(spacing: 4) {
                        Image(systemName: volumeChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.caption2)
                        Text(String(format: "%.0f%%", abs(volumeChange)))
                            .font(.caption)
                    }
                    .foregroundStyle(volumeChange >= 0 ? .green : .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 4)
        }
    }

    private var volumeCardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if recentVolumePoints.isEmpty {
                Text("No sets logged in the last 30 days.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                Chart(recentVolumePoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Volume", point.value)
                    )
                    .foregroundStyle(Color.blue)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Volume", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 160)
                .padding(.top, 4)
            }
        }
    }

    private var topExercisesCardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if topExercisesAllTime.isEmpty {
                Text("No sets logged yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                Chart(topExercisesAllTime) { ex in
                    BarMark(
                        x: .value("Volume", ex.volume),
                        y: .value("Exercise", ex.name)
                    )
                    .foregroundStyle(Color.green)
                }
                .frame(height: CGFloat(topExercisesAllTime.count) * 30 + 20)
                .padding(.top, 4)

                Divider()
                    .padding(.vertical, 4)

                ForEach(topExercisesAllTime) { ex in
                    HStack {
                        Text(ex.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(ex.volume))")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
    
    // Old card views (kept for reference, can be removed)
    private var volumeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 30 days volume")
                .font(.headline)

            if recentVolumePoints.isEmpty {
                Text("No sets logged in the last 30 days.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(recentVolumePoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Volume", point.value)
                    )
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Volume", point.value)
                    )
                    .opacity(0.15)
                }
                .frame(height: 160)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private var topExercisesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top exercises (all time)")
                .font(.headline)

            if topExercisesAllTime.isEmpty {
                Text("No sets logged yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Chart(topExercisesAllTime) { ex in
                    BarMark(
                        x: .value("Volume", ex.volume),
                        y: .value("Exercise", ex.name)
                    )
                }
                .frame(height: CGFloat(topExercisesAllTime.count) * 26 + 20)

                ForEach(topExercisesAllTime) { ex in
                    HStack {
                        Text(ex.name)
                            .font(.subheadline)
                        Spacer()
                        Text(String(Int(ex.volume)))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // MARK: - Helpers

    private struct ChartPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
    
    private struct StreakData {
        var currentStreak: Int
        var longestStreak: Int
        var workoutsThisWeek: Int
        var workoutsThisMonth: Int
    }
    
    private func calculateStreakData() -> StreakData {
        guard !workouts.isEmpty else {
            return StreakData(currentStreak: 0, longestStreak: 0, workoutsThisWeek: 0, workoutsThisMonth: 0)
        }
        
        let calendar = Calendar.current
        let workoutDates = workouts
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        let uniqueDates = Array(Set(workoutDates)).sorted(by: >)
        
        // Calculate current streak
        var currentStreak = 0
        let today = calendar.startOfDay(for: Date())
        
        if let mostRecent = uniqueDates.first {
            let daysSinceLastWorkout = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
            
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
            workoutsThisMonth: workoutsThisMonth
        )
    }
    
    private func miniStatCard(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3.bold())
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(10)
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(value)
                .font(.headline)
        }
        .frame(minWidth: 70, alignment: .leading)
    }
}
