import Foundation
import CloudKit
import SwiftUI

/// Manager for CloudKit friend system
/// Handles user profiles, friend relationships, and public workouts

@Observable
class CloudKitFriendManager {
    
    // MARK: - Properties
    
    var currentUserProfile: UserProfile?
    var friends: [UserProfile] = []
    var pendingRequests: [UserProfile] = []
    var isLoading = false
    var errorMessage: String?
    
    private let container = CKContainer.default()
    private var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    // MARK: - Feature Flag
    
    static let isEnabled = true // Set to false to disable friends feature
    
    // MARK: - Initialization
    
    init() {
        Task {
            await checkCurrentUser()
        }
    }
    
    // MARK: - User Profile Management
    
    /// Check if current user has a profile, create if needed
    func checkCurrentUser() async {
        guard let userRecordID = try? await container.userRecordID() else {
            errorMessage = "Could not get user ID from iCloud"
            return
        }
        
        // Try to fetch existing profile
        let appleUserID = userRecordID.recordName
        
        do {
            currentUserProfile = try await fetchUserProfile(by: appleUserID)
        } catch {
            // No profile exists - user needs to create one
            currentUserProfile = nil
        }
    }
    
    /// Create a new user profile
    func createUserProfile(username: String, displayName: String, bio: String = "") async throws -> UserProfile {
        guard let userRecordID = try? await container.userRecordID() else {
            throw CloudKitError.noUserID
        }
        
        let appleUserID = userRecordID.recordName
        
        // Check if username is available
        let isAvailable = try await isUsernameAvailable(username)
        guard isAvailable else {
            throw CloudKitError.usernameExists
        }
        
        // Create profile
        let profile = UserProfile(
            appleUserID: appleUserID,
            username: username.lowercased(),
            displayName: displayName,
            bio: bio
        )
        
        let record = profile.toCKRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            let savedProfile = UserProfile.fromCKRecord(savedRecord)
            currentUserProfile = savedProfile
            return savedProfile!
        } catch {
            throw CloudKitError.saveFailed(error)
        }
    }
    
    /// Update current user's profile
    func updateUserProfile(displayName: String? = nil, bio: String? = nil, isPublic: Bool? = nil) async throws {
        guard var profile = currentUserProfile else {
            throw CloudKitError.noProfile
        }
        
        if let displayName = displayName {
            profile.displayName = displayName
        }
        
        if let bio = bio {
            profile.bio = bio
        }
        
        if let isPublic = isPublic {
            profile.isPublic = isPublic
        }
        
        profile.updatedAt = Date()
        
        let record = profile.toCKRecord()
        
        do {
            let savedRecord = try await publicDatabase.save(record)
            currentUserProfile = UserProfile.fromCKRecord(savedRecord)
        } catch {
            throw CloudKitError.saveFailed(error)
        }
    }
    
    /// Check if username is available
    func isUsernameAvailable(_ username: String) async throws -> Bool {
        let predicate = NSPredicate(format: "username == %@", username.lowercased())
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        do {
            let results = try await publicDatabase.records(matching: query)
            return results.matchResults.isEmpty
        } catch {
            throw CloudKitError.queryFailed(error)
        }
    }
    
    /// Fetch user profile by Apple User ID
    private func fetchUserProfile(by appleUserID: String) async throws -> UserProfile {
        let predicate = NSPredicate(format: "appleUserID == %@", appleUserID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        do {
            let results = try await publicDatabase.records(matching: query)
            
            guard let firstResult = results.matchResults.first,
                  case .success(let record) = firstResult.1 else {
                throw CloudKitError.noProfile
            }
            
            guard let profile = UserProfile.fromCKRecord(record) else {
                throw CloudKitError.invalidData
            }
            
            return profile
        } catch {
            throw CloudKitError.queryFailed(error)
        }
    }
    
    // MARK: - User Search
    
    /// Search for users by username
    func searchUsers(username: String) async throws -> [UserProfile] {
        let searchTerm = username.lowercased()
        let predicate = NSPredicate(format: "username BEGINSWITH %@ AND isPublic == 1", searchTerm)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        
        do {
            let results = try await publicDatabase.records(matching: query)
            
            var profiles: [UserProfile] = []
            for result in results.matchResults {
                if case .success(let record) = result.1,
                   let profile = UserProfile.fromCKRecord(record) {
                    profiles.append(profile)
                }
            }
            
            return profiles
        } catch {
            throw CloudKitError.queryFailed(error)
        }
    }
    
    // MARK: - Friend Relationships
    
    /// Follow a user
    func followUser(_ userProfile: UserProfile) async throws {
        guard let currentProfile = currentUserProfile else {
            throw CloudKitError.noProfile
        }
        
        // Check if already following
        let existing = try? await fetchRelationship(from: currentProfile.id, to: userProfile.id)
        if existing != nil {
            throw CloudKitError.alreadyFollowing
        }
        
        // Create relationship
        let relationship = FriendRelationship(
            followerID: currentProfile.id,
            followingID: userProfile.id,
            status: .accepted // Simple follow model (not request-based)
        )
        
        let record = relationship.toCKRecord()
        
        do {
            _ = try await publicDatabase.save(record)
            
            // Refresh friends list
            await loadFriends()
        } catch {
            throw CloudKitError.saveFailed(error)
        }
    }
    
    /// Unfollow a user
    func unfollowUser(_ userProfile: UserProfile) async throws {
        guard let currentProfile = currentUserProfile else {
            throw CloudKitError.noProfile
        }
        
        // Find relationship
        guard let relationship = try? await fetchRelationship(from: currentProfile.id, to: userProfile.id) else {
            throw CloudKitError.notFollowing
        }
        
        // Delete relationship
        let recordID = CKRecord.ID(recordName: relationship.id)
        
        do {
            _ = try await publicDatabase.deleteRecord(withID: recordID)
            
            // Refresh friends list
            await loadFriends()
        } catch {
            throw CloudKitError.deleteFailed(error)
        }
    }
    
    /// Check if currently following a user
    func isFollowing(_ userProfile: UserProfile) async -> Bool {
        guard let currentProfile = currentUserProfile else {
            return false
        }
        
        let relationship = try? await fetchRelationship(from: currentProfile.id, to: userProfile.id)
        return relationship != nil
    }
    
    /// Fetch relationship between two users
    private func fetchRelationship(from followerID: String, to followingID: String) async throws -> FriendRelationship? {
        let predicate = NSPredicate(
            format: "followerID == %@ AND followingID == %@",
            followerID,
            followingID
        )
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        do {
            let results = try await publicDatabase.records(matching: query)
            
            guard let firstResult = results.matchResults.first,
                  case .success(let record) = firstResult.1 else {
                return nil
            }
            
            return FriendRelationship.fromCKRecord(record)
        } catch {
            return nil
        }
    }
    
    /// Load friends list
    func loadFriends() async {
        guard let currentProfile = currentUserProfile else { return }
        
        isLoading = true
        
        // Query relationships where current user is follower
        let predicate = NSPredicate(format: "followerID == %@", currentProfile.id)
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        do {
            let results = try await publicDatabase.records(matching: query)
            
            var friendIDs: [String] = []
            for result in results.matchResults {
                if case .success(let record) = result.1,
                   let relationship = FriendRelationship.fromCKRecord(record) {
                    friendIDs.append(relationship.followingID)
                }
            }
            
            // Fetch friend profiles
            var friendProfiles: [UserProfile] = []
            for friendID in friendIDs {
                if let profile = try? await fetchProfileByID(friendID) {
                    friendProfiles.append(profile)
                }
            }
            
            await MainActor.run {
                self.friends = friendProfiles
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load friends"
                self.isLoading = false
            }
        }
    }
    
    /// Fetch user profile by profile ID
    private func fetchProfileByID(_ profileID: String) async throws -> UserProfile {
        let recordID = CKRecord.ID(recordName: profileID)
        
        do {
            let record = try await publicDatabase.record(for: recordID)
            guard let profile = UserProfile.fromCKRecord(record) else {
                throw CloudKitError.invalidData
            }
            return profile
        } catch {
            throw CloudKitError.queryFailed(error)
        }
    }
    
    // MARK: - Public Workouts (Activity Feed)
    
    /// Share a workout publicly
    func shareWorkout(name: String, date: Date, totalVolume: Double, exerciseCount: Int, duration: Int, notes: String = "") async throws {
        guard let currentProfile = currentUserProfile else {
            throw CloudKitError.noProfile
        }
        
        let publicWorkout = PublicWorkout(
            userID: currentProfile.id,
            workoutName: name,
            date: date,
            totalVolume: totalVolume,
            exerciseCount: exerciseCount,
            duration: duration,
            notes: notes
        )
        
        let record = publicWorkout.toCKRecord()
        
        do {
            _ = try await publicDatabase.save(record)
        } catch {
            throw CloudKitError.saveFailed(error)
        }
    }
    
    /// Fetch friends' recent workouts (activity feed)
    func loadFriendsActivity(limit: Int = 20) async throws -> [PublicWorkout] {
        guard let currentProfile = currentUserProfile else {
            throw CloudKitError.noProfile
        }
        
        // Get friend IDs
        let friendIDs = friends.map { $0.id }
        
        guard !friendIDs.isEmpty else {
            return []
        }
        
        // Query workouts from friends
        let predicate = NSPredicate(format: "userID IN %@", friendIDs)
        let query = CKQuery(recordType: "PublicWorkout", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try await publicDatabase.records(matching: query)
            
            var workouts: [PublicWorkout] = []
            for result in results.matchResults.prefix(limit) {
                if case .success(let record) = result.1,
                   let workout = PublicWorkout.fromCKRecord(record) {
                    workouts.append(workout)
                }
            }
            
            return workouts
        } catch {
            throw CloudKitError.queryFailed(error)
        }
    }
}

// MARK: - Errors

enum CloudKitError: Error, LocalizedError {
    case noUserID
    case noProfile
    case usernameExists
    case invalidData
    case saveFailed(Error)
    case queryFailed(Error)
    case deleteFailed(Error)
    case alreadyFollowing
    case notFollowing
    
    var errorDescription: String? {
        switch self {
        case .noUserID:
            return "Could not get your iCloud user ID. Make sure you're signed in to iCloud."
        case .noProfile:
            return "You need to create a profile first."
        case .usernameExists:
            return "This username is already taken. Please choose another."
        case .invalidData:
            return "Invalid data received from server."
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .queryFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .alreadyFollowing:
            return "You're already following this user."
        case .notFollowing:
            return "You're not following this user."
        }
    }
}
