import SwiftUI

struct FriendsActivityFeedView: View {
    let friendManager: CloudKitFriendManager
    
    @State private var activities: [(UserProfile, PublicWorkout)] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading activity...")
                        .padding()
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if activities.isEmpty {
                    emptyStateView
                } else {
                    activityList
                }
            }
            .navigationTitle("Activity")
            .refreshable {
                await loadActivities()
            }
            .onAppear {
                Task {
                    await loadActivities()
                }
            }
        }
    }
    
    // MARK: - Activity List
    
    private var activityList: some View {
        List {
            ForEach(activities, id: \.1.id) { (user, workout) in
                ActivityRowView(user: user, workout: workout, friendManager: friendManager)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("No Activity Yet")
                .font(.title2.bold())
            
            Text("Follow friends to see their workout activity here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            NavigationLink {
                UserSearchView(friendManager: friendManager)
            } label: {
                Text("Find Friends")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
            }
        }
        .padding()
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            
            Text("Error Loading Activity")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                Task {
                    await loadActivities()
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
    }
    
    // MARK: - Load Activities
    
    private func loadActivities() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await friendManager.fetchFriendsWorkouts(limit: 50)
            
            await MainActor.run {
                activities = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

// MARK: - Activity Row

struct ActivityRowView: View {
    let user: UserProfile
    let workout: PublicWorkout
    let friendManager: CloudKitFriendManager
    
    var body: some View {
        NavigationLink {
            UserProfileView(userProfile: user, friendManager: friendManager)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // User Info
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Text(user.displayName.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName)
                            .font(.subheadline.weight(.semibold))
                        
                        Text(relativeDate(workout.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if workout.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                // Workout Details
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.workoutName)
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        Label("\(workout.exerciseCount) exercises", systemImage: "dumbbell.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Label(formatVolume(workout.totalVolume), systemImage: "chart.bar.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000000 {
            return String(format: "%.1fM lbs", volume / 1000000)
        } else if volume >= 1000 {
            return String(format: "%.1fK lbs", volume / 1000)
        } else {
            return String(format: "%.0f lbs", volume)
        }
    }
}

#Preview {
    FriendsActivityFeedView(friendManager: CloudKitFriendManager())
}
