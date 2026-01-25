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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink {
                            SocialPrivacySettingsView()
                        } label: {
                            Label("Privacy Settings", systemImage: "hand.raised")
                        }
                        
                        #if DEBUG
                        Divider()
                        
                        Button(role: .destructive) {
                            Task {
                                try? await socialService.deleteCurrentUserProfile()
                            }
                        } label: {
                            Label("Delete My Profile", systemImage: "trash")
                        }
                        
                        Button {
                            Task {
                                try? await socialService.cleanupOrphanedProfiles()
                            }
                        } label: {
                            Label("Cleanup Old Profiles", systemImage: "trash.slash")
                        }
                        
                        Button {
                            socialService.currentUserProfile = nil
                            UserDefaults.standard.removeObject(forKey: "cachedUserProfile")
                            UserDefaults.standard.removeObject(forKey: "cachedAppleUserID")
                        } label: {
                            Label("Clear Local Cache", systemImage: "arrow.counterclockwise")
                        }
                        #endif
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
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
            if !searchText.isEmpty {
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
                    Section("Following") {
                        if socialService.friends.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                
                                Text("Not following anyone yet")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Text("Find people to follow in the Discover tab")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
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
            await socialService.fetchFollowing()
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
                            VStack(spacing: 12) {
                                Text("No suggestions available")
                                    .foregroundStyle(.secondary)
                                
                                if let errorMessage = socialService.errorMessage {
                                    Text("Error: \(errorMessage)")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button("Retry") {
                                    Task {
                                        await socialService.fetchSuggestedUsers()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
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
                if isSearching {
                    HStack {
                        ProgressView()
                        Text("Searching...")
                            .foregroundStyle(.secondary)
                    }
                } else if searchResults.isEmpty {
                    VStack(spacing: 8) {
                        Text("No users found")
                            .foregroundStyle(.secondary)
                        
                        if let errorMessage = socialService.errorMessage {
                            Text("Error: \(errorMessage)")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
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
        } catch SocialError.profileNotFound {
            // Profile doesn't exist in CloudKit - clear cache
            print("⚠️ Profile not found in CloudKit, clearing local cache")
            socialService.currentUserProfile = nil
            UserDefaults.standard.removeObject(forKey: "cachedUserProfile")
            print("✅ Cache cleared, showing profile setup")
        } catch {
            // Other errors (network, auth, etc.)
            print("⚠️ Error loading profile: \(error)")
            // Don't clear cache for network errors - might just be offline
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
