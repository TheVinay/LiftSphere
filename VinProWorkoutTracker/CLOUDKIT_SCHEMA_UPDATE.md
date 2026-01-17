# 🔧 CloudKit Schema Update for Privacy Settings

## ⚠️ CRITICAL: Update CloudKit Schema Before Release

You've added 7 new privacy fields to `UserProfile`. You **MUST** update the CloudKit schema to support these fields.

---

## 📋 New Fields Added to UserProfile

| Field Name | Type | Default | Description |
|------------|------|---------|-------------|
| `profileVisibility` | String | "friendsOnly" | "everyone", "friendsOnly", or "nobody" |
| `showWorkoutCount` | Int64 | 1 | Show total workout count (0/1) |
| `showTotalVolume` | Int64 | 1 | Show total volume lifted (0/1) |
| `showExerciseNames` | Int64 | 1 | Show exercise names in shared workouts (0/1) |
| `showSetDetails` | Int64 | 0 | Show weight/reps in shared workouts (0/1) |
| `whoCanFollow` | String | "everyone" | "everyone", "approvalRequired", or "nobody" |
| `autoShareWorkouts` | Int64 | 0 | Auto-share completed workouts (0/1) |

---

## 🚀 Option 1: CloudKit Dashboard (Recommended)

### Step-by-Step:

1. **Open CloudKit Dashboard**
   - Go to: https://icloud.developer.apple.com/dashboard
   - Sign in with your Apple ID
   - Select your app: `iCloud.com.vinay.VinProWorkoutTracker`

2. **Navigate to Schema**
   - Click "Schema" in the left sidebar
   - Select "Development" environment (test first!)
   - Find "UserProfile" record type

3. **Add Each Field**
   - Click "Add Field" button
   - For each field above:
     - Enter field name (exact match)
     - Select type (String or Int64)
     - Click "Save"

4. **Create Indexes (Important for queries)**
   - Click "Indexes" tab
   - Add index for `profileVisibility` (queryable)
   - Add index for `whoCanFollow` (queryable)

5. **Deploy to Production**
   - After testing, go to "Schema" → "Deploy to Production"
   - This makes changes permanent

---

## 🔧 Option 2: Automatic Schema Creation (Testing Only)

CloudKit can auto-create fields when you first save a record, but this is **NOT recommended for production**.

### If you want to test quickly:

1. Run your app on a device (simulator won't work)
2. Create a new profile
3. CloudKit will auto-create the fields
4. **DANGER:** This can cause issues if field types are wrong

---

## ✅ Verify Schema is Updated

### Test Checklist:

1. **Create a test profile**
   ```swift
   // In your app, sign in and create profile
   // Check CloudKit Dashboard → Data → UserProfile
   // Verify all privacy fields exist
   ```

2. **Update privacy settings**
   ```swift
   // Go to Settings → Social Privacy
   // Change settings
   // Save
   // Check CloudKit Dashboard to see fields updated
   ```

3. **Test privacy enforcement**
   ```swift
   // Set profile to "Nobody can follow"
   // Try to follow yourself from another account
   // Should get error: "This user's privacy settings don't allow followers"
   ```

---

## 🐛 Troubleshooting

### "Field not found" errors?
- Schema not updated yet
- Run through Option 1 above

### Privacy settings not syncing?
- Check CloudKit Dashboard → Logs
- Look for errors saving UserProfile records
- Verify field types match (String vs Int64)

### Old profiles missing privacy fields?
- They'll use defaults automatically
- No migration needed!
- UserProfile init handles missing fields gracefully

---

## 📝 Record Type Definitions (for reference)

### UserProfile
```
Record Type: UserProfile

Fields:
- appleUserID: String (indexed)
- username: String (indexed, unique)
- displayName: String
- bio: String
- avatarURL: String (optional)
- createdDate: Date/Time
- isPublic: Int64 (0 or 1)
- totalWorkouts: Int64
- totalVolume: Double

NEW Privacy Fields:
- profileVisibility: String (indexed)
- showWorkoutCount: Int64
- showTotalVolume: Int64
- showExerciseNames: Int64
- showSetDetails: Int64
- whoCanFollow: String (indexed)
- autoShareWorkouts: Int64

Indexes:
- appleUserID (queryable, unique)
- username (queryable, unique)
- profileVisibility (queryable)
- whoCanFollow (queryable)
```

---

## 🎯 Next Steps After Schema Update

1. ✅ Update CloudKit schema (this document)
2. ✅ Add auto-share to ContentView (see AUTO_SHARE_INTEGRATION.md)
3. ✅ Test on real device
4. ✅ TestFlight beta
5. 🚀 Release!

---

**Estimated time:** 15-20 minutes to update schema  
**Must do before:** Tonight's release (CRITICAL!)
