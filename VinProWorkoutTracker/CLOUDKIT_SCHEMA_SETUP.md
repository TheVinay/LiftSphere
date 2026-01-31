# CloudKit Schema Setup Guide

**Issue:** "Error: did not find record type: followrelationship"

**Date:** January 31, 2026

---

## Problem

The error appears when searching for users because the app tries to load your following list on startup, but the `FollowRelationship` record type doesn't exist in CloudKit yet.

## Solution: Create CloudKit Record Types

You need to create the following record types in your CloudKit schema:

### 1. UserProfile (Probably already exists)
- `appleUserID` - String - **Indexed (Queryable & Sortable)**
- `username` - String - **Indexed (Queryable & Sortable)**
- `displayName` - String - **Indexed (Queryable)**
- `bio` - String
- `avatarURL` - String
- `createdDate` - Date/Time
- `isPublic` - Int64 - **Indexed (Queryable)**
- `totalWorkouts` - Int64 - **Indexed (Sortable)**
- `totalVolume` - Double
- `profileVisibility` - String
- `showWorkoutCount` - Int64
- `showTotalVolume` - Int64
- `showExerciseNames` - Int64
- `showSetDetails` - Int64
- `whoCanFollow` - String
- `autoShareWorkouts` - Int64

### 2. FollowRelationship (MISSING - THIS IS THE ISSUE!)
- `followerID` - String - **Indexed (Queryable)**
- `followingID` - String - **Indexed (Queryable)**
- `followedAt` - Date/Time

### 3. PublicWorkout (Optional, for activity feed)
- `userID` - String - **Indexed (Queryable)**
- `workoutName` - String
- `date` - Date/Time - **Indexed (Sortable)**
- `totalVolume` - Double
- `exerciseCount` - Int64
- `isCompleted` - Int64

---

## Step-by-Step: Create FollowRelationship Record Type

### Option 1: CloudKit Dashboard (Recommended)

1. **Go to CloudKit Dashboard**
   - Visit: https://icloud.developer.apple.com/dashboard/
   - Sign in with your Apple Developer account

2. **Select Your Container**
   - Choose: `iCloud.com.vinay.VinProWorkoutTracker`

3. **Navigate to Schema**
   - Click **"Schema"** in the left sidebar
   - Select **"Record Types"**

4. **Create New Record Type**
   - Click the **"+"** button (top right)
   - Enter name: `FollowRelationship` (case-sensitive!)
   - Click **"Create"**

5. **Add Fields**
   Click **"Add Field"** for each:
   
   **Field 1: followerID**
   - Field Name: `followerID`
   - Field Type: `String`
   - Index: ✅ **Queryable**
   - Click **"Save Field"**
   
   **Field 2: followingID**
   - Field Name: `followingID`
   - Field Type: `String`
   - Index: ✅ **Queryable**
   - Click **"Save Field"**
   
   **Field 3: followedAt**
   - Field Name: `followedAt`
   - Field Type: `Date/Time`
   - Index: (Optional - for sorting)
   - Click **"Save Field"**

6. **Save Record Type**
   - Click **"Save"** (bottom right)

7. **Deploy to Production**
   - Click **"Deploy Schema Changes"** at the top
   - Select **"Development"** → **"Production"**
   - Confirm deployment
   - Wait for deployment to complete (~30 seconds)

8. **Verify**
   - Go to **Data → Public Database**
   - You should now see `FollowRelationship` in the dropdown

---

### Option 2: Let App Create It Automatically

The record type will be automatically created the **first time** someone tries to follow another user. However, this causes errors during initial loads.

**To trigger automatic creation:**
1. Make sure the code changes I made are in place (error handling)
2. Have two user profiles created
3. Try to follow one user from another account
4. The record type will be created automatically

**Downside:** You'll see errors until the first follow relationship is created.

---

## Code Changes Made

I've updated `SocialService.swift` to handle the missing record type gracefully:

### 1. `fetchFollowing()` - Better Error Handling
```swift
catch let error as CKError where error.code == .unknownItem {
    // Record type doesn't exist yet - this is expected on first run
    print("ℹ️ FollowRelationship record type not created yet")
    self.friends = []
    self.errorMessage = nil // Don't show error
}
```

### 2. `followUser()` - Auto-Create on First Use
```swift
do {
    let record = relationship.toCKRecord()
    try await publicDatabase.save(record)
    // This will create the record type automatically if it doesn't exist
}
```

### 3. `unfollowUser()` - Handle Missing Type
```swift
catch let error as CKError where error.code == .unknownItem {
    // Record type doesn't exist - you're not following anyone anyway
    print("ℹ️ FollowRelationship record type doesn't exist yet")
}
```

---

## Testing After Setup

### 1. Verify Record Type Exists
1. CloudKit Dashboard → Data → Public Database
2. Select "FollowRelationship" from dropdown
3. Should show "No records found" (not "Record type not found")

### 2. Test Search Functionality
1. Open app on physical device
2. Navigate to **Friends** tab
3. Tap **"Discover"** - should show users without errors
4. Use **search bar** - should search without errors

### 3. Test Following
1. Find a user in Discover or Search
2. Tap to view their profile
3. Tap **"Follow"** button
4. Should succeed without errors
5. Go to **"Friends"** tab → should show the user

### 4. Verify in CloudKit
1. CloudKit Dashboard → Data → Public Database
2. Select "FollowRelationship"
3. Run query: `TRUEPREDICATE`
4. Should see your follow relationship record

---

## Common Issues

### Issue: "Permission denied" when creating record type
**Solution:** 
- Make sure you're signed in with the Apple Developer account that owns this app
- Check that you have Admin access to the CloudKit container

### Issue: "Cannot deploy to production"
**Solution:**
- Development and Production are separate environments
- You must deploy schema changes from Development → Production
- Once deployed, you can't easily remove fields (only add new ones)

### Issue: Records still not working after creating type
**Solution:**
1. Make sure indexes are enabled on `followerID` and `followingID`
2. Wait 30-60 seconds for CloudKit to sync
3. Force-close and reopen the app
4. Clear app cache: Friends tab → ⋯ menu → "Clear Local Cache"

### Issue: Works in Development, not in Production
**Solution:**
- You need to deploy schema changes to Production
- CloudKit Dashboard → Deploy Schema Changes button
- Select "Development to Production"

---

## Understanding the Error

The error message:
```
Error: did not find record type: followrelationship
```

This means:
1. Your app tried to query CloudKit for `FollowRelationship` records
2. CloudKit checked the schema
3. No record type named `FollowRelationship` exists
4. CloudKit returned an error
5. The error propagated to the UI, breaking search

**Why it affects search:**
- When you open Friends tab, app loads following list
- This queries `FollowRelationship` record type
- Query fails with "record type not found"
- Error message is stored in `SocialService.errorMessage`
- UI shows this error even when you're trying to search

**After the fix:**
- Missing record type is treated as "you're not following anyone yet"
- No error message is shown
- Search and Discover work normally
- Once you follow someone, records are created

---

## Summary

**Before:** 
- App crashes or shows errors when loading Friends tab
- Search shows "No users found" with error message
- Following functionality doesn't work

**After:**
- App handles missing record type gracefully
- Search and Discover work correctly
- Following creates the record type automatically (or you create it manually)
- No more error messages

**Recommended approach:**
1. ✅ Create `FollowRelationship` manually in CloudKit Dashboard (5 minutes)
2. ✅ Deploy to Production
3. ✅ Test search and following functionality
4. ✅ Verify records appear in CloudKit Dashboard

---

## Next Steps

After setting up the schema:

1. **Test on a real device** (CloudKit doesn't work well in simulator)
2. **Create multiple test accounts** to test following
3. **Verify privacy settings** work correctly
4. **Check that feed updates** when following users share workouts

Need help? Check the console logs for detailed debugging information prefixed with 🔍.
