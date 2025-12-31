# Social Features Documentation

## Overview

The VinPro Workout Tracker now includes comprehensive social features that allow users to connect with friends, share workouts, and see their friends' fitness progress.

## Features

### 1. User Profiles
- **Create Profile**: Users can create a social profile with username, display name, and bio
- **Profile Stats**: Display total workouts completed and total volume lifted
- **Profile Customization**: Edit display name and bio at any time

### 2. Friend System
- **Send Friend Requests**: Find and add friends by searching for usernames
- **Accept/Reject Requests**: Manage incoming friend requests
- **Friends List**: View all your connected friends with their stats
- **Remove Friends**: Unfriend users if needed

### 3. User Discovery
- **Search Users**: Search for users by username or display name
- **Suggested Users**: Discover active users based on their workout stats
- **User Profiles**: View detailed profiles of other users including their stats and recent workouts

### 4. Activity Feed
- **Friend Workouts**: See your friends' completed workouts in real-time
- **Workout Details**: View workout names, dates, exercise counts, and total volume
- **Completion Status**: See which workouts were completed

### 5. Workout Sharing
- **Share to CloudKit**: Share completed workouts with friends
- **Automatic Stats Update**: Your profile stats update automatically when you share workouts
- **Privacy**: Only friends can see your shared workouts

## Architecture

### Key Components

#### SocialService.swift
The main service class that handles all CloudKit operations:
- User authentication and profile management
- Friend relationship CRUD operations
- Workout sharing and retrieval
- User search and discovery

#### FriendsView.swift
The main social tab with three sections:
- **Friends Tab**: Shows friend list and pending requests
- **Feed Tab**: Displays friends' recent workouts
- **Discover Tab**: Suggests users to follow

#### ProfileSetupView.swift
Onboarding flow for creating a social profile:
- Username validation
- Display name entry
- Optional bio

#### UserProfileView.swift
Detailed view of any user's profile:
- Profile information and stats
- Friend/Unfriend actions
- Recent workout history

### Data Models

#### UserProfile
```swift
struct UserProfile {
    let id: String
    var username: String
    var displayName: String
    var bio: String
    var totalWorkouts: Int
    var totalVolume: Double
}
```

#### FriendRelationship
```swift
struct FriendRelationship {
    let id: String
    let followerID: String
    let followingID: String
    var status: RelationshipStatus // .pending, .accepted, .blocked
}
```

#### PublicWorkout
```swift
struct PublicWorkout {
    let id: String
    let userID: String
    let workoutName: String
    let date: Date
    let totalVolume: Double
    let exerciseCount: Int
    let isCompleted: Bool
}
```

## CloudKit Setup

To use these features, you need to configure CloudKit in your Xcode project:

### 1. Enable iCloud Capability
1. Select your project in Xcode
2. Go to "Signing & Capabilities"
3. Click "+ Capability" and add "iCloud"
4. Check "CloudKit"

### 2. Create Record Types
In CloudKit Dashboard (developer.apple.com), create these record types:

**UserProfile**
- username (String, Queryable, Sortable)
- displayName (String, Queryable)
- bio (String)
- avatarURL (String)
- createdDate (Date/Time)
- isPublic (Int64)
- totalWorkouts (Int64)
- totalVolume (Double)

**FriendRelationship**
- followerID (String, Queryable)
- followingID (String, Queryable)
- createdDate (Date/Time)
- status (String, Queryable)

**PublicWorkout**
- userID (String, Queryable)
- workoutName (String)
- date (Date/Time, Sortable)
- totalVolume (Double)
- exerciseCount (Int64)
- isCompleted (Int64)

### 3. Set Permissions
For all record types, set these permissions in the Public Database:
- World: Read
- Authenticated: Create, Write (on own records)

## Usage

### Creating a Profile
1. Navigate to the Friends tab
2. Tap "Create Profile"
3. Enter a unique username (3+ characters, letters/numbers/underscores only)
4. Enter your display name
5. Optionally add a bio
6. Tap "Create"

### Adding Friends
1. Use the search bar to find users by username
2. Tap on a user to view their profile
3. Tap "Add Friend" to send a request
4. The user can accept your request from their Friends tab

### Viewing the Feed
1. Go to the Friends tab
2. Switch to the "Feed" section
3. Pull down to refresh and see the latest workouts from friends

### Sharing a Workout
1. Open any workout in your list
2. Tap the menu (•••) button
3. Select "Share to Friends"
4. The workout will appear in your friends' feeds

## Privacy & Security

- **User Authentication**: All CloudKit operations require iCloud authentication
- **Public Database**: Social data is stored in the public CloudKit database for discoverability
- **Friend-Only Visibility**: Only accepted friends can see your shared workouts
- **Profile Control**: Users can choose to make their profile public or private
- **Local Data**: Your workout details remain private in SwiftData; only summary info is shared

## Future Enhancements

Potential features to add:
- Direct messaging between friends
- Workout comments and reactions
- Challenge system (compete with friends)
- Leaderboards
- Group workouts
- Profile photos using CloudKit Assets
- Activity notifications
- Workout templates sharing
- Privacy settings (public/friends-only/private posts)

## Error Handling

The system handles these common errors:
- **Not Authenticated**: User isn't signed into iCloud
- **Username Taken**: Chosen username already exists
- **Already Following**: Attempt to follow same user twice
- **User Not Found**: Invalid user ID or deleted account

## Testing

To test social features:
1. Use multiple iOS Simulators with different iCloud accounts
2. Or use a real device with a different iCloud account
3. Create profiles on both accounts
4. Search for and add each other as friends
5. Share workouts and verify they appear in feeds

## Performance Considerations

- **Lazy Loading**: Friend lists and feeds load on demand
- **Pagination**: Large result sets are limited (configurable in SocialService)
- **Pull to Refresh**: Manual refresh for latest data
- **Local Caching**: Friend data is cached in @Observable properties

## Troubleshooting

**Can't see friend requests:**
- Make sure both users have enabled iCloud
- Check that CloudKit permissions are set correctly
- Verify the followerID/followingID match actual user IDs

**Workouts not appearing in feed:**
- Confirm the workout was shared (not just saved locally)
- Check that you're friends with the user (relationship status = .accepted)
- Pull down to refresh the feed

**Search not working:**
- Ensure usernames and displayNames are marked as Queryable in CloudKit
- Check for typos in search query
- Verify CloudKit container is properly configured
