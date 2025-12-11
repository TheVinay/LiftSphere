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
                        volumeCard
                        topExercisesCard
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
