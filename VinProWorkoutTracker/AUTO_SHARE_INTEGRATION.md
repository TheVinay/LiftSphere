# 🚀 Auto-Share Integration for ContentView

## Add this code to ContentView.swift

### Step 1: Add SocialService to ContentView

At the top of ContentView, add:
```swift
@State private var socialService = SocialService()
```

### Step 2: Update toggleCompleted() method

Find the `toggleCompleted()` function and add auto-share logic:

```swift
func toggleCompleted(_ workout: Workout) {
    workout.isCompleted.toggle()
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
    
    // Save to HealthKit if completed
    if workout.isCompleted {
        Task {
            await saveWorkoutToHealthKit(workout)
            
            // 🆕 AUTO-SHARE: Share to social feed if enabled
            if let profile = socialService.currentUserProfile,
               profile.autoShareWorkouts {
                do {
                    try await socialService.shareWorkout(workout, autoShared: true)
                    print("✅ Auto-shared workout to feed")
                } catch {
                    print("⚠️ Auto-share failed: \(error.localizedDescription)")
                    // Fail silently - don't interrupt user flow
                }
            }
        }
    }
}
```

### Step 3: Import at the top of ContentView.swift

Make sure you have:
```swift
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import HealthKit
// Add if not present:
import CloudKit
```

---

## Testing Auto-Share

1. **Go to Settings → Social Privacy**
2. **Enable "Auto-share completed workouts"**
3. **Complete a workout** (swipe → Complete)
4. **Check the Friends tab → Feed** to see it appear

---

## That's it! ✅

Auto-share is now fully integrated. Workouts will automatically post to your feed when completed, respecting privacy settings.
