# Debug Guide - User Search Not Working

**Date:** January 20, 2026  
**Status:** Enhanced debugging added  
**Your Report:** Database shows `isPublic=1` and `profileVisibility=everyone`, but search for "josh" returns nothing

---

## What I Just Added

### 1. **Comprehensive Console Logging** 📝
Both search functions now print detailed debug info:

**For Search Bar (`searchUsers`):**
```
🔍 ========== SEARCH USERS DEBUG ==========
🔍 Query: 'josh'
🔍 Current user: <your username>
🔍 Executing CloudKit query...
🔍 CloudKit returned X raw results
🔍 Processing result 1...
   ✅ Got record: <record ID>
   - username: josh
   - displayName: Josh
   - isPublic: 1
   - profileVisibility: everyone
   ✅ Parsed profile successfully
   - Is self: false
   - Is public: true
   - Visibility: 'everyone' (OK: true)
   ✅ ADDED TO RESULTS
✅ Found 1 users matching 'josh' (privacy-filtered)
```

**For Discover Tab (`fetchSuggestedUsers`):**
```
🔍 ========== FETCH SUGGESTED USERS DEBUG ==========
🔍 Current user: <your username>
🔍 Executing CloudKit query for suggested users...
🔍 CloudKit returned X raw results
<similar detailed output>
```

### 2. **Visual Error Display** 🔴
- Discover tab now shows error messages if CloudKit fails
- Search results show "No users found" with error details
- Added "Retry" button on Discover tab

### 3. **Better Search Overlay** 🔍
- Search results now show even when empty (so you can see errors)
- Shows "Searching..." with spinner while loading
- Shows "No users found" when search completes with no results

---

## How to Test (Step by Step)

### Test 1: Discover Tab
1. Open app on your **physical iPhone** (not simulator)
2. Navigate to **Friends tab** (bottom navigation)
3. Tap **"Discover"** at the top (segmented control)
4. Watch for:
   - Loading spinner
   - "No suggestions available" OR list of users
   - Red error message (if CloudKit fails)
5. **Pull down to refresh** and try again
6. **Check Xcode console** for debug output

### Test 2: Search Bar
1. Stay on Friends tab (any sub-tab: Friends/Feed/Discover)
2. Look for **search bar at the very top** (below navigation)
3. Tap search bar and type "**josh**"
4. Watch for:
   - "Searching..." message
   - Results list OR "No users found"
   - Red error message (if any)
5. **Check Xcode console** for detailed debug output

---

## Important: Search Bar vs Discover Tab

### Search Bar (Top of Screen) 🔍
- Uses `searchUsers()` function
- Searches by username OR display name
- Case-insensitive CONTAINS search
- Shows results in overlay

### Discover Tab (Segmented Control) 👥
- Uses `fetchSuggestedUsers()` function
- Shows ALL public users (sorted by workout count)
- Excludes yourself and people you follow
- Shows in main list

**Both should work!** If one works but not the other, it tells us which CloudKit query is failing.

---

## What to Look For in Console

### ✅ SUCCESS Pattern:
```
🔍 Query: 'josh'
🔍 CloudKit returned 1 raw results
   ✅ Got record: ABC123
   - username: josh
   - isPublic: 1
   - profileVisibility: everyone
   ✅ ADDED TO RESULTS
✅ Found 1 users matching 'josh'
```

### ❌ FAILURE Pattern 1 - No CloudKit Results:
```
🔍 Query: 'josh'
🔍 CloudKit returned 0 raw results
✅ Found 0 users matching 'josh'
```
**Means:** CloudKit query isn't finding the record at all
**Possible causes:**
- Username in database is NOT "josh" (check exact spelling)
- Record not in Public database (check container/database)
- CloudKit index not updated yet (wait 30 seconds)

### ❌ FAILURE Pattern 2 - Record Filtered Out:
```
🔍 CloudKit returned 1 raw results
   ✅ Got record: ABC123
   - isPublic: 0
   ❌ FILTERED OUT
```
**Means:** Record found but failed privacy filter
**Check:** `isPublic` should be integer `1`, not `0`

### ❌ FAILURE Pattern 3 - Parse Error:
```
🔍 CloudKit returned 1 raw results
   ✅ Got record: ABC123
   ❌ Could not parse profile from record
```
**Means:** Record is missing required fields
**Check:** Record must have `appleUserID`, `username`, `displayName`

### ❌ FAILURE Pattern 4 - CloudKit Error:
```
❌ Error fetching suggested users: <error message>
```
**Means:** CloudKit query failed entirely
**Possible causes:**
- Not signed in to iCloud
- Network error
- Container permission issue

---

## Quick Checks

### Check 1: iCloud Sign-In
On your iPhone:
1. Settings → [Your Name] at top
2. Should show your Apple ID email
3. Tap iCloud → should show LiftSphere in app list

### Check 2: CloudKit Dashboard
1. Go to https://icloud.developer.apple.com/dashboard/
2. Sign in with your Apple Developer account
3. Select container: `iCloud.com.vinay.VinProWorkoutTracker`
4. Go to: **Data → Public Database → UserProfile**
5. Run query: `TRUEPREDICATE` (shows all records)
6. Find the "josh" record and verify:
   - `username` field = "josh" (exact, case matters for database)
   - `isPublic` field = 1 (integer)
   - `profileVisibility` field = "everyone" (exact, lowercase)

### Check 3: Your Own Profile
1. In app, go to Profile tab (bottom left)
2. Check your display name shows (not "Guest User")
3. Tap ⋯ menu in Friends tab → "Clear Local Cache"
4. Force close app and reopen
5. Try search again

---

## Common Issues & Fixes

### Issue: "No suggestions available" on Discover
**Diagnosis:** Run these checks:
1. Is your phone signed in to iCloud? (Settings → [Name])
2. Do you have other test users in database? (Check CloudKit Dashboard)
3. Are those users `isPublic = 1`?
4. Check console for error message

**Fix:** 
- Ensure at least 2 different iCloud accounts have created profiles
- Make sure test profiles have `isPublic = 1`
- Try pull-to-refresh on Discover tab

### Issue: Search returns empty but Discover works
**Diagnosis:** Different CloudKit queries
- Discover queries: `isPublic == 1` (integer comparison)
- Search queries: `username CONTAINS[cd] "josh"` (text search)

**Fix:**
- Verify username field contains "josh" (case-insensitive)
- Check CloudKit indexes are enabled for username field

### Issue: Both return empty
**Diagnosis:** Likely CloudKit authentication or container issue

**Fix:**
1. Check Xcode console for error details
2. Use CloudKit Debug view in app:
   - Settings → Data & Sync → CloudKit Status
   - Tap "Run Full Diagnostics"
   - Look for red error messages
3. Verify container identifier matches: `iCloud.com.vinay.VinProWorkoutTracker`
4. Check Xcode entitlements file has correct container

---

## Next Steps

### Step 1: Run the App with Xcode Attached
1. Connect iPhone via cable
2. Select your device in Xcode
3. Run app (Cmd+R)
4. Open Console pane (Cmd+Shift+C)
5. Filter for "🔍" to see only search logs

### Step 2: Test Search
1. Navigate to Friends → Discover
2. Pull to refresh
3. **Copy the entire console output**
4. Navigate to Friends → use search bar
5. Type "josh"
6. **Copy the entire console output**

### Step 3: Share Results
Send me:
- Console output from Discover tab
- Console output from Search
- Screenshot of CloudKit Dashboard showing the "josh" record
- Screenshot of any error messages in the app

This will tell us EXACTLY what's going wrong! 🔍

---

## Expected Behavior (When Working)

### Discover Tab:
1. Shows loading spinner
2. Fetches all `isPublic = 1` profiles
3. Filters out yourself
4. Shows list sorted by workout count
5. Shows "josh" if:
   - `isPublic = 1`
   - Not your own profile
   - You're not already following them

### Search "josh":
1. Shows "Searching..." overlay
2. Queries CloudKit for username/displayName containing "josh"
3. Filters for:
   - `isPublic = true`
   - `profileVisibility != "nobody"`
   - Not yourself
4. Shows results in overlay list
5. Should find username "josh" OR displayName containing "josh"

---

## CloudKit Query Syntax (For Reference)

The app runs these queries:

**Discover:**
```
Record Type: UserProfile
Predicate: isPublic == 1
Sort: totalWorkouts (descending)
Limit: 20
```

**Search:**
```
Record Type: UserProfile
Predicate: username CONTAINS[cd] "josh" OR displayName CONTAINS[cd] "josh"
Limit: 20
```

`[cd]` means case-insensitive and diacritic-insensitive

---

## Summary

I've added extensive debugging so we can see exactly what's happening:
1. ✅ Detailed console logs for every step
2. ✅ Visual error messages in UI
3. ✅ Retry button on Discover tab
4. ✅ Better search overlay showing empty state

**Now run the app with Xcode console open and copy the output!** 📋
