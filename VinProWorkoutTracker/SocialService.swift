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
    
    init() {
        self.container = CKContainer.default()
        self.publicDatabase = container.publicCloudDatabase
    }
    
    // MARK: - User Profile Management
    
    func checkAuthentication() async throws -> Bool {
        let status = try await container.accountStatus()
        return status == .available
    }
    
    func createUserProfile(username: String, displayName: String, bio: String = "") async throws {
        guard try await checkAuthentication() else {
            throw SocialError.notAuthenticated
        }
        
        // Check if username is available
        let predicate = NSPredicate(format: "username == %@", username)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query)
        if !results.matchResults.isEmpty {
            throw SocialError.usernameTaken
        }
        
        // Create profile
        let profile = UserProfile(
            username: username,
            displayName: displayName,
            bio: bio
        )
        
        let record = profile.toCKRecord()
        try await publicDatabase.save(record)
        
        self.currentUserProfile = profile
    }
    
    func fetchCurrentUserProfile() async throws {
        guard try await checkAuthentication() else {
            throw SocialError.notAuthenticated
        }
        
        // Fetch user's profile from CloudKit
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
        
        let results = try await publicDatabase.records(matching: query, desiredKeys: nil, resultsLimit: 1)
        
        if let firstMatch = results.matchResults.first {
            let record = try firstMatch.1.get()
            if let profile = UserProfile(from: record) {
                self.currentUserProfile = profile
            }
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
    }
    
    // MARK: - Friend Management
    
    func searchUsers(query: String) async throws -> [UserProfile] {
        let predicate = NSPredicate(format: "username CONTAINS %@ OR displayName CONTAINS %@", query, query)
        let ckQuery = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: ckQuery, desiredKeys: nil, resultsLimit: 20)
        
        var profiles: [UserProfile] = []
        for result in results.matchResults {
            if let record = try? result.1.get(),
               let profile = UserProfile(from: record) {
                profiles.append(profile)
            }
        }
        
        return profiles
    }
    
    func sendFriendRequest(to userID: String) async throws {
        guard let currentUser = currentUserProfile else {
            throw SocialError.notAuthenticated
        }
        
        // Check if already following
        let predicate = NSPredicate(format: "followerID == %@ AND followingID == %@", currentUser.id, userID)
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        let existing = try await publicDatabase.records(matching: query)
        if !existing.matchResults.isEmpty {
            throw SocialError.alreadyFollowing
        }
        
        // Create friend relationship
        let relationship = FriendRelationship(
            followerID: currentUser.id,
            followingID: userID,
            status: .pending
        )
        
        let record = relationship.toCKRecord()
        try await publicDatabase.save(record)
    }
    
    func acceptFriendRequest(relationshipID: String) async throws {
        let recordID = CKRecord.ID(recordName: relationshipID)
        let record = try await publicDatabase.record(for: recordID)
        
        record["status"] = "accepted" as CKRecordValue
        try await publicDatabase.save(record)
        
        await fetchFriends()
        await fetchFriendRequests()
    }
    
    func removeFriend(userID: String) async throws {
        guard let currentUser = currentUserProfile else { return }
        
        let predicate = NSPredicate(format: "(followerID == %@ AND followingID == %@) OR (followerID == %@ AND followingID == %@)",
                                   currentUser.id, userID, userID, currentUser.id)
        let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
        
        let results = try await publicDatabase.records(matching: query)
        
        for result in results.matchResults {
            if let record = try? result.1.get() {
                try await publicDatabase.deleteRecord(withID: record.recordID)
            }
        }
        
        await fetchFriends()
    }
    
    func fetchFriends() async {
        guard let currentUser = currentUserProfile else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch accepted friend relationships
            let predicate = NSPredicate(format: "(followerID == %@ OR followingID == %@) AND status == %@",
                                       currentUser.id, currentUser.id, "accepted")
            let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
            
            let results = try await publicDatabase.records(matching: query)
            
            var friendIDs: Set<String> = []
            for result in results.matchResults {
                if let record = try? result.1.get(),
                   let relationship = FriendRelationship(from: record) {
                    if relationship.followerID == currentUser.id {
                        friendIDs.insert(relationship.followingID)
                    } else {
                        friendIDs.insert(relationship.followerID)
                    }
                }
            }
            
            // Fetch friend profiles
            var friendProfiles: [UserProfile] = []
            for friendID in friendIDs {
                let recordID = CKRecord.ID(recordName: friendID)
                if let record = try? await publicDatabase.record(for: recordID),
                   let profile = UserProfile(from: record) {
                    friendProfiles.append(profile)
                }
            }
            
            self.friends = friendProfiles
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchFriendRequests() async {
        guard let currentUser = currentUserProfile else { return }
        
        do {
            // Fetch pending requests where current user is being followed
            let predicate = NSPredicate(format: "followingID == %@ AND status == %@",
                                       currentUser.id, "pending")
            let query = CKQuery(recordType: "FriendRelationship", predicate: predicate)
            
            let results = try await publicDatabase.records(matching: query)
            
            var requests: [FriendRelationship] = []
            for result in results.matchResults {
                if let record = try? result.1.get(),
                   let relationship = FriendRelationship(from: record) {
                    requests.append(relationship)
                }
            }
            
            self.friendRequests = requests
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func fetchSuggestedUsers() async {
        guard let currentUser = currentUserProfile else { return }
        
        do {
            let predicate = NSPredicate(format: "isPublic == %d", 1)
            let query = CKQuery(recordType: "UserProfile", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "totalWorkouts", ascending: false)]
            
            let results = try await publicDatabase.records(matching: query, desiredKeys: nil, resultsLimit: 10)
            
            var profiles: [UserProfile] = []
            for result in results.matchResults {
                if let record = try? result.1.get(),
                   let profile = UserProfile(from: record),
                   profile.id != currentUser.id {
                    profiles.append(profile)
                }
            }
            
            self.suggestedUsers = profiles
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Workout Sharing
    
    func shareWorkout(_ workout: Workout) async throws {
        guard let currentUser = currentUserProfile else {
            throw SocialError.notAuthenticated
        }
        
        let publicWorkout = PublicWorkout(
            userID: currentUser.id,
            workoutName: workout.name,
            date: workout.date,
            totalVolume: workout.totalVolume,
            exerciseCount: workout.sets.count,
            isCompleted: workout.isCompleted
        )
        
        let record = publicWorkout.toCKRecord()
        try await publicDatabase.save(record)
        
        // Update user's total stats
        try await updateUserProfile(
            totalWorkouts: currentUser.totalWorkouts + 1,
            totalVolume: currentUser.totalVolume + workout.totalVolume
        )
    }
    
    func fetchFriendWorkouts() async {
        guard !friends.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let friendIDs = friends.map { $0.id }
            let predicate = NSPredicate(format: "userID IN %@", friendIDs)
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
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
