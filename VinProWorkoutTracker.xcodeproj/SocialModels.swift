import Foundation
import CloudKit

/// Models for the social/friends feature
/// These are stored in CloudKit Public Database

// MARK: - User Profile (Public)

struct UserProfile: Identifiable, Codable {
    let id: String // CloudKit record ID
    let appleUserID: String // Reference to Apple ID (hashed)
    var username: String // Unique, searchable username
    var displayName: String
    var bio: String
    var avatarURL: String? // Optional avatar image URL
    var isPublic: Bool // Privacy: public profile or private
    var createdAt: Date
    var updatedAt: Date
    
    // Stats (public)
    var totalWorkouts: Int
    var totalVolume: Double
    var joinedDate: Date
    
    init(
        id: String = UUID().uuidString,
        appleUserID: String,
        username: String,
        displayName: String,
        bio: String = "",
        avatarURL: String? = nil,
        isPublic: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        totalWorkouts: Int = 0,
        totalVolume: Double = 0,
        joinedDate: Date = Date()
    ) {
        self.id = id
        self.appleUserID = appleUserID
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarURL = avatarURL
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.totalWorkouts = totalWorkouts
        self.totalVolume = totalVolume
        self.joinedDate = joinedDate
    }
    
    // Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "UserProfile", recordID: CKRecord.ID(recordName: id))
        record["appleUserID"] = appleUserID as CKRecordValue
        record["username"] = username.lowercased() as CKRecordValue
        record["displayName"] = displayName as CKRecordValue
        record["bio"] = bio as CKRecordValue
        record["isPublic"] = (isPublic ? 1 : 0) as CKRecordValue
        record["totalWorkouts"] = totalWorkouts as CKRecordValue
        record["totalVolume"] = totalVolume as CKRecordValue
        record["joinedDate"] = joinedDate as CKRecordValue
        
        if let avatarURL = avatarURL {
            record["avatarURL"] = avatarURL as CKRecordValue
        }
        
        return record
    }
    
    // Create from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> UserProfile? {
        guard
            let appleUserID = record["appleUserID"] as? String,
            let username = record["username"] as? String,
            let displayName = record["displayName"] as? String
        else {
            return nil
        }
        
        return UserProfile(
            id: record.recordID.recordName,
            appleUserID: appleUserID,
            username: username,
            displayName: displayName,
            bio: record["bio"] as? String ?? "",
            avatarURL: record["avatarURL"] as? String,
            isPublic: (record["isPublic"] as? Int ?? 1) == 1,
            createdAt: record.creationDate ?? Date(),
            updatedAt: record.modificationDate ?? Date(),
            totalWorkouts: record["totalWorkouts"] as? Int ?? 0,
            totalVolume: record["totalVolume"] as? Double ?? 0,
            joinedDate: record["joinedDate"] as? Date ?? Date()
        )
    }
}

// MARK: - Friend Relationship

struct FriendRelationship: Identifiable, Codable {
    let id: String
    let followerID: String // User who is following
    let followingID: String // User being followed
    let status: RelationshipStatus
    let createdAt: Date
    
    enum RelationshipStatus: String, Codable {
        case pending    // Request sent, not accepted
        case accepted   // Both are friends
        case blocked    // User blocked
    }
    
    init(
        id: String = UUID().uuidString,
        followerID: String,
        followingID: String,
        status: RelationshipStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.followerID = followerID
        self.followingID = followingID
        self.status = status
        self.createdAt = createdAt
    }
    
    // Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "FriendRelationship", recordID: CKRecord.ID(recordName: id))
        record["followerID"] = followerID as CKRecordValue
        record["followingID"] = followingID as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        return record
    }
    
    // Create from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> FriendRelationship? {
        guard
            let followerID = record["followerID"] as? String,
            let followingID = record["followingID"] as? String,
            let statusString = record["status"] as? String,
            let status = RelationshipStatus(rawValue: statusString)
        else {
            return nil
        }
        
        return FriendRelationship(
            id: record.recordID.recordName,
            followerID: followerID,
            followingID: followingID,
            status: status,
            createdAt: record.creationDate ?? Date()
        )
    }
}

// MARK: - Public Workout (Shared with friends)

struct PublicWorkout: Identifiable, Codable {
    let id: String
    let userID: String // Owner's profile ID
    let workoutName: String
    let date: Date
    let totalVolume: Double
    let exerciseCount: Int
    let duration: Int // minutes
    let notes: String
    var likeCount: Int
    var commentCount: Int
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userID: String,
        workoutName: String,
        date: Date,
        totalVolume: Double,
        exerciseCount: Int,
        duration: Int,
        notes: String = "",
        likeCount: Int = 0,
        commentCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.workoutName = workoutName
        self.date = date
        self.totalVolume = totalVolume
        self.exerciseCount = exerciseCount
        self.duration = duration
        self.notes = notes
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.createdAt = createdAt
    }
    
    // Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "PublicWorkout", recordID: CKRecord.ID(recordName: id))
        record["userID"] = userID as CKRecordValue
        record["workoutName"] = workoutName as CKRecordValue
        record["date"] = date as CKRecordValue
        record["totalVolume"] = totalVolume as CKRecordValue
        record["exerciseCount"] = exerciseCount as CKRecordValue
        record["duration"] = duration as CKRecordValue
        record["notes"] = notes as CKRecordValue
        record["likeCount"] = likeCount as CKRecordValue
        record["commentCount"] = commentCount as CKRecordValue
        return record
    }
    
    // Create from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> PublicWorkout? {
        guard
            let userID = record["userID"] as? String,
            let workoutName = record["workoutName"] as? String,
            let date = record["date"] as? Date
        else {
            return nil
        }
        
        return PublicWorkout(
            id: record.recordID.recordName,
            userID: userID,
            workoutName: workoutName,
            date: date,
            totalVolume: record["totalVolume"] as? Double ?? 0,
            exerciseCount: record["exerciseCount"] as? Int ?? 0,
            duration: record["duration"] as? Int ?? 0,
            notes: record["notes"] as? String ?? "",
            likeCount: record["likeCount"] as? Int ?? 0,
            commentCount: record["commentCount"] as? Int ?? 0,
            createdAt: record.creationDate ?? Date()
        )
    }
}
