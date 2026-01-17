import Foundation
import CloudKit

// MARK: - User Profile (Public CloudKit Record)

struct UserProfile: Identifiable, Codable {
    let id: String // CKRecord.ID as string
    var appleUserID: String // 🆕 Link to Apple ID for persistence
    var username: String
    var displayName: String
    var bio: String
    var avatarURL: String?
    var createdDate: Date
    var isPublic: Bool
    
    // Stats
    var totalWorkouts: Int
    var totalVolume: Double
    
    // 🆕 Privacy Settings (stored in CloudKit)
    var profileVisibility: String // "everyone", "friendsOnly", "nobody"
    var showWorkoutCount: Bool
    var showTotalVolume: Bool
    var showExerciseNames: Bool
    var showSetDetails: Bool
    var whoCanFollow: String // "everyone", "approvalRequired", "nobody"
    var autoShareWorkouts: Bool
    
    init(
        id: String = UUID().uuidString,
        appleUserID: String,
        username: String,
        displayName: String,
        bio: String = "",
        avatarURL: String? = nil,
        createdDate: Date = Date(),
        isPublic: Bool = true,
        totalWorkouts: Int = 0,
        totalVolume: Double = 0,
        profileVisibility: String = "friendsOnly",
        showWorkoutCount: Bool = true,
        showTotalVolume: Bool = true,
        showExerciseNames: Bool = true,
        showSetDetails: Bool = false,
        whoCanFollow: String = "everyone",
        autoShareWorkouts: Bool = false
    ) {
        self.id = id
        self.appleUserID = appleUserID
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarURL = avatarURL
        self.createdDate = createdDate
        self.isPublic = isPublic
        self.totalWorkouts = totalWorkouts
        self.totalVolume = totalVolume
        self.profileVisibility = profileVisibility
        self.showWorkoutCount = showWorkoutCount
        self.showTotalVolume = showTotalVolume
        self.showExerciseNames = showExerciseNames
        self.showSetDetails = showSetDetails
        self.whoCanFollow = whoCanFollow
        self.autoShareWorkouts = autoShareWorkouts
    }
    
    // Convert from CloudKit Record
    init?(from record: CKRecord) {
        guard let appleUserID = record["appleUserID"] as? String,
              let username = record["username"] as? String,
              let displayName = record["displayName"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.appleUserID = appleUserID
        self.username = username
        self.displayName = displayName
        self.bio = record["bio"] as? String ?? ""
        self.avatarURL = record["avatarURL"] as? String
        self.createdDate = record["createdDate"] as? Date ?? Date()
        self.isPublic = record["isPublic"] as? Int == 1
        self.totalWorkouts = record["totalWorkouts"] as? Int ?? 0
        self.totalVolume = record["totalVolume"] as? Double ?? 0
        
        // Privacy settings with defaults
        self.profileVisibility = record["profileVisibility"] as? String ?? "friendsOnly"
        self.showWorkoutCount = record["showWorkoutCount"] as? Int == 1 ? true : (record["showWorkoutCount"] == nil ? true : false)
        self.showTotalVolume = record["showTotalVolume"] as? Int == 1 ? true : (record["showTotalVolume"] == nil ? true : false)
        self.showExerciseNames = record["showExerciseNames"] as? Int == 1 ? true : (record["showExerciseNames"] == nil ? true : false)
        self.showSetDetails = record["showSetDetails"] as? Int == 1 ? true : false
        self.whoCanFollow = record["whoCanFollow"] as? String ?? "everyone"
        self.autoShareWorkouts = record["autoShareWorkouts"] as? Int == 1 ? true : false
    }
    
    // Convert to CloudKit Record
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "UserProfile", recordID: recordID)
        
        record["appleUserID"] = appleUserID as CKRecordValue
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
        
        // Privacy settings
        record["profileVisibility"] = profileVisibility as CKRecordValue
        record["showWorkoutCount"] = (showWorkoutCount ? 1 : 0) as CKRecordValue
        record["showTotalVolume"] = (showTotalVolume ? 1 : 0) as CKRecordValue
        record["showExerciseNames"] = (showExerciseNames ? 1 : 0) as CKRecordValue
        record["showSetDetails"] = (showSetDetails ? 1 : 0) as CKRecordValue
        record["whoCanFollow"] = whoCanFollow as CKRecordValue
        record["autoShareWorkouts"] = (autoShareWorkouts ? 1 : 0) as CKRecordValue
        
        return record
    }
}

// MARK: - Follow Relationship (Simplified, One-Way Following)

struct FollowRelationship: Identifiable {
    let id: String
    let followerID: String // Person who follows
    let followingID: String // Person being followed
    let followedAt: Date
    
    init(
        id: String = UUID().uuidString,
        followerID: String,
        followingID: String,
        followedAt: Date = Date()
    ) {
        self.id = id
        self.followerID = followerID
        self.followingID = followingID
        self.followedAt = followedAt
    }
    
    init?(from record: CKRecord) {
        guard let followerID = record["followerID"] as? String,
              let followingID = record["followingID"] as? String else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.followerID = followerID
        self.followingID = followingID
        self.followedAt = record["followedAt"] as? Date ?? Date()
    }
    
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: "FollowRelationship", recordID: recordID)
        
        record["followerID"] = followerID as CKRecordValue
        record["followingID"] = followingID as CKRecordValue
        record["followedAt"] = followedAt as CKRecordValue
        
        return record
    }
}

// MARK: - Friend Relationship (Legacy - Kept for Compatibility)

struct FriendRelationship: Identifiable {
    let id: String
    let followerID: String // Person who follows
    let followingID: String // Person being followed
    let createdDate: Date
    var status: FriendStatus
    
    enum FriendStatus: String, Codable {
        case pending
        case accepted
        case blocked
    }
    
    init(
        id: String = UUID().uuidString,
        followerID: String,
        followingID: String,
        createdDate: Date = Date(),
        status: FriendStatus = .pending
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
              let status = FriendStatus(rawValue: statusString) else {
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

struct PublicWorkout: Identifiable, Codable {
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
    case usernameAlreadyTaken // Alias for usernameTaken
    case alreadyFollowing
    case userNotFound
    case profileNotFound // Alias for userNotFound
    case networkError
    case serverError
    case containerNotConfigured
    case followingNotAllowed // 🆕 Privacy: User doesn't allow followers
    case approvalRequired // 🆕 Privacy: Follow requires approval
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to iCloud to use social features. Please sign in to iCloud in Settings."
        case .usernameTaken, .usernameAlreadyTaken:
            return "This username is already taken. Please choose a different one."
        case .alreadyFollowing:
            return "You're already following this user."
        case .userNotFound, .profileNotFound:
            return "User not found."
        case .networkError:
            return "Network connection error. Please check your internet connection and try again."
        case .serverError:
            return "CloudKit server is temporarily unavailable. Please try again later."
        case .containerNotConfigured:
            return "iCloud container is not properly configured. Please check your iCloud settings in Xcode."
        case .followingNotAllowed:
            return "This user's privacy settings don't allow followers."
        case .approvalRequired:
            return "Follow request sent. Waiting for approval."
        }
    }
}
