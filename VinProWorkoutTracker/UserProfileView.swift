import SwiftUI

struct UserProfileView: View {
    let user: UserProfile
    let socialService: SocialService
    
    @State private var isFriend = false
    @State private var isProcessing = false
    @State private var userWorkouts: [PublicWorkout] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.gradient)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(user.displayName.prefix(1).uppercased())
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    
                    Text(user.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // Action Button
                    if user.id != socialService.currentUserProfile?.id {
                        actionButton
                    }
                }
                .padding()
                
                // Stats
                HStack(spacing: 40) {
                    StatView(
                        value: "\(user.totalWorkouts)",
                        label: "Workouts"
                    )
                    
                    StatView(
                        value: "\(Int(user.totalVolume))",
                        label: "Total lbs"
                    )
                    
                    StatView(
                        value: "\(socialService.friends.count)",
                        label: "Friends"
                    )
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                }
                .padding(.horizontal)
                
                // Recent Workouts
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Workouts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if userWorkouts.isEmpty {
                        Text("No workouts shared yet")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(userWorkouts) { workout in
                            WorkoutCard(workout: workout)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadUserWorkouts()
            checkFriendshipStatus()
        }
    }
    
    private var actionButton: some View {
        Group {
            if isFriend {
                Button(role: .destructive) {
                    Task {
                        await removeFriend()
                    }
                } label: {
                    Label("Remove Friend", systemImage: "person.badge.minus")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)
            } else {
                Button {
                    Task {
                        await sendFriendRequest()
                    }
                } label: {
                    Label("Add Friend", systemImage: "person.badge.plus")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
        }
    }
    
    private func checkFriendshipStatus() {
        isFriend = socialService.friends.contains(where: { $0.id == user.id })
    }
    
    private func sendFriendRequest() async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            try await socialService.sendFriendRequest(to: user.id)
            isFriend = true
        } catch {
            print("Error sending friend request: \(error)")
        }
    }
    
    private func removeFriend() async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            try await socialService.removeFriend(userID: user.id)
            isFriend = false
        } catch {
            print("Error removing friend: \(error)")
        }
    }
    
    private func loadUserWorkouts() async {
        // In a real implementation, you would fetch workouts for this specific user
        userWorkouts = socialService.friendWorkouts.filter { $0.userID == user.id }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct WorkoutCard: View {
    let workout: PublicWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.workoutName)
                    .font(.headline)
                
                Spacer()
                
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Label("\(workout.exerciseCount) exercises", systemImage: "list.bullet")
                
                Spacer()
                
                Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileView(
            user: UserProfile(
                username: "johndoe",
                displayName: "John Doe",
                bio: "Fitness enthusiast and weightlifting lover",
                totalWorkouts: 42,
                totalVolume: 125000
            ),
            socialService: SocialService()
        )
    }
}
