import SwiftUI

struct FriendsView: View {
    @State private var socialService = SocialService()
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var searchResults: [UserProfile] = []
    @State private var showingProfileSetup = false
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            Group {
                if socialService.currentUserProfile == nil {
                    profileSetupPrompt
                } else {
                    mainContent
                }
            }
            .navigationTitle("Friends")
            .sheet(isPresented: $showingProfileSetup) {
                ProfileSetupView(socialService: socialService)
            }
            .task {
                await loadInitialData()
            }
        }
    }
    
    private var profileSetupPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Connect with Friends")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a profile to share workouts and follow other athletes")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button("Create Profile") {
                showingProfileSetup = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $selectedTab) {
                Text("Friends").tag(0)
                Text("Feed").tag(1)
                Text("Discover").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                friendsListView
            } else if selectedTab == 1 {
                feedView
            } else {
                discoverView
            }
        }
        .searchable(text: $searchText, prompt: "Search users")
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                Task {
                    await performSearch(query: newValue)
                }
            } else {
                searchResults = []
            }
        }
        .overlay {
            if !searchText.isEmpty && !searchResults.isEmpty {
                searchResultsView
            }
        }
    }
    
    private var friendsListView: some View {
        Group {
            if socialService.isLoading {
                ProgressView()
            } else {
                List {
                    if !socialService.friendRequests.isEmpty {
                        Section("Friend Requests") {
                            ForEach(socialService.friendRequests) { request in
                                FriendRequestRow(
                                    request: request,
                                    socialService: socialService
                                )
                            }
                        }
                    }
                    
                    Section("Your Friends") {
                        if socialService.friends.isEmpty {
                            Text("No friends yet")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(socialService.friends) { friend in
                                NavigationLink {
                                    UserProfileView(
                                        user: friend,
                                        socialService: socialService
                                    )
                                } label: {
                                    FriendRowView(user: friend)
                                }
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await socialService.fetchFriends()
            await socialService.fetchFriendRequests()
        }
    }
    
    private var feedView: some View {
        Group {
            if socialService.isLoading {
                ProgressView()
            } else {
                List {
                    if socialService.friendWorkouts.isEmpty {
                        ContentUnavailableView(
                            "No Workouts Yet",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Follow friends to see their workouts here")
                        )
                    } else {
                        ForEach(socialService.friendWorkouts) { workout in
                            WorkoutFeedRow(
                                workout: workout,
                                user: socialService.friends.first(where: { $0.id == workout.userID })
                            )
                        }
                    }
                }
            }
        }
        .refreshable {
            await socialService.fetchFriendWorkouts()
        }
    }
    
    private var discoverView: some View {
        Group {
            if socialService.isLoading {
                ProgressView()
            } else {
                List {
                    Section("Suggested Users") {
                        if socialService.suggestedUsers.isEmpty {
                            Text("No suggestions available")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(socialService.suggestedUsers) { user in
                                NavigationLink {
                                    UserProfileView(
                                        user: user,
                                        socialService: socialService
                                    )
                                } label: {
                                    DiscoverUserRow(
                                        user: user,
                                        socialService: socialService
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await socialService.fetchSuggestedUsers()
        }
    }
    
    private var searchResultsView: some View {
        List {
            Section("Search Results") {
                ForEach(searchResults) { user in
                    NavigationLink {
                        UserProfileView(
                            user: user,
                            socialService: socialService
                        )
                    } label: {
                        FriendRowView(user: user)
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private func loadInitialData() async {
        do {
            try await socialService.fetchCurrentUserProfile()
            
            if socialService.currentUserProfile != nil {
                await socialService.fetchFriends()
                await socialService.fetchFriendRequests()
                await socialService.fetchSuggestedUsers()
                await socialService.fetchFriendWorkouts()
            }
        } catch {
            // User doesn't have a profile yet
            print("No profile found: \(error)")
        }
    }
    
    private func performSearch(query: String) async {
        isSearching = true
        defer { isSearching = false }
        
        do {
            searchResults = try await socialService.searchUsers(query: query)
        } catch {
            print("Search error: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct FriendRowView: View {
    let user: UserProfile
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Text(user.displayName.prefix(1).uppercased())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if user.totalWorkouts > 0 {
                    Text("\(user.totalWorkouts) workouts • \(Int(user.totalVolume)) lbs total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct FriendRequestRow: View {
    let request: FriendRelationship
    let socialService: SocialService
    @State private var isProcessing = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Friend Request")
                    .font(.headline)
                Text("User ID: \(request.followerID.prefix(8))...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Accept") {
                Task {
                    isProcessing = true
                    try? await socialService.acceptFriendRequest(relationshipID: request.id)
                    isProcessing = false
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing)
        }
    }
}

struct DiscoverUserRow: View {
    let user: UserProfile
    let socialService: SocialService
    @State private var isFollowing = false
    @State private var isProcessing = false
    
    var body: some View {
        HStack {
            FriendRowView(user: user)
            
            if !isFollowing {
                Button {
                    Task {
                        isProcessing = true
                        try? await socialService.sendFriendRequest(to: user.id)
                        isFollowing = true
                        isProcessing = false
                    }
                } label: {
                    Label("Follow", systemImage: "person.badge.plus")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(isProcessing)
            } else {
                Label("Requested", systemImage: "checkmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct WorkoutFeedRow: View {
    let workout: PublicWorkout
    let user: UserProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 40, height: 40)
                    .overlay {
                        if let user = user {
                            Text(user.displayName.prefix(1).uppercased())
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                
                VStack(alignment: .leading) {
                    Text(user?.displayName ?? "Unknown User")
                        .font(.headline)
                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if workout.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.workoutName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack {
                    Label("\(workout.exerciseCount) exercises", systemImage: "list.bullet")
                    Text("•")
                    Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FriendsView()
}
