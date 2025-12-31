import SwiftUI

/// View model for friends feature
/// Manages state and coordinates with CloudKitFriendManager

@Observable
class FriendsViewModel {
    
    // MARK: - Dependencies
    
    let friendManager: CloudKitFriendManager
    
    // MARK: - State
    
    var searchText = ""
    var searchResults: [UserProfile] = []
    var isSearching = false
    var selectedTab: FriendsTab = .following
    var showUsernameSetup = false
    var activityFeed: [PublicWorkout] = []
    var isLoadingActivity = false
    
    enum FriendsTab: String, CaseIterable {
        case following = "Following"
        case activity = "Activity"
        case discover = "Discover"
    }
    
    // MARK: - Initialization
    
    init(friendManager: CloudKitFriendManager = CloudKitFriendManager()) {
        self.friendManager = friendManager
        
        Task {
            await checkSetup()
        }
    }
    
    // MARK: - Setup
    
    func checkSetup() async {
        await friendManager.checkCurrentUser()
        
        await MainActor.run {
            if friendManager.currentUserProfile == nil {
                showUsernameSetup = true
            } else {
                // Load friends
                Task {
                    await friendManager.loadFriends()
                    await loadActivityFeed()
                }
            }
        }
    }
    
    // MARK: - Search
    
    func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            let results = try await friendManager.searchUsers(username: searchText)
            
            await MainActor.run {
                self.searchResults = results
                self.isSearching = false
            }
        } catch {
            await MainActor.run {
                self.isSearching = false
                self.friendManager.errorMessage = "Search failed: \(error.localizedDescription)"
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
    }
    
    // MARK: - Follow/Unfollow
    
    func toggleFollow(_ user: UserProfile) async {
        let isFollowing = await friendManager.isFollowing(user)
        
        do {
            if isFollowing {
                try await friendManager.unfollowUser(user)
            } else {
                try await friendManager.followUser(user)
            }
        } catch {
            await MainActor.run {
                friendManager.errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Activity Feed
    
    func loadActivityFeed() async {
        isLoadingActivity = true
        
        do {
            let workouts = try await friendManager.loadFriendsActivity(limit: 50)
            
            await MainActor.run {
                self.activityFeed = workouts
                self.isLoadingActivity = false
            }
        } catch {
            await MainActor.run {
                self.isLoadingActivity = false
                self.friendManager.errorMessage = "Failed to load activity: \(error.localizedDescription)"
            }
        }
    }
    
    func refreshAll() async {
        await friendManager.loadFriends()
        await loadActivityFeed()
    }
}
