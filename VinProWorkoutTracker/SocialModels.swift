import Foundation
import CloudKit

// MARK: - User Profile (Public CloudKit Record)

struct UserProfile: Identifiable, Codable {
    let id: String // CKRecord.ID as string
    var username: String
    var displayName: String
    var bio: String
    var avatarURL: String?
    var createdDate: Date
    var isPublic: Bool
    
    // Stats
    var totalWorkouts: Int
    var totalVolume: Double
    
    init(
        id: String = UUID().uuidString,
        username: String,
        displayName: String,
        bio: String = "",
        avatarURL: String? = nil,
        createdDate: Date = Date(),
        isPublic: Bool = true,
        totalWorkouts: Int = 0,
        totalVolume: Double = 0
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarURL = avatarURL
        self.createdDate = createdDate
        self.isPublic = isPublic
        self.totalWorkouts = totalWorkouts
        self.totalVolume = totalVolume
    }
    
    // Convert from CloudKit Record
    init?(from record: CKRecord) {
        guard let username = record["username"] as? String,
              let displayName = record["displayName"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.username = username
        self.displayName = displayName
        self.bio = record["bio"] as? String ?? ""
        self.avatarURL = record["avatarURL"] as? String
        self.createdDate = record["createdDate"] as? Date ?? Date()
        self.isPublic = record["isPublic"] as? Int == 1
        self.totalWorkouts = record["totalWorkouts"] as? Int ?? 0
        self.totalVolume = record["totalVolume"] as? Double ?? 0
    }
    
    // Convert to CloudKit Record
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "UserProfile", recordID: recordID)
        
        record["username"] = username as CKRecordValue
        record["displayName"] = displayName as CKRecordValue
        record["bio"] = bio as CKRecordValue
        if let url = avatarURL {
            record["avatarURL"] = url as CKRecordValue
        }
        record["createdDate"] = createdDate as CKRecordValue
        record["isPublic"] = (isPublic ? 1 : 0) as CKRecordValue
        record["totalWorkouts"] = totalWorkouts as CKRecordValue
        record["totalVolume"] = totalVolume as CKRecordValue
        
        return record
    }
}

// MARK: - Friend Relationship

struct FriendRelationship: Identifiable {
    let id: String
    let followerID: String // Person who follows
    let followingID: String // Person being followed
    let createdDate: Date
    var status: RelationshipStatus
    
    enum RelationshipStatus: String {
        case pending
        case accepted
        case blocked
    }
    
    init(
        id: String = UUID().uuidString,
        followerID: String,
        followingID: String,
        createdDate: Date = Date(),
        status: RelationshipStatus = .accepted
    ) {
        self.id = id
        self.followerID = followerID
        self.followingID = followingID
        self.createdDate = createdDate
        self.status = status
    }
    
    init?(from record: CKRecord) {
        guard let followerID = record["followerID"] as? String,
              let followingID = record["followingID"] as? String,
              let statusString = record["status"] as? String,
              let status = RelationshipStatus(rawValue: statusString) else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.followerID = followerID
        self.followingID = followingID
        self.createdDate = record["createdDate"] as? Date ?? Date()
        self.status = status
    }
    
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "FriendRelationship", recordID: recordID)
        
        record["followerID"] = followerID as CKRecordValue
        record["followingID"] = followingID as CKRecordValue
        record["createdDate"] = createdDate as CKRecordValue
        record["status"] = status.rawValue as CKRecordValue
        
        return record
    }
}

// MARK: - Public Workout (Shared workout data)

struct PublicWorkout: Identifiable {
    let id: String
    let userID: String
    let workoutName: String
    let date: Date
    let totalVolume: Double
    let exerciseCount: Int
    let isCompleted: Bool
    
    init(
        id: String = UUID().uuidString,
        userID: String,
        workoutName: String,
        date: Date,
        totalVolume: Double,
        exerciseCount: Int,
        isCompleted: Bool
    ) {
        self.id = id
        self.userID = userID
        self.workoutName = workoutName
        self.date = date
        self.totalVolume = totalVolume
        self.exerciseCount = exerciseCount
        self.isCompleted = isCompleted
    }
    
    init?(from record: CKRecord) {
        guard let userID = record["userID"] as? String,
              let workoutName = record["workoutName"] as? String,
              let date = record["date"] as? Date else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.userID = userID
        self.workoutName = workoutName
        self.date = date
        self.totalVolume = record["totalVolume"] as? Double ?? 0
        self.exerciseCount = record["exerciseCount"] as? Int ?? 0
        self.isCompleted = record["isCompleted"] as? Int == 1
    }
    
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "PublicWorkout", recordID: recordID)
        
        record["userID"] = userID as CKRecordValue
        record["workoutName"] = workoutName as CKRecordValue
        record["date"] = date as CKRecordValue
        record["totalVolume"] = totalVolume as CKRecordValue
        record["exerciseCount"] = exerciseCount as CKRecordValue
        record["isCompleted"] = (isCompleted ? 1 : 0) as CKRecordValue
        
        return record
    }
}

// MARK: - Social Errors

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
