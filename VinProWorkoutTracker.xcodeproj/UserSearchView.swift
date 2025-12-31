import SwiftUI

struct UserSearchView: View {
    let friendManager: CloudKitFriendManager
    
    @State private var searchQuery: String = ""
    @State private var searchResults: [UserProfile] = []
    @State private var isSearching = false
    @State private var followingStates: [String: Bool] = [:] // userID: isFollowing
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search users...", text: $searchQuery)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                            searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Results
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                    Spacer()
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("No users found")
                            .font(.headline)
                        
                        Text("Try a different search")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    Spacer()
                } else if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("Find Friends")
                            .font(.headline)
                        
                        Text("Search by username or name to connect with friends")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(searchResults) { user in
                            NavigationLink {
                                UserProfileView(userProfile: user, friendManager: friendManager)
                            } label: {
                                UserRowView(
                                    user: user,
                                    isFollowing: followingStates[user.id] ?? false,
                                    onFollowToggle: {
                                        toggleFollow(user: user)
                                    }
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search Users")
            .onAppear {
                loadFollowingStates()
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        Task {
            do {
                let results = try await friendManager.searchUsers(query: searchQuery)
                
                // Filter out current user
                let filtered = results.filter { $0.id != friendManager.currentUserProfile?.id }
                
                await MainActor.run {
                    searchResults = filtered
                    isSearching = false
                }
                
                // Load following states for results
                await loadFollowingStatesForResults(filtered)
            } catch {
                await MainActor.run {
                    isSearching = false
                    print("Search error: \(error)")
                }
            }
        }
    }
    
    private func loadFollowingStates() {
        Task {
            for user in searchResults {
                let isFollowing = await friendManager.isFollowing(user)
                await MainActor.run {
                    followingStates[user.id] = isFollowing
                }
            }
        }
    }
    
    private func loadFollowingStatesForResults(_ users: [UserProfile]) async {
        for user in users {
            let isFollowing = await friendManager.isFollowing(user)
            await MainActor.run {
                followingStates[user.id] = isFollowing
            }
        }
    }
    
    private func toggleFollow(user: UserProfile) {
        Task {
            do {
                let currentlyFollowing = followingStates[user.id] ?? false
                
                if currentlyFollowing {
                    try await friendManager.unfollowUser(user)
                } else {
                    try await friendManager.followUser(user)
                }
                
                await MainActor.run {
                    followingStates[user.id] = !currentlyFollowing
                }
            } catch {
                print("Follow toggle error: \(error)")
            }
        }
    }
}

// MARK: - User Row

struct UserRowView: View {
    let user: UserProfile
    let isFollowing: Bool
    let onFollowToggle: () -> Void
    
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
            }
            
            Spacer()
            
            Button {
                onFollowToggle()
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isFollowing ? .primary : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isFollowing ? Color.secondary.opacity(0.2) : Color.blue)
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    UserSearchView(friendManager: CloudKitFriendManager())
}
