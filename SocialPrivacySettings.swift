import Foundation

/// Privacy settings for social features
struct SocialPrivacySettings: Codable, Equatable {
    
    // MARK: - Profile Visibility
    
    /// Who can see your profile
    var profileVisibility: Visibility = .everyone
    
    /// Show profile photo
    var showProfilePhoto: Bool = true
    
    /// Show bio
    var showBio: Bool = true
    
    // MARK: - Stats Visibility
    
    /// Show total workout count
    var showWorkoutCount: Bool = true
    
    /// Show total volume lifted
    var showTotalVolume: Bool = true
    
    /// Show workout streak
    var showStreak: Bool = true
    
    /// Show personal records
    var showPersonalRecords: Bool = false
    
    // MARK: - Workout Sharing
    
    /// Automatically share workouts to feed when completed
    var autoShareWorkouts: Bool = false
    
    /// Show exercise names in shared workouts
    var showExerciseNames: Bool = true
    
    /// Show set details (weight/reps) in shared workouts
    var showSetDetails: Bool = false
    
    /// Show workout notes
    var showWorkoutNotes: Bool = false
    
    // MARK: - Social Interactions
    
    /// Who can send you friend requests
    var whoCanFollow: FollowPermission = .everyone
    
    /// Allow workout reactions/likes
    var allowWorkoutReactions: Bool = true
    
    /// Allow comments on workouts
    var allowComments: Bool = false
    
    // MARK: - Enums
    
    enum Visibility: String, Codable, CaseIterable {
        case everyone = "Everyone"
        case friendsOnly = "Friends Only"
        case nobody = "Only Me"
        
        var description: String {
            switch self {
            case .everyone:
                return "Anyone can see your profile"
            case .friendsOnly:
                return "Only people you follow can see your profile"
            case .nobody:
                return "Your profile is completely private"
            }
        }
        
        var icon: String {
            switch self {
            case .everyone: return "globe"
            case .friendsOnly: return "person.2"
            case .nobody: return "lock"
            }
        }
    }
    
    enum FollowPermission: String, Codable, CaseIterable {
        case everyone = "Everyone"
        case friendsOnly = "Friends of Friends"
        case approvalRequired = "Approval Required"
        case nobody = "No One"
        
        var description: String {
            switch self {
            case .everyone:
                return "Anyone can follow you"
            case .friendsOnly:
                return "Only friends of your friends can follow you"
            case .approvalRequired:
                return "You must approve all follow requests"
            case .nobody:
                return "No one can follow you"
            }
        }
    }
    
    // MARK: - Presets
    
    static var publicPreset: SocialPrivacySettings {
        var settings = SocialPrivacySettings()
        settings.profileVisibility = .everyone
        settings.showWorkoutCount = true
        settings.showTotalVolume = true
        settings.showStreak = true
        settings.showPersonalRecords = true
        settings.autoShareWorkouts = true
        settings.showExerciseNames = true
        settings.showSetDetails = true
        settings.whoCanFollow = .everyone
        settings.allowWorkoutReactions = true
        settings.allowComments = true
        return settings
    }
    
    static var friendsOnlyPreset: SocialPrivacySettings {
        var settings = SocialPrivacySettings()
        settings.profileVisibility = .friendsOnly
        settings.showWorkoutCount = true
        settings.showTotalVolume = true
        settings.showStreak = true
        settings.showPersonalRecords = false
        settings.autoShareWorkouts = false
        settings.showExerciseNames = true
        settings.showSetDetails = false
        settings.whoCanFollow = .friendsOnly
        settings.allowWorkoutReactions = true
        settings.allowComments = false
        return settings
    }
    
    static var privatePreset: SocialPrivacySettings {
        var settings = SocialPrivacySettings()
        settings.profileVisibility = .nobody
        settings.showWorkoutCount = false
        settings.showTotalVolume = false
        settings.showStreak = false
        settings.showPersonalRecords = false
        settings.autoShareWorkouts = false
        settings.showExerciseNames = false
        settings.showSetDetails = false
        settings.whoCanFollow = .nobody
        settings.allowWorkoutReactions = false
        settings.allowComments = false
        return settings
    }
    
    // MARK: - Persistence
    
    private static let storageKey = "socialPrivacySettings"
    
    static func load() -> SocialPrivacySettings {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let settings = try? JSONDecoder().decode(SocialPrivacySettings.self, from: data) {
            return settings
        }
        // Default: Friends only for new users
        return friendsOnlyPreset
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: SocialPrivacySettings.storageKey)
        }
    }
}
