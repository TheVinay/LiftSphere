import Foundation
import CloudKit
import SwiftData

@Observable
class SocialService {
    var currentUserProfile: UserProfile?
    var friends: [UserProfile] = []
    var friendRequests: [FriendRelationship] = []
    var suggestedUsers: [UserProfile] = []
    var friendWorkouts: [PublicWorkout] = []
    var isLoading = false
    var errorMessage: String?
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private var cachedAppleUserID: String?
    
    // Privacy settings
    var privacySettings: SocialPrivacySettings = .load()
    
    // Local cache keys
    private let profileCacheKey = "cachedUserProfile"
    private let appleUserIDCacheKey = "cachedAppleUserID"
    
    init() {
        // Explicitly use the container that matches Xcode configuration
        self.container = CKContainer(identifier: "iCloud.com.vinay.VinProWorkoutTracker")
        self.publicDatabase = container.publicCloudDatabase
        
        // Load cached Apple User ID
        self.cachedAppleUserID = UserDefaults.standard.string(forKey: appleUserIDCacheKey)
        
        // Load cached profile
        loadCachedProfile()
        
        // Debug logging
        print("🔍 SocialService initialized")
        print("🔍 Container identifier: \(container.containerIdentifier ?? "nil")")
        print("🔍 Cached Apple User ID: \(cachedAppleUserID ?? "none")")
    }
    
    // MARK: - Local Caching
    
    private func loadCachedProfile() {
        if let data = UserDefaults.standard.data(forKey: profileCacheKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUserProfile = profile
            print("✅ Loaded cached profile: \(profile.displayName)")
        }
    }
    
    private func cacheProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: profileCacheKey)
            print("✅ Cached profile locally")
        }
    }
    
    private func clearCachedProfile() {
        UserDefaults.standard.removeObject(forKey: profileCacheKey)
        UserDefaults.standard.removeObject(forKey: appleUserIDCacheKey)
        self.cachedAppleUserID = nil
        print("🗑️ Cleared cached profile")
    }
    
    // MARK: - Apple User ID Management
    
    private func getAppleUserID() async throws -> String {
        // Return cached ID if available
        if let cached = cachedAppleUserID {
            return cached
        }
        
        #if targetEnvironment(simulator)
        // Debug: Use a fake but consistent Apple User ID in simulator
        let simulatorUserID = "simulator-user-\(UUID().uuidString.prefix(8))"
        self.cachedAppleUserID = simulatorUserID
        UserDefaults.standard.set(simulatorUserID, forKey: appleUserIDCacheKey)
        print("⚠️ DEBUG: Using simulator Apple User ID: \(simulatorUserID)")
        return simulatorUserID
        #else
        // Fetch from CloudKit
        let userID = try await container.userRecordID()
        let appleUserID = userID.recordName
        
        // Cache it
        self.cachedAppleUserID = appleUserID
        UserDefaults.standard.set(appleUserID, forKey: appleUserIDCacheKey)
        
        print("✅ Got Apple User ID: \(appleUserID)")
        return appleUserID
        #endif
    }
    
    // MARK: - User Profile Management
    
    func checkAuthentication() async throws -> Bool {
        #if targetEnvironment(simulator)
        // Debug: Allow simulator to bypass CloudKit auth check
        print("⚠️ DEBUG: Simulator detected - CloudKit auth check bypassed")
        print("⚠️ Note: CloudKit features may not work properly in simulator")
        return true
        #else
        let status = try await container.accountStatus()
        return status == .available
        #endif
    }
    
    func createUserProfile(username: String, displayName: String, bio: String = "") async throws {
        print("🔍 Starting createUserProfile...")
        
        // Check authentication first
        guard try await checkAuthentication() else {
            print("❌ Not authenticated")
            throw SocialError.notAuthenticated
        }
        
        print("✅ Authentication OK")
        
        do {
            // Get Apple User ID
            let appleUserID = try await getAppleUserID()
            print("✅ Got Apple User ID: \(appleUserID)")
            
            // Normalize username (lowercase, trim whitespace)
            let normalizedUsername = username.lowercased().trimmingCharacters(in: .whitespaces)
            print("🔍 Checking username availability: '\(normalizedUsername)'")
            
            // Check if username is already taken
            let usernameCheck = NSPredicate(format: "username == %@", normalizedUsername)
            let usernameQuery = CKQuery(recordType: "UserProfile", predicate: usernameCheck)
            
            #if DEBUG
            print("🔍 Executing username uniqueness check...")
            #endif
            
            let existingResults = try await publicDatabase.records(matching: usernameQuery, desiredKeys: ["username"], resultsLimit: 1)
            
            #if DEBUG
            print("🔍 Found \(existingResults.matchResults.count) existing profiles with this username")
            #endif
            
            if !existingResults.matchResults.isEmpty {
                print("❌ Username already taken: \(normalizedUsername)")
                throw SocialError.usernameAlreadyTaken
            }
            
            print("✅ Username is available")
            
            // Create profile with Apple User ID link
            let profile = UserProfile(
                appleUserID: appleUserID,
                username: normalizedUsername,
                displayName: displayName,
                bio: bio
            )
            
            print("🔍 Creating CloudKit record...")
            let record = profile.toCKRecord()
            
            print("🔍 Saving to CloudKit...")
            try await publicDatabase.save(record)
            
            print("✅ Profile saved successfully!")
            self.currentUserProfile = profile
            
            // Cache profile locally
            cacheProfile(profile)
            
        } catch let error as CKError {
            // Provide better error messages for CloudKit issues
            print("❌ CloudKit Error: \(error.localizedDescription)")
            print("❌ Error Code: \(error.code.rawValue)")
            print("❌ Error domain: \(error.errorCode)")
            
            switch error.code {
            case .notAuthenticated:
                print("❌ Reason: Not authenticated with iCloud")
                throw SocialError.notAuthenticated
            case .networkUnavailable, .networkFailure:
                print("❌ Reason: Network error")
                throw SocialError.networkError
            case .serverResponseLost, .serviceUnavailable:
                print("❌ Reason: Server error")
                throw SocialError.serverError
            case .badContainer, .missingEntitlement:
                print("❌ Reason: Bad container or missing entitlement")
                print("❌ Container used: iCloud.com.vinay.VinProWorkoutTracker")
                throw SocialError.containerNotConfigured
            case .unknownItem:
                print("❌ Reason: Record type doesn't exist (schema not set up)")
                throw SocialError.containerNotConfigured
            default:
                print("⚠️ Unknown CloudKit error")
                print("⚠️ Make sure iCloud.com.vinay.VinProWorkoutTracker is checked in Xcode")
                throw error
            }
        } catch {
            print("❌ Non-CloudKit error: \(error)")
            throw error
        }
    }
    
    func fetchCurrentUserProfile() async throws {
        print("🔍 Fetching current user profile...")
        
        // Return cached profile if available
        if let cached = currentUserProfile {
            print("✅ Using cached profile: \(cached.displayName)")
            return
        }
        
        guard try await checkAuthentication() else {
            throw SocialError.notAuthenticated
        }
        
        // Get Apple User ID
        let appleUserID = try await getAppleUserID()
        print("🔍 Querying by Apple User ID: \(appleUserID)")
        
        // Fetch user's profile from CloudKit by Apple User ID
        let predicate = NSPredicate(format: "appleUserID == %@", appleUserID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        let results = try await publicDatabase.records(matching: query, desiredKeys: nil, resultsLimit: 1)
        
        if let firstMatch = results.matchResults.first {
            let record = try firstMatch.1.get()
            if let profile = UserProfile(from: record) {
                print("✅ Found profile: \(profile.displayName)")
                self.currentUserProfile = profile
                cacheProfile(profile)
            } else {
                print("⚠️ Could not parse profile record")
                throw SocialError.profileNotFound
            }
        } else {
            print("⚠️ No profile found for Apple User ID: \(appleUserID)")
            throw SocialError.profileNotFound
        }
    }
    
    func updateUserProfile(displayName: String? = nil, bio: String? = nil, totalWorkouts: Int? = nil, totalVolume: Double? = nil) async throws {
        guard var profile = currentUserProfile else { return }
        
        if let displayName = displayName {
            profile.displayName = displayName
        }
        if let bio = bio {
            profile.bio = bio
        }
        if let totalWorkouts = totalWorkouts {
            profile.totalWorkouts = totalWorkouts
        }
        if let totalVolume = totalVolume {
            profile.totalVolume = totalVolume
        }
        
        let record = profile.toCKRecord()
        try await publicDatabase.save(record)
        
        self.currentUserProfile = profile
        cacheProfile(profile) // Cache updated profile
        print("✅ Updated and cached profile")
    }
    
    // 🆕 Update privacy settings (syncs to CloudKit)
    func updatePrivacySettings(_ settings: SocialPrivacySettings) async throws {
        guard var profile = currentUserProfile else {
            throw SocialError.notAuthenticated
        }
        
        // Update profile with privacy settings
        profile.profileVisibility = settings.profileVisibility.rawValue
        profile.showWorkoutCount = settings.showWorkoutCount
        profile.showTotalVolume = settings.showTotalVolume
        profile.showExerciseNames = settings.showExerciseNames
        profile.showSetDetails = settings.showSetDetails
        profile.whoCanFollow = settings.whoCanFollow.rawValue
        profile.autoShareWorkouts = settings.autoShareWorkouts
        
        // Save to CloudKit
        let record = profile.toCKRecord()
        try await publicDatabase.save(record)
        
        // Update local state
        self.currentUserProfile = profile
        cacheProfile(profile)
        
        // Also save to UserDefaults for offline access
        settings.save()
        
        print("✅ Privacy settings updated and synced to CloudKit")
    }
    
    // 🆕 Fetch another user's profile (for privacy checks)
    func fetchUserProfile(userID: String) async throws -> UserProfile {
        #if targetEnvironment(simulator)
        throw SocialError.userNotFound
        #else
        let recordID = CKRecord.ID(recordName: userID)
        let record = try await publicDatabase.record(for: recordID)
        
        guard let profile = UserProfile(from: record) else {
            throw SocialError.userNotFound
        }
        
        return profile
        #endif
    }
    
    // MARK: - Following Management (Simplified - One Way)
    
    /// Search for users by username or display name (privacy-aware)
    func searchUsers(query: String) async throws -> [UserProfile] {
        #if DEBUG
        print("🔍 ========== SEARCH USERS DEBUG ==========")
        print("🔍 Query: '\(query)'")
        print("🔍 Current user: \(currentUserProfile?.username ?? "nil")")
        #endif
        
        let predicate = NSPredicate(format: "username CONTAINS[cd] %@ OR displayName CONTAINS[cd] %@", query, query)
        let ckQuery = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        #if targetEnvironment(simulator)
        print("⚠️ DEBUG: Search in simulator - CloudKit queries may not work properly")
        // Attempt search anyway - might work if iCloud configured
        #endif
        
        #if DEBUG
        print("🔍 Executing CloudKit query...")
        #endif
        let results = try await publicDatabase.records(matching: ckQuery, desiredKeys: nil, resultsLimit: 20)
        #if DEBUG
        print("🔍 CloudKit returned \(results.matchResults.count) raw results")
        #endif
        
        var profiles: [UserProfile] = []
        for (index, result) in results.matchResults.enumerated() {
            #if DEBUG
            print("🔍 Processing result \(index + 1)...")
            #endif
            
            if let record = try? result.1.get() {
                #if DEBUG
                print("   ✅ Got record: \(record.recordID.recordName)")
                print("   - username: \(record["username"] as? String ?? "nil")")
                print("   - displayName: \(record["displayName"] as? String ?? "nil")")
                print("   - isPublic: \(record["isPublic"] as? Int ?? -1)")
                print("   - profileVisibility: \(record["profileVisibility"] as? String ?? "nil")")
                #endif
                
                if let profile = UserProfile(from: record) {
                    #if DEBUG
                    print("   ✅ Parsed profile successfully")
                    
                    // Check filters
                    let isSelf = profile.id == currentUserProfile?.id
                    let isPublic = profile.isPublic
                    let visibilityOK = profile.profileVisibility != "nobody"
                    
                    print("   - Is self: \(isSelf)")
                    print("   - Is public: \(isPublic)")
                    print("   - Visibility: '\(profile.profileVisibility)' (OK: \(visibilityOK))")
                    #endif
                    
                    if profile.id != currentUserProfile?.id, // Don't include yourself
                       profile.isPublic, // ✅ PRIVACY: Only show public profiles
                       profile.profileVisibility != "nobody" { // ✅ Exclude fully private profiles
                        profiles.append(profile)
                        #if DEBUG
                        print("   ✅ ADDED TO RESULTS")
                        #endif
                    } else {
                        #if DEBUG
                        print("   ❌ FILTERED OUT")
                        #endif
                    }
                } else {
                    #if DEBUG
                    print("   ❌ Could not parse profile from record")
                    #endif
                }
            } else {
                #if DEBUG
                print("   ❌ Could not get record")
                #endif
            }
        }
        
        #if DEBUG
        print("✅ Found \(profiles.count) users matching '\(query)' (privacy-filtered)")
        print("🔍 ========================================")
        #endif
        return profiles
    }
    
    /// Follow a user (privacy-aware, respects whoCanFollow setting)
    func followUser(userID: String) async throws {
        guard let currentUser = currentUserProfile else {
            throw SocialError.notAuthenticated
        }
        
        print("🔍 Following user: \(userID)")
        
        // ✅ PRIVACY CHECK: Fetch target user's profile to check settings
        #if !targetEnvironment(simulator)
        let targetRecordID = CKRecord.ID(recordName: userID)
        guard let targetRecord = try? await publicDatabase.record(for: targetRecordID),
              let targetProfile = UserProfile(from: targetRecord) else {
            throw SocialError.userNotFound
        }
        
        // Check whoCanFollow privacy setting
        switch targetProfile.whoCanFollow {
        case "nobody":
            print("❌ User doesn't allow followers")
            throw SocialError.followingNotAllowed
            
        case "approvalRequired":
            print("⚠️ Approval required - creating friend request instead")
            // Create pending friend request
            let friendRequest = FriendRelationship(
                followerID: currentUser.id,
                followingID: userID,
                status: .pending
            )
            let requestRecord = friendRequest.toCKRecord()
            try await publicDatabase.save(requestRecord)
            print("✅ Friend request sent (approval required)")
            throw SocialError.approvalRequired // Inform UI it needs approval
            
        case "everyone":
            // Proceed with instant follow
            break
            
        default:
            // Default to everyone for unknown values
            break
        }
        #endif
        
        // Check if already following
        let predicate = NSPredicate(format: "followerID == %@ AND followingID == %@", currentUser.id, userID)
        let query = CKQuery(recordType: "FollowRelationship", predicate: predicate)
        
        #if !targetEnvironment(simulator)
        let existing = try await publicDatabase.records(matching: query)
        if !existing.matchResults.isEmpty {
            print("⚠️ Already following this user")
            throw SocialError.alreadyFollowing
        }
        #endif
        
        // Create follow relationship (instant, no approval)
        let relationship = FollowRelationship(
            followerID: currentUser.id,
            followingID: userID
        )
        
        #if !targetEnvironment(simulator)
        let record = relationship.toCKRecord()
        try await publicDatabase.save(record)
        print("✅ Now following user")
        #else
        print("⚠️ DEBUG: Simulator - would follow user in real CloudKit")
        #endif
        
        // Refresh following list
        await fetchFollowing()
    }
    
    /// Unfollow a user
    func unfollowUser(userID: String) async throws {
        guard let currentUser = currentUserProfile else { return }
        
        print("🔍 Unfollowing user: \(userID)")
        
        let predicate = NSPredicate(format: "followerID == %@ AND followingID == %@",
                                   currentUser.id, userID)
        let query = CKQuery(recordType: "FollowRelationship", predicate: predicate)
        
        #if !targetEnvironment(simulator)
        let results = try await publicDatabase.records(matching: query)
        
        for result in results.matchResults {
            if let record = try? result.1.get() {
                try await publicDatabase.deleteRecord(withID: record.recordID)
                print("✅ Unfollowed user")
            }
        }
        #else
        print("⚠️ DEBUG: Simulator - would unfollow user in real CloudKit")
        #endif
        
        // Refresh following list
        await fetchFollowing()
    }
    
    /// Check if currently following a specific user
    func isFollowing(userID: String) -> Bool {
        return friends.contains(where: { $0.id == userID })
    }
    
    /// Fetch list of users you're following
    func fetchFollowing() async {
        guard let currentUser = currentUserProfile else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        print("🔍 Fetching users you're following...")
        
        #if targetEnvironment(simulator)
        print("⚠️ DEBUG: Simulator - following list will be empty")
        self.friends = []
        #else
        do {
            // Fetch follow relationships where you're the follower
            let predicate = NSPredicate(format: "followerID == %@", currentUser.id)
            let query = CKQuery(recordType: "FollowRelationship", predicate: predicate)
            
            let results = try await publicDatabase.records(matching: query)
            
            var followingIDs: Set<String> = []
            for result in results.matchResults {
                if let record = try? result.1.get(),
                   let relationship = FollowRelationship(from: record) {
                    followingIDs.insert(relationship.followingID)
                }
            }
            
            print("✅ Found \(followingIDs.count) users you're following")
            
            // Fetch profiles of users you're following
            var followingProfiles: [UserProfile] = []
            for userID in followingIDs {
                let recordID = CKRecord.ID(recordName: userID)
                if let record = try? await publicDatabase.record(for: recordID),
                   let profile = UserProfile(from: record) {
                    followingProfiles.append(profile)
                }
            }
            
            self.friends = followingProfiles // Using 'friends' array to store following
            print("✅ Loaded \(followingProfiles.count) user profiles")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Error fetching following: \(error)")
        }
        #endif
    }
    
    // MARK: - Legacy Friend Requests (Kept for compatibility with existing UI)
    
    /// Legacy: Maps to followUser for compatibility
    func sendFriendRequest(to userID: String) async throws {
        try await followUser(userID: userID)
    }
    
    /// Legacy: No-op since we don't have requests anymore
    func acceptFriendRequest(relationshipID: String) async throws {
        print("⚠️ Accept friend request is deprecated - using instant follow now")
    }
    
    /// Legacy: Maps to unfollowUser for compatibility
    func removeFriend(userID: String) async throws {
        try await unfollowUser(userID: userID)
    }
    
    /// Legacy: Maps to fetchFollowing
    func fetchFriends() async {
        await fetchFollowing()
    }
    
    /// Legacy: Returns empty since no requests with instant follow
    func fetchFriendRequests() async {
        self.friendRequests = []
        print("ℹ️ Friend requests disabled - using instant follow")
    }
    
    // MARK: - User Discovery
    
    func fetchSuggestedUsers() async {
        guard let currentUser = currentUserProfile else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        #if DEBUG
        print("🔍 ========== FETCH SUGGESTED USERS DEBUG ==========")
        print("🔍 Current user: \(currentUser.username)")
        #endif
        
        #if targetEnvironment(simulator)
        print("⚠️ DEBUG: Simulator - CloudKit queries may not work properly")
        // Attempt to fetch anyway - might work if iCloud configured
        #endif
        
        do {
            // Fetch public profiles, sorted by workout count
            let predicate = NSPredicate(format: "isPublic == %d", 1)
            let query = CKQuery(recordType: "UserProfile", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "totalWorkouts", ascending: false)]
            
            #if DEBUG
            print("🔍 Executing CloudKit query for suggested users...")
            #endif
            let results = try await publicDatabase.records(matching: query, desiredKeys: nil, resultsLimit: 20)
            #if DEBUG
            print("🔍 CloudKit returned \(results.matchResults.count) raw results")
            #endif
            
            var profiles: [UserProfile] = []
            let followingIDs = Set(friends.map { $0.id })
            #if DEBUG
            print("🔍 Already following \(followingIDs.count) users")
            #endif
            
            for (index, result) in results.matchResults.enumerated() {
                #if DEBUG
                print("🔍 Processing result \(index + 1)...")
                #endif
                
                if let record = try? result.1.get() {
                    #if DEBUG
                    print("   ✅ Got record: \(record.recordID.recordName)")
                    print("   - username: \(record["username"] as? String ?? "nil")")
                    print("   - displayName: \(record["displayName"] as? String ?? "nil")")
                    print("   - isPublic: \(record["isPublic"] as? Int ?? -1)")
                    print("   - totalWorkouts: \(record["totalWorkouts"] as? Int ?? 0)")
                    #endif
                    
                    if let profile = UserProfile(from: record) {
                        #if DEBUG
                        print("   ✅ Parsed profile successfully")
                        
                        let isSelf = profile.id == currentUser.id
                        let alreadyFollowing = followingIDs.contains(profile.id)
                        
                        print("   - Is self: \(isSelf)")
                        print("   - Already following: \(alreadyFollowing)")
                        #endif
                        
                        if profile.id != currentUser.id, // Don't suggest yourself
                           !followingIDs.contains(profile.id) { // Don't suggest people you already follow
                            profiles.append(profile)
                            #if DEBUG
                            print("   ✅ ADDED TO SUGGESTIONS")
                            #endif
                        } else {
                            #if DEBUG
                            print("   ❌ FILTERED OUT")
                            #endif
                        }
                    } else {
                        #if DEBUG
                        print("   ❌ Could not parse profile from record")
                        #endif
                    }
                } else {
                    #if DEBUG
                    print("   ❌ Could not get record")
                    #endif
                }
            }
            
            self.suggestedUsers = profiles
            #if DEBUG
            print("✅ Found \(profiles.count) suggested users")
            #endif
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Error fetching suggested users: \(error)")
            #if DEBUG
            print("❌ Error details: \(error.localizedDescription)")
            #endif
        }
        #if DEBUG
        print("🔍 ==================================================")
        #endif
    }
    
    // MARK: - Workout Sharing
    
    func shareWorkout(_ workout: Workout, autoShared: Bool = false) async throws {
        guard let currentUser = currentUserProfile else {
            throw SocialError.notAuthenticated
        }
        
        // ✅ PRIVACY: Don't share if auto-share is disabled and this was auto-triggered
        if autoShared && !currentUser.autoShareWorkouts {
            print("⏭️ Auto-share disabled, skipping workout share")
            return
        }
        
        print("🔍 Sharing workout: \(workout.name) (auto: \(autoShared))")
        
        let publicWorkout = PublicWorkout(
            userID: currentUser.id,
            workoutName: workout.name,
            date: workout.date,
            totalVolume: workout.totalVolume,
            exerciseCount: workout.mainExercises.count + workout.coreExercises.count,
            isCompleted: workout.isCompleted
        )
        
        #if !targetEnvironment(simulator)
        let record = publicWorkout.toCKRecord()
        try await publicDatabase.save(record)
        print("✅ Workout shared to feed")
        
        // Update user's total stats
        try await updateUserProfile(
            totalWorkouts: currentUser.totalWorkouts + 1,
            totalVolume: currentUser.totalVolume + workout.totalVolume
        )
        #else
        print("⚠️ DEBUG: Simulator - would share workout in real CloudKit")
        #endif
    }
    
    func fetchFriendWorkouts() async {
        guard currentUserProfile != nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        print("🔍 Fetching workouts from people you follow...")
        
        #if targetEnvironment(simulator)
        print("⚠️ DEBUG: Simulator - feed will be empty")
        self.friendWorkouts = []
        #else
        // If not following anyone, return empty
        guard !friends.isEmpty else {
            print("ℹ️ Not following anyone yet")
            self.friendWorkouts = []
            return
        }
        
        do {
            let followingIDs = friends.map { $0.id }
            let predicate = NSPredicate(format: "userID IN %@", followingIDs)
            let query = CKQuery(recordType: "PublicWorkout", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            let results = try await publicDatabase.records(matching: query, desiredKeys: nil, resultsLimit: 50)
            
            var workouts: [PublicWorkout] = []
            for result in results.matchResults {
                if let record = try? result.1.get(),
                   let workout = PublicWorkout(from: record) {
                    workouts.append(workout)
                }
            }
            
            self.friendWorkouts = workouts
            print("✅ Loaded \(workouts.count) workouts from feed")
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Error fetching friend workouts: \(error)")
        }
        #endif
    }
    
    // MARK: - Debug / Cleanup Methods
    
    #if DEBUG
    /// Deletes the current user's profile from CloudKit (DEBUG only)
    func deleteCurrentUserProfile() async throws {
        guard let profile = currentUserProfile else {
            print("⚠️ No profile to delete")
            return
        }
        
        print("🗑️ Deleting profile: \(profile.displayName)")
        
        let recordID = CKRecord.ID(recordName: profile.id)
        try await publicDatabase.deleteRecord(withID: recordID)
        
        print("✅ Profile deleted from CloudKit")
        
        // Clear local cache
        self.currentUserProfile = nil
        clearCachedProfile()
        
        print("✅ Local cache cleared")
    }
    
    /// Deletes ALL orphaned profiles (profiles without appleUserID field)
    func cleanupOrphanedProfiles() async throws {
        print("🔍 Searching for orphaned profiles...")
        
        // Find profiles that don't have appleUserID field
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query)
        
        var deletedCount = 0
        for result in results.matchResults {
            if let record = try? result.1.get() {
                // Check if appleUserID field is missing
                if record["appleUserID"] as? String == nil {
                    print("🗑️ Deleting orphaned profile: \(record.recordID.recordName)")
                    do {
                        try await publicDatabase.deleteRecord(withID: record.recordID)
                        deletedCount += 1
                    } catch {
                        print("⚠️ Failed to delete orphaned profile: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        print("✅ Deleted \(deletedCount) orphaned profiles")
    }
    #endif
}
