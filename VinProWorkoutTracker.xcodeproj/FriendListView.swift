import SwiftUI

/// Main friends view with tabs
struct FriendListView: View {
    @State private var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.showUsernameSetup {
                    // Show username setup if profile not created
                    Color.clear
                        .sheet(isPresented: $viewModel.showUsernameSetup) {
                            UsernameSetupView(
                                friendManager: viewModel.friendManager,
                                onComplete: {
                                    Task {
                                        await viewModel.checkSetup()
                                    }
                                }
                            )
                        }
                } else {
                    // Main content
                    mainContent
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshAll()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Tab Picker
            Picker("View", selection: $viewModel.selectedTab) {
                ForEach(FriendsViewModel.FriendsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content based on tab
            TabView(selection: $viewModel.selectedTab) {
                followingTab
                    .tag(FriendsViewModel.FriendsTab.following)
                
                activityTab
                    .tag(FriendsViewModel.FriendsTab.activity)
                
                discoverTab
                    .tag(FriendsViewModel.FriendsTab.discover)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    // MARK: - Following Tab
    
    private var followingTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.friendManager.isLoading {
                    ProgressView("Loading friends...")
                        .padding()
                } else if viewModel.friendManager.friends.isEmpty {
                    emptyFollowingView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.friendManager.friends) { friend in
                            FriendRowView(
                                profile: friend,
                                isFollowing: true,
                                onToggleFollow: {
                                    Task {
                                        await viewModel.toggleFollow(friend)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var emptyFollowingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .padding(.top, 60)
            
            Text("No Friends Yet")
                .font(.title2.bold())
            
            Text("Search for friends in the Discover tab to start following them!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Activity Tab
    
    private var activityTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoadingActivity {
                    ProgressView("Loading activity...")
                        .padding()
                } else if viewModel.activityFeed.isEmpty {
                    emptyActivityView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.activityFeed) { workout in
                            WorkoutActivityCard(
                                workout: workout,
                                friendManager: viewModel.friendManager
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .refreshable {
            await viewModel.loadActivityFeed()
        }
    }
    
    private var emptyActivityView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .padding(.top, 60)
            
            Text("No Activity Yet")
                .font(.title2.bold())
            
            Text("When your friends share workouts, they'll appear here!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Discover Tab
    
    private var discoverTab: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search username...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        Task {
                            await viewModel.performSearch()
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
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
            
            // Search Results
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.isSearching {
                        ProgressView("Searching...")
                            .padding()
                    } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.fill.questionmark")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                                .padding(.top, 40)
                            
                            Text("No Users Found")
                                .font(.headline)
                            
                            Text("Try a different username")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else if !viewModel.searchResults.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { user in
                                FriendRowView(
                                    profile: user,
                                    isFollowing: false,
                                    onToggleFollow: {
                                        Task {
                                            await viewModel.toggleFollow(user)
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    } else {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                                .padding(.top, 40)
                            
                            Text("Search for Friends")
                                .font(.headline)
                            
                            Text("Enter a username to find friends")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Friend Row View

struct FriendRowView: View {
    let profile: UserProfile
    let isFollowing: Bool
    let onToggleFollow: () -> Void
    
    @State private var isProcessing = false
    @State private var currentlyFollowing: Bool
    
    init(profile: UserProfile, isFollowing: Bool, onToggleFollow: @escaping () -> Void) {
        self.profile = profile
        self.isFollowing = isFollowing
        self.onToggleFollow = onToggleFollow
        self._currentlyFollowing = State(initialValue: isFollowing)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(profile.displayName.prefix(1).uppercased())
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName)
                    .font(.headline)
                
                Text("@\(profile.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !profile.bio.isEmpty {
                    Text(profile.bio)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Follow Button
            Button {
                isProcessing = true
                currentlyFollowing.toggle()
                onToggleFollow()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isProcessing = false
                }
            } label: {
                Group {
                    if isProcessing {
                        ProgressView()
                            .tint(currentlyFollowing ? .secondary : .white)
                    } else {
                        Text(currentlyFollowing ? "Following" : "Follow")
                            .font(.subheadline.bold())
                    }
                }
                .frame(width: 90, height: 32)
                .background(currentlyFollowing ? Color.secondary.opacity(0.2) : Color.blue)
                .foregroundColor(currentlyFollowing ? .primary : .white)
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Workout Activity Card

struct WorkoutActivityCard: View {
    let workout: PublicWorkout
    let friendManager: CloudKitFriendManager
    
    @State private var userProfile: UserProfile?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(userProfile?.displayName.prefix(1).uppercased() ?? "?")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(userProfile?.displayName ?? "Loading...")
                        .font(.subheadline.bold())
                    
                    Text(workout.date.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Workout Details
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.workoutName)
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
                    Label("\(workout.exerciseCount) exercises", systemImage: "list.bullet")
                    Label("\(workout.duration) min", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if !workout.notes.isEmpty {
                    Text(workout.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .task {
            // Load user profile
            if let profile = try? await friendManager.fetchProfileByID(workout.userID) {
                userProfile = profile
            }
        }
    }
}

#Preview {
    FriendListView()
}
