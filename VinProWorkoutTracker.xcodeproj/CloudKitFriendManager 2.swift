import Foundation
import CloudKit
import SwiftUI

@Observable
class CloudKitFriendManager {
    private let container = CKContainer.default()
    private var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    // Current user's profile
    var currentUserProfile: UserProfile?
    var isSettingUp = false
    var errorMessage: String?
    
    // MARK: - Setup & Authentication
    
    func checkUserSetup() async -> Bool {
        do {
            let recordID = try await getCurrentUserRecordID()
            let profile = try await fetchUserProfile(byRecordID: recordID)
            await MainActor.run {
                self.currentUserProfile = profile
            }
            return profile != nil
        } catch {
            print("Error checking user setup: \(error)")
            return false
        }
    }
    
    func createUserProfile(username: String, displayName: String, bio: String = "") async throws {
        // Check if username is taken
        let isTaken = try await isUsernameTaken(username)
        if isTaken {
            throw SocialError.usernameTaken
        }
        
        let recordID = try await getCurrentUserRecordID()
        
        let profile = UserProfile(
            id: recordID,
            username: username.lowercased(),
            displayName: displayName,
            bio: bio
        )
        
        let record = profile.toCKRecord()
        
        try await publicDatabase.save(record)
        
        await MainActor.run {
            self.currentUserProfile = profile
        }
    }
    
    private func getCurrentUserRecordID() async throws -> String {
        let recordID = try await container.userRecordID()
        return recordID.recordName
    }
    
    // MARK: - User Search
    
    func searchUsers(query: String) async throws -> [UserProfile] {
        let predicate = NSPredicate(format: "username CONTAINS[cd] %@ OR displayName CONTAINS[cd] %@", query, query)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        
        let results = try await publicDatabase.records(matching: query, resultsLimit: 20)
        
        var profiles: [UserProfile] = []
        for (_, result) in results.matchResults {
            if let record = try? result.get(),
               let profile = UserProfile(from: record) {
                profiles.append(profile)
            }
        }
        
        return profiles
    }
    
    func fetchUserProfile(byRecordID recordID: String) async throws -> UserProfile? {
        let ckRecordID = CKRecord.ID(recordName: recordID)
        let record = try await publicDatabase.record(for: ckRecordID)
        return UserProfile(from: record)
    }
    
    func fetchUserProfile(byUsername username: String) async throws -> UserProfile? {
        let predicate = NSPredicate(format: "username == %@", username.lowercased())
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query, resultsLimit: 1)
        
        for (_, result) in results.matchResults {
            if let record = try? result.get() {
                return UserProfile(from: record)
            }
        }
        
        return nil
    }
    
    private func isUsernameTaken(_ username: String) async throws -> Bool {
        let profile = try await fetchUserProfile(byUsername: username)
        return profile != nil
    }
    
    // MARK: - Friend Relationships
    
    func followUser(_ userProfile: UserProfile) async throws {
        guard let currentUserID = currentUserProfile?.id else {
            throw SocialError.notAuthenticated
        }
        
        // Check if already following
        let existing = try await fetchRelationship(followerID: currentUserID, followingID: userProfile.id)
        if existing != nil {
            throw SocialError.alreadyFollowing
        }
        
        let relationship = FriendRelationship(
            followerID: currentUserID,
            followingID: userProfile.id,
            status: .accepted // Simple follow, no approval needed
        )
        
        let record = relationship.toCKRecord()
        try await publicDatabase.save(record)
    }
    
    func unfollowUser(_ userProfile: UserProfile) async throws {
        guard let currentUserID = currentUserProfile?.id else {
            throw SocialError.notAuthenticated
        }
        
        // Find the relationship record
        if let relationship = try await fetchRelationship(followerID: currentUserID, followingID: userProfile.id) {
            let recordID = CKRecord.ID(recordName: relationship.id)
            try await publicDatabase.deleteRecord(withID: recordID)
        }
    }
    
    func isFollowing(_ userProfile: UserProfile) async -> Bool {
        guard let currentUserID = currentUserProfile?.id else {
            return false
        }
        
        do {
            let relationship = try await fetchRelationship(followerID: currentUserID, followingID: userProfile.id)
            return relationship != nil
        } catch {
            return false
        }
    }
    
    private func fetchRelationship(followerID: String, followingID: String) async throws -> FriendRelationship? {
        let predicate = NSPredicate(format: "followerID == %@ AND followingID == %@", followerID, followingID)
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query, resultsLimit: 1)
        
        for (_, result) in results.matchResults {
            if let record = try? result.get() {
                return FriendRelationship(from: record)
            }
        }
        
        return nil
    }
    
    // MARK: - Fetch Friends
    
    func fetchFollowing() async throws -> [UserProfile] {
        guard let currentUserID = currentUserProfile?.id else {
            throw SocialError.notAuthenticated
        }
        
        // Get all relationships where current user is the follower
        let predicate = NSPredicate(format: "followerID == %@", currentUserID)
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query)
        
        var followingIDs: [String] = []
        for (_, result) in results.matchResults {
            if let record = try? result.get(),
               let relationship = FriendRelationship(from: record) {
                followingIDs.append(relationship.followingID)
            }
        }
        
        // Fetch user profiles for all following IDs
        var profiles: [UserProfile] = []
        for id in followingIDs {
            if let profile = try? await fetchUserProfile(byRecordID: id) {
                profiles.append(profile)
            }
        }
        
        return profiles
    }
    
    func fetchFollowers() async throws -> [UserProfile] {
        guard let currentUserID = currentUserProfile?.id else {
            throw SocialError.notAuthenticated
        }
        
        // Get all relationships where current user is being followed
        let predicate = NSPredicate(format: "followingID == %@", currentUserID)
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query)
        
        var followerIDs: [String] = []
        for (_, result) in results.matchResults {
            if let record = try? result.get(),
               let relationship = FriendRelationship(from: record) {
                followerIDs.append(relationship.followerID)
            }
        }
        
        // Fetch user profiles
        var profiles: [UserProfile] = []
        for id in followerIDs {
            if let profile = try? await fetchUserProfile(byRecordID: id) {
                profiles.append(profile)
            }
        }
        
        return profiles
    }
    
    // MARK: - Public Workouts
    
    func shareWorkout(name: String, date: Date, volume: Double, exerciseCount: Int, isCompleted: Bool) async throws {
        guard let currentUserID = currentUserProfile?.id else {
            throw SocialError.notAuthenticated
        }
        
        let publicWorkout = PublicWorkout(
            userID: currentUserID,
            workoutName: name,
            date: date,
            totalVolume: volume,
            exerciseCount: exerciseCount,
            isCompleted: isCompleted
        )
        
        let record = publicWorkout.toCKRecord()
        try await publicDatabase.save(record)
    }
    
    func fetchFriendsWorkouts(limit: Int = 20) async throws -> [(UserProfile, PublicWorkout)] {
        // Get following list
        let following = try await fetchFollowing()
        let followingIDs = following.map { $0.id }
        
        guard !followingIDs.isEmpty else {
            return []
        }
        
        // Fetch recent workouts from friends
        let predicate = NSPredicate(format: "userID IN %@", followingIDs)
        let query = CKQuery(recordType: "PublicWorkout", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let results = try await publicDatabase.records(matching: query, resultsLimit: limit)
        
        var workoutsWithProfiles: [(UserProfile, PublicWorkout)] = []
        
        for (_, result) in results.matchResults {
            if let record = try? result.get(),
               let workout = PublicWorkout(from: record),
               let profile = following.first(where: { $0.id == workout.userID }) {
                workoutsWithProfiles.append((profile, workout))
            }
        }
        
        return workoutsWithProfiles
    }
    
    func fetchUserWorkouts(userID: String, limit: Int = 10) async throws -> [PublicWorkout] {
        let predicate = NSPredicate(format: "userID == %@", userID)
        let query = CKQuery(recordType: "PublicWorkout", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let results = try await publicDatabase.records(matching: query, resultsLimit: limit)
        
        var workouts: [PublicWorkout] = []
        for (_, result) in results.matchResults {
            if let record = try? result.get(),
               let workout = PublicWorkout(from: record) {
                workouts.append(workout)
            }
        }
        
        return workouts
    }
    
    // MARK: - Update Profile Stats
    
    func updateUserStats(totalWorkouts: Int, totalVolume: Double) async throws {
        guard var profile = currentUserProfile else {
            throw SocialError.notAuthenticated
        }
        
        profile.totalWorkouts = totalWorkouts
        profile.totalVolume = totalVolume
        
        let record = profile.toCKRecord()
        try await publicDatabase.save(record)
        
        await MainActor.run {
            self.currentUserProfile = profile
        }
    }
}

// MARK: - Errors

enum SocialError: LocalizedError {
    case notAuthenticated
    case usernameTaken
    case alreadyFollowing
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please set up your profile first"
        case .usernameTaken:
            return "This username is already taken"
        case .alreadyFollowing:
            return "You're already following this user"
        case .userNotFound:
            return "User not found"
        }
    }
}
