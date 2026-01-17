# Social Features - Implementation Roadmap

## ✅ **Phase 1: Privacy Controls (COMPLETE)**

### **What We Built:**

1. **SocialPrivacySettings.swift**
   - Complete privacy model with Codable support
   - 3 preset options: Public, Friends Only, Private
   - Granular controls for:
     - Profile visibility
     - Stats visibility
     - Workout sharing preferences
     - Social interactions
   - Persists to UserDefaults

2. **SocialPrivacySettingsView.swift**
   - Beautiful UI with Form-based settings
   - Quick preset selection sheet
   - Privacy summary card
   - Live preview of what others can see
   - Accessible from:
     - Settings → Social Privacy
     - Friends tab → ⋯ menu → Privacy Settings

3. **Integration:**
   - Added privacy button to FriendsView toolbar
   - Added to SettingsView main menu
   - Searchable (keywords: "Social Privacy Friends")

---

## 🔄 **Phase 2: Complete Following System (NEXT)**

### **What Needs to Be Done:**

#### **2.1 Update SocialService for Privacy-Aware Queries**

```swift
// In SocialService.swift

// Add privacy settings property
@Published var privacySettings: SocialPrivacySettings = .load()

// Update createUserProfile to include privacy
// Update fetchCurrentUserProfile to respect privacy
// Add privacy filtering to all queries
```

#### **2.2 Fix Following/Friend Requests**

Currently broken/incomplete:
- `sendFriendRequest()` - Works but needs privacy check
- `acceptFriendRequest()` - Needs implementation
- `fetchFriendRequests()` - Needs privacy filtering
- `fetchFriends()` - Needs privacy filtering

**Changes Needed:**
```swift
// 1. Check privacy before allowing follow
func sendFriendRequest(to userID: String) async throws {
    // Check target user's privacy settings
    // If .nobody - throw error
    // If .approvalRequired - create pending request
    // If .everyone - auto-accept
}

// 2. Filter friend requests by privacy
func fetchFriendRequests() async {
    // Only show requests if privacy allows
    // Filter by whoCanFollow setting
}

// 3. Respect privacy in friend list
func fetchFriends() async {
    // Filter based on profileVisibility
}
```

---

## 🔄 **Phase 3: Workout Sharing Integration (NEXT)**

### **What Needs to Be Done:**

#### **3.1 Auto-Share on Completion**

**In ContentView.swift:**
```swift
func toggleCompleted(_ workout: Workout) {
    workout.isCompleted.toggle()
    
    if workout.isCompleted {
        // Existing HealthKit save...
        
        // NEW: Auto-share if enabled
        if privacySettings.autoShareWorkouts {
            Task {
                try? await socialService.shareWorkout(workout)
            }
        }
    }
    
    // Haptic feedback...
}
```

#### **3.2 Manual Share from WorkoutDetailView**

Already has the button! Just needs privacy integration:

```swift
// In WorkoutDetailView.swift
// The "Share to Friends" button exists
// Just update shareToFriends() to respect privacy:

func shareToFriends() {
    let settings = SocialPrivacySettings.load()
    
    // Create PublicWorkout with privacy-filtered data
    let publicWorkout = PublicWorkout(
        userID: currentUserID,
        workoutName: workout.name,
        date: workout.date,
        totalVolume: settings.showTotalVolume ? workout.totalVolume : 0,
        exerciseCount: settings.showExerciseNames ? workout.sets.count : 0,
        isCompleted: workout.isCompleted
    )
    
    // Share via SocialService
}
```

#### **3.3 Privacy-Filtered Feed**

**In FriendsView.swift:**
```swift
// Update WorkoutFeedRow to respect privacy
// Hide details based on poster's privacy settings
// Show placeholder text for hidden data
```

---

## 🔄 **Phase 4: User Discovery (NEXT)**

### **What Needs to Be Done:**

#### **4.1 Privacy-Aware Search**

```swift
// In SocialService.swift
func searchUsers(query: String) async throws -> [UserProfile] {
    // Only return users with profileVisibility = .everyone
    // Or .friendsOnly if you're friends
    // Skip users with .nobody
}
```

#### **4.2 Suggested Users**

```swift
func fetchSuggestedUsers() async {
    // Filter by privacy settings
    // Only show public profiles
    // Exclude users who have whoCanFollow = .nobody
}
```

---

## 🔄 **Phase 5: Feed Improvements (LATER)**

### **Features to Add:**

1. **Reactions** (if privacy allows)
   - Like/💪/🔥 buttons
   - Respect `allowWorkoutReactions` setting

2. **Comments** (if privacy allows)
   - Simple comment system
   - Respect `allowComments` setting

3. **Real-time Updates**
   - CloudKit subscriptions
   - Push notifications

---

## 📋 **Implementation Checklist**

### **Week 1: Core Functionality**
- [ ] Update SocialService with privacy integration
- [ ] Fix following/friend request system
- [ ] Test on real device with CloudKit
- [ ] Privacy filtering in all queries

### **Week 2: Workout Sharing**
- [ ] Implement auto-share on completion
- [ ] Fix manual share from detail view
- [ ] Privacy-filtered feed display
- [ ] Test sharing with different privacy levels

### **Week 3: Polish & Testing**
- [ ] User discovery with privacy
- [ ] Suggested users filtering
- [ ] Edge case testing
- [ ] Multi-user testing (2+ devices)
- [ ] Performance optimization

### **Week 4: Final Testing**
- [ ] TestFlight beta
- [ ] Bug fixes
- [ ] Documentation
- [ ] App Store submission

---

## 🎯 **Priority Order**

1. **HIGHEST:** Privacy-aware queries (Phase 2.1)
2. **HIGH:** Following system (Phase 2.2)
3. **HIGH:** Workout sharing (Phase 3)
4. **MEDIUM:** User discovery (Phase 4)
5. **LOW:** Reactions/Comments (Phase 5)

---

## 🧪 **Testing Strategy**

### **Test Scenarios:**

1. **Public User:**
   - Set privacy to Public
   - Share workout
   - Verify everything visible

2. **Friends Only User:**
   - Set privacy to Friends Only
   - Share workout
   - Verify only friends can see
   - Verify strangers can't see

3. **Private User:**
   - Set privacy to Private
   - Profile should be hidden
   - Can't be followed
   - Workouts not shared

4. **Mixed Scenarios:**
   - Public user follows Private user (should fail)
   - Friends Only user shares workout (only friends see)
   - User changes privacy mid-session (updates immediately)

---

## 📝 **Code Files to Modify**

| File | Changes Needed | Priority |
|------|----------------|----------|
| `SocialService.swift` | Privacy integration | 🔴 High |
| `ContentView.swift` | Auto-share on complete | 🟡 Medium |
| `WorkoutDetailView.swift` | Manual share with privacy | 🟡 Medium |
| `FriendsView.swift` | Privacy-filtered feed | 🟡 Medium |
| `UserProfileView.swift` | Respect privacy settings | 🟢 Low |

---

## 🚀 **Next Steps**

**Start with Phase 2.1:**
1. Add `privacySettings` to SocialService
2. Update all CloudKit queries to filter by privacy
3. Test with different privacy presets
4. Move to Phase 2.2 (Following system)

**Timeline:** 2-3 weeks for full completion

**Goal:** Have complete, privacy-respecting social features ready for App Store release ~Feb 1

---

## 💡 **Notes**

- Privacy controls are **already complete** ✅
- Foundation is solid (models, UI, CloudKit)
- Main work is integrating privacy into existing code
- Most changes are small, incremental updates
- Testing is the time-consuming part

**You're ~30% done with social features. Remaining 70% is integration & testing.**
