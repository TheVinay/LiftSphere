# Social Features - Quick Start Guide

## What Was Added

Your VinPro Workout Tracker now has complete social networking features! Here's what's new:

### 📱 New Views Created

1. **FriendsView.swift** - Main social hub with 3 tabs:
   - Friends: See your friend list and accept requests
   - Feed: View friends' workouts in real-time
   - Discover: Find new users to follow

2. **ProfileSetupView.swift** - Onboarding for creating your social profile

3. **UserProfileView.swift** - Detailed profile pages for viewing any user

4. **SocialService.swift** - CloudKit backend service managing all social features

5. **SocialShareComponents.swift** - Reusable components for sharing workouts

### 🔧 Modified Files

- **WorkoutDetailView.swift** - Added "Share to Friends" button in the menu
- **RootTabView.swift** - Already includes FriendsView tab (no changes needed)

### 📊 Data Models (Already Existed)

- **SocialModels.swift** - Contains UserProfile, FriendRelationship, PublicWorkout

## Getting Started

### Step 1: Enable CloudKit

1. Open your project in Xcode
2. Select your project target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "iCloud"
6. Check the "CloudKit" checkbox
7. Make sure your container is created (it should auto-generate)

### Step 2: Configure CloudKit Schema

Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard) and add these record types to your **Public Database**:

#### UserProfile Record Type
| Field Name | Type | Indexed | Sortable |
|------------|------|---------|----------|
| username | String | Yes | Yes |
| displayName | String | Yes | No |
| bio | String | No | No |
| avatarURL | String | No | No |
| createdDate | Date/Time | No | Yes |
| isPublic | Int(64) | Yes | No |
| totalWorkouts | Int(64) | No | Yes |
| totalVolume | Double | No | Yes |

#### FriendRelationship Record Type
| Field Name | Type | Indexed | Sortable |
|------------|------|---------|----------|
| followerID | String | Yes | No |
| followingID | String | Yes | No |
| createdDate | Date/Time | No | Yes |
| status | String | Yes | No |

#### PublicWorkout Record Type
| Field Name | Type | Indexed | Sortable |
|------------|------|---------|----------|
| userID | String | Yes | No |
| workoutName | String | No | No |
| date | Date/Time | No | Yes |
| totalVolume | Double | No | Yes |
| exerciseCount | Int(64) | No | No |
| isCompleted | Int(64) | No | No |

### Step 3: Set Permissions

For each record type in CloudKit Dashboard:
1. Click on the record type
2. Go to "Security Roles"
3. Set these permissions:
   - **World**: Read
   - **Authenticated**: Create, Write

### Step 4: Test the Features

1. Run your app
2. Go to the Friends tab
3. Tap "Create Profile"
4. Fill in your username and display name
5. Explore the three tabs:
   - **Friends**: Manage your connections
   - **Feed**: See friend activity
   - **Discover**: Find new users

## Key Features Explained

### Creating a Profile
```swift
// Handled automatically by ProfileSetupView
// User provides:
// - username (unique, 3+ chars)
// - displayName
// - bio (optional)
```

### Finding Friends
```swift
// In FriendsView, use the search bar
// Search by username or display name
// Tap a user to view their profile
// Tap "Add Friend" to send a request
```

### Sharing Workouts
```swift
// From any workout:
// 1. Tap ••• menu
// 2. Select "Share to Friends"
// 3. Confirm sharing
// Your friends will see it in their Feed!
```

### Viewing Friend Activity
```swift
// Go to Friends tab > Feed
// See all recent workouts from friends
// Pull down to refresh
// Each workout shows:
// - User who posted it
// - Workout name and date
// - Exercise count and total volume
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│          RootTabView                    │
│  (Main App Container)                   │
└─────────────┬───────────────────────────┘
              │
              ├── ProfileView
              ├── ContentView (Workouts)
              ├── AnalyticsView
              ├── FriendsView ←── NEW SOCIAL HUB
              └── LearnView
                    │
                    ├── Friends Tab
                    │   └── Lists friends & requests
                    │
                    ├── Feed Tab
                    │   └── Shows friend workouts
                    │
                    └── Discover Tab
                        └── Suggests new users
```

## Code Examples

### Accessing Social Service
```swift
@State private var socialService = SocialService()

// Fetch current user profile
try await socialService.fetchCurrentUserProfile()

// Search for users
let results = try await socialService.searchUsers(query: "john")

// Send friend request
try await socialService.sendFriendRequest(to: userID)

// Share a workout
try await socialService.shareWorkout(workout)
```

### Using the Share Button Component
```swift
import SwiftUI

ShareToFriendsButton(workout: myWorkout)
    .buttonStyle(.borderedProminent)
```

### Adding Social Sharing to Any View
```swift
YourView()
    .socialShare(for: workout)
```

## API Reference

### SocialService Methods

#### Profile Management
- `checkAuthentication() async throws -> Bool`
- `createUserProfile(username:displayName:bio:) async throws`
- `fetchCurrentUserProfile() async throws`
- `updateUserProfile(displayName:bio:totalWorkouts:totalVolume:) async throws`

#### Friend Management
- `searchUsers(query:) async throws -> [UserProfile]`
- `sendFriendRequest(to:) async throws`
- `acceptFriendRequest(relationshipID:) async throws`
- `removeFriend(userID:) async throws`
- `fetchFriends() async`
- `fetchFriendRequests() async`
- `fetchSuggestedUsers() async`

#### Workout Sharing
- `shareWorkout(_:) async throws`
- `fetchFriendWorkouts() async`

## Troubleshooting

### "Cannot find 'FriendsView' in scope"
✅ Fixed! FriendsView.swift has been created.

### "User not authenticated"
- Make sure you're signed into iCloud on your device/simulator
- Go to Settings > [Your Name] and verify you're signed in
- Check that iCloud Drive is enabled

### "CloudKit errors"
- Verify you've added the iCloud capability
- Check that CloudKit is enabled in capabilities
- Make sure record types are created in CloudKit Dashboard
- Verify permissions are set correctly

### "Can't find users"
- Make sure both users have created profiles
- Check that usernames are spelled correctly
- Verify the username and displayName fields are indexed in CloudKit

### "Workouts not appearing in feed"
- Ensure you've shared the workout (not just saved it)
- Check that you're friends with the user
- Pull down to refresh the feed
- Verify the workout is marked as completed

## Privacy Notes

- All social data is stored in CloudKit's **public database**
- Users must be signed into iCloud to use social features
- Only workout summaries are shared (name, date, volume, exercise count)
- Detailed set-by-set data remains private in SwiftData
- Users can control their profile visibility with the `isPublic` flag

## Next Steps

Consider adding these enhancements:
- Push notifications for friend requests
- Workout comments and likes
- Profile photos using CloudKit Assets
- Activity badges and achievements
- Group challenges
- Custom workout templates sharing
- Direct messaging
- Workout streaks tracking
- Privacy settings per workout

## Testing Checklist

- [ ] Enable iCloud capability
- [ ] Create CloudKit record types
- [ ] Set proper permissions
- [ ] Create a profile
- [ ] Search for a user
- [ ] Send a friend request (use 2 devices/simulators)
- [ ] Accept a friend request
- [ ] Share a workout
- [ ] View workout in friend's feed
- [ ] View user profile
- [ ] Remove a friend

## Support

For more detailed information, see:
- **SOCIAL_FEATURES.md** - Complete technical documentation
- **SocialModels.swift** - Data structure definitions
- **SocialService.swift** - Implementation details

---

**Built with**: SwiftUI, Swift Concurrency, CloudKit, Swift Data
**Platforms**: iOS 17+
**Features**: User profiles, friend system, workout sharing, activity feed
