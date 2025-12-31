import SwiftUI

struct FriendListView: View {
    let friendManager: CloudKitFriendManager
    
    @State private var following: [UserProfile] = []
    @State private var followers: [UserProfile] = []
    @State private var isLoading = false
    @State private var selectedTab: Tab = .following
    
    enum Tab: String, CaseIterable {
        case following = "Following"
        case followers = "Followers"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                } else {
                    Group {
                        switch selectedTab {
                        case .following:
                            followingList
                        case .followers:
                            followersList
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        UserSearchView(friendManager: friendManager)
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .onAppear {
                loadFriends()
            }
            .refreshable {
                loadFriends()
            }
        }
    }
    
    // MARK: - Following List
    
    private var followingList: some View {
        Group {
            if following.isEmpty {
                emptyState(
                    icon: "person.2",
                    title: "No Following Yet",
                    message: "Find friends to follow and see their workouts"
                )
            } else {
                List {
                    ForEach(following) { user in
                        NavigationLink {
                            UserProfileView(userProfile: user, friendManager: friendManager)
                        } label: {
                            FriendRowView(user: user)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - Followers List
    
    private var followersList: some View {
        Group {
            if followers.isEmpty {
                emptyState(
                    icon: "person.2",
                    title: "No Followers Yet",
                    message: "Share your profile to gain followers"
                )
            } else {
                List {
                    ForEach(followers) { user in
                        NavigationLink {
                            UserProfileView(userProfile: user, friendManager: friendManager)
                        } label: {
                            FriendRowView(user: user)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - Empty State
    
    private func emptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title2.bold())
            
            Text(message)
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
            
            Spacer()
        }
    }
    
    // MARK: - Load Data
    
    private func loadFriends() {
        isLoading = true
        
        Task {
            do {
                async let followingTask = friendManager.fetchFollowing()
                async let followersTask = friendManager.fetchFollowers()
                
                let (followingList, followersList) = try await (followingTask, followersTask)
                
                await MainActor.run {
                    following = followingList
                    followers = followersList
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Error loading friends: \(error)")
                }
            }
        }
    }
}

// MARK: - Friend Row

struct FriendRowView: View {
    let user: UserProfile
    
    var body: some View {
        HStack(spacing: 12) {
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
                    .frame(width: 50, height: 50)
                
                Text(user.displayName.prefix(1).uppercased())
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if user.totalWorkouts > 0 {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(user.totalWorkouts) workouts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FriendListView(friendManager: CloudKitFriendManager())
}
