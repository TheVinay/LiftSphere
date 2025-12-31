import SwiftUI

struct UserProfileView: View {
    let userProfile: UserProfile
    let friendManager: CloudKitFriendManager
    
    @State private var isFollowing = false
    @State private var recentWorkouts: [PublicWorkout] = []
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text(userProfile.displayName.prefix(1).uppercased())
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text(userProfile.displayName)
                            .font(.title2.bold())
                        
                        Text("@\(userProfile.username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !userProfile.bio.isEmpty {
                        Text(userProfile.bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Stats
                    HStack(spacing: 40) {
                        statView(value: "\(userProfile.totalWorkouts)", label: "Workouts")
                        statView(value: formatVolume(userProfile.totalVolume), label: "Volume")
                    }
                    .padding(.top, 8)
                    
                    // Follow Button
                    Button {
                        toggleFollow()
                    } label: {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.headline)
                            .foregroundColor(isFollowing ? .primary : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFollowing ? Color.secondary.opacity(0.2) : Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 20)
                
                // Recent Workouts
                if isLoading {
                    ProgressView("Loading workouts...")
                        .padding()
                } else if !recentWorkouts.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Workouts")
                            .font(.title3.bold())
                            .padding(.horizontal, 20)
                        
                        ForEach(recentWorkouts) { workout in
                            WorkoutCardView(workout: workout)
                                .padding(.horizontal, 20)
                        }
                    }
                } else {
                    Text("No public workouts yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkFollowingStatus()
            loadRecentWorkouts()
        }
    }
    
    private func statView(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000000 {
            return String(format: "%.1fM", volume / 1000000)
        } else if volume >= 1000 {
            return String(format: "%.1fK", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
    
    private func checkFollowingStatus() {
        Task {
            let following = await friendManager.isFollowing(userProfile)
            await MainActor.run {
                isFollowing = following
            }
        }
    }
    
    private func toggleFollow() {
        Task {
            do {
                if isFollowing {
                    try await friendManager.unfollowUser(userProfile)
                } else {
                    try await friendManager.followUser(userProfile)
                }
                
                await MainActor.run {
                    isFollowing.toggle()
                }
            } catch {
                print("Follow error: \(error)")
            }
        }
    }
    
    private func loadRecentWorkouts() {
        isLoading = true
        
        Task {
            do {
                let workouts = try await friendManager.fetchUserWorkouts(userID: userProfile.id, limit: 10)
                
                await MainActor.run {
                    recentWorkouts = workouts
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Error loading workouts: \(error)")
                }
            }
        }
    }
}

// MARK: - Workout Card

struct WorkoutCardView: View {
    let workout: PublicWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.workoutName)
                        .font(.headline)
                    
                    Text(workout.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            HStack(spacing: 20) {
                statItem(icon: "dumbbell.fill", value: "\(workout.exerciseCount)", label: "Exercises")
                statItem(icon: "chart.bar.fill", value: formatVolume(workout.totalVolume), label: "Volume")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline.bold())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000000 {
            return String(format: "%.1fM", volume / 1000000)
        } else if volume >= 1000 {
            return String(format: "%.1fK", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            userProfile: UserProfile(username: "johndoe", displayName: "John Doe", bio: "Fitness enthusiast", totalWorkouts: 150, totalVolume: 250000),
            friendManager: CloudKitFriendManager()
        )
    }
}
