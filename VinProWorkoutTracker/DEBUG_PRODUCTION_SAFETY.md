# Debug Output & Production Safety

**Date:** January 20, 2026

## Summary

All debug logging is now wrapped in `#if DEBUG` blocks, which means:
- ✅ **Development builds** (Xcode debug): Full verbose logging
- ✅ **Production builds** (App Store/TestFlight): NO debug output
- ✅ **Error messages** still logged (not wrapped, important for crash reports)

---

## How `#if DEBUG` Works

### What It Does:
```swift
#if DEBUG
print("🔍 This only prints in debug builds")
#endif
```

- Xcode automatically defines `DEBUG` flag when building in **Debug** configuration
- **Release** builds (App Store, TestFlight) use **Release** configuration
- Code inside `#if DEBUG` is **completely removed** from Release builds (not even compiled!)

### Why It's Safe:
1. **Zero performance impact** in production (code doesn't exist)
2. **Zero log noise** for real users
3. **Binary size reduction** (less code = smaller app)
4. **Security** (doesn't leak internal logic to users)

---

## What's Protected Now

### SocialService.swift

#### `searchUsers()` function:
- ✅ Query details (what you're searching for)
- ✅ CloudKit result counts
- ✅ Every record's username, isPublic, profileVisibility
- ✅ Filter decision reasons ("ADDED" vs "FILTERED OUT")
- ❌ **NOT wrapped:** Error messages (important for diagnostics)

#### `fetchSuggestedUsers()` function:
- ✅ Current user info
- ✅ CloudKit result counts
- ✅ Following counts
- ✅ Record details
- ✅ Filter decisions
- ❌ **NOT wrapped:** Actual error objects (for crash reporting)

### What Still Logs in Production:
```swift
print("❌ Error fetching suggested users: \(error)")
```
This is intentional! If CloudKit fails in production, you want to know about it via:
- Firebase Crashlytics
- Apple Crash Reports
- User feedback

---

## How to Verify

### Test 1: Debug Build (Development)
1. In Xcode: Product → Scheme → Edit Scheme
2. Run → Build Configuration → **Debug** ✅
3. Run app → Console shows all 🔍 logs

### Test 2: Release Build (App Store Simulation)
1. In Xcode: Product → Scheme → Edit Scheme
2. Run → Build Configuration → **Release** ✅
3. Run app → Console shows **NO** 🔍 logs
4. Console only shows errors (if any occur)

### Test 3: Archive (Real App Store Build)
1. Product → Archive
2. This always uses **Release** configuration
3. No debug logs will be in the final .ipa

---

## Additional DEBUG-Only Code

You also have `#if DEBUG` in several other places:

### FriendsView.swift (Toolbar Menu)
```swift
#if DEBUG
Divider()

Button(role: .destructive) {
    Task {
        try? await socialService.deleteCurrentUserProfile()
    }
} label: {
    Label("Delete My Profile", systemImage: "trash")
}

Button {
    Task {
        try? await socialService.cleanupOrphanedProfiles()
    }
} label: {
    Label("Cleanup Old Profiles", systemImage: "trash.slash")
}
// ... etc
#endif
```
These admin/debug buttons **won't appear** in App Store builds! ✅

### SocialService.swift (Debug Methods)
```swift
#if DEBUG
/// Deletes the current user's profile from CloudKit (DEBUG only)
func deleteCurrentUserProfile() async throws {
    // ...
}

func cleanupOrphanedProfiles() async throws {
    // ...
}
#endif
```
These dangerous methods **won't exist** in production! ✅

---

## Best Practices

### ✅ DO Wrap in `#if DEBUG`:
- Detailed logging (🔍 emoji logs)
- Internal state dumps
- Debug-only features (delete profile, clear cache)
- Performance measurements
- Test data

### ❌ DON'T Wrap:
- Error logging (need this for crash reports!)
- Analytics events
- User-facing error messages
- Critical warnings

### Example:
```swift
do {
    let data = try await fetchData()
    #if DEBUG
    print("✅ Fetched \(data.count) items")  // Debug only
    #endif
} catch {
    print("❌ Fetch failed: \(error)")  // Always logged (production too)
    #if DEBUG
    print("   Full error: \(error.localizedDescription)")  // Extra detail for dev
    #endif
}
```

---

## Your `whoCanFollow` Question

### How It Works:
`whoCanFollow` controls **who can follow you**, NOT **who can find you**:

- **Search/Discover:** Only checks `isPublic` and `profileVisibility`
- **Follow Action:** Then checks `whoCanFollow`

### Flow Example:
1. User searches "josh" → ✅ Josh appears (public profile)
2. User taps "Follow" button → Checks Josh's `whoCanFollow` setting:
   - `"everyone"` → ✅ Instant follow
   - `"approvalRequired"` → ⚠️ Sends request, waits for approval
   - `"nobody"` → ❌ Error: "This user doesn't allow followers"

### So:
- `profileVisibility` = "Can others **SEE** my profile?"
- `whoCanFollow` = "Can others **FOLLOW** me?"

You can have:
- **Public profile** but **require approval** to follow (Instagram private account style)
- **Public profile** with **instant follow** (Twitter/X style)
- **Private profile** (completely hidden from search)

---

## App Store Checklist

Before submitting:

- [ ] Build Configuration set to **Release**
- [ ] Archive the app (Product → Archive)
- [ ] Upload to App Store Connect
- [ ] Test on TestFlight (uses Release build)
- [ ] Verify no debug logs appear in device console
- [ ] Verify no debug menu items visible in app

Debug code **automatically** removed - no manual changes needed! ✅

---

## Console in Production

### What Users See:
- Nothing! (unless they connect device to Mac with Xcode)

### What You See (if user sends crash report):
- Error messages (not wrapped in `#if DEBUG`)
- Crash stack traces
- OS-level logs

### What You WON'T See:
- Any 🔍 debug logs
- Filter decision logs
- CloudKit record dumps
- "Processing result X..." messages

All safe! 🎉
