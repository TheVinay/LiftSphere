# String Consistency Fix - Privacy Enum Values

**Date:** January 20, 2026  
**Issue:** Inconsistent use of capitalized vs lowercase strings for privacy settings

---

## The Problem

There was a mismatch between:
- **Enum raw values** (user-facing, capitalized): `"Everyone"`, `"Friends Only"`, `"Only Me"`
- **CloudKit storage values** (lowercase, camelCase): `"everyone"`, `"friendsOnly"`, `"nobody"`

This could cause:
- Comparison failures in search filters
- CloudKit query mismatches
- Hard-to-debug string comparison bugs

---

## The Solution

**Separate storage values from display values:**

### Storage (Raw Values) - lowercase, camelCase ✅
Used in:
- CloudKit database
- Code comparisons
- JSON encoding/decoding

```swift
enum Visibility: String, Codable, CaseIterable {
    case everyone = "everyone"           // Raw value for storage
    case friendsOnly = "friendsOnly"     // Raw value for storage
    case nobody = "nobody"               // Raw value for storage
    
    var displayName: String {            // Display value for UI
        switch self {
        case .everyone: return "Everyone"
        case .friendsOnly: return "Friends Only"
        case .nobody: return "Only Me"
        }
    }
}
```

### Display (displayName) - Capitalized, Human-Readable ✅
Used in:
- Picker UI
- Settings screens
- User-facing text

```swift
// In UI code
Label(visibility.displayName, systemImage: visibility.icon)  // Shows "Everyone"
```

---

## What Changed

### File 1: `SocialPrivacySettings.swift`

#### Visibility Enum:
```swift
// BEFORE
case everyone = "Everyone"
case friendsOnly = "Friends Only"
case nobody = "Only Me"

// AFTER
case everyone = "everyone"
case friendsOnly = "friendsOnly"
case nobody = "nobody"

var displayName: String {
    switch self {
    case .everyone: return "Everyone"
    case .friendsOnly: return "Friends Only"
    case .nobody: return "Only Me"
    }
}
```

#### FollowPermission Enum:
```swift
// BEFORE
case everyone = "Everyone"
case friendsOnly = "Friends of Friends"
case approvalRequired = "Approval Required"
case nobody = "No One"

// AFTER
case everyone = "everyone"
case friendsOnly = "friendsOnly"
case approvalRequired = "approvalRequired"
case nobody = "nobody"

var displayName: String {
    switch self {
    case .everyone: return "Everyone"
    case .friendsOnly: return "Friends of Friends"
    case .approvalRequired: return "Approval Required"
    case .nobody: return "No One"
    }
}
```

### File 2: `SocialPrivacySettingsView.swift`

```swift
// BEFORE
Label(visibility.rawValue, systemImage: visibility.icon)

// AFTER
Label(visibility.displayName, systemImage: visibility.icon)
```

```swift
// BEFORE
Text(permission.rawValue)

// AFTER
Text(permission.displayName)
```

---

## Consistency Guide

### ✅ DO: Use lowercase for storage/comparison
```swift
profile.profileVisibility = "everyone"
if profile.profileVisibility != "nobody" { ... }
record["profileVisibility"] = "friendsOnly"
```

### ✅ DO: Use displayName for UI
```swift
Text(visibility.displayName)  // Shows "Everyone"
picker.text = permission.displayName  // Shows "Friends Only"
```

### ❌ DON'T: Mix raw values and display values
```swift
// DON'T do this:
if profile.profileVisibility == "Everyone" { ... }  // ❌ Wrong case!

// DO this:
if profile.profileVisibility == "everyone" { ... }  // ✅ Correct
```

---

## CloudKit Values

Your CloudKit records should now store these **exact** values:

### profileVisibility field (String):
- `"everyone"` (lowercase)
- `"friendsOnly"` (camelCase)
- `"nobody"` (lowercase)

### whoCanFollow field (String):
- `"everyone"` (lowercase)
- `"friendsOnly"` (camelCase)
- `"approvalRequired"` (camelCase)
- `"nobody"` (lowercase)

---

## Migration for Existing Users

If you have existing CloudKit records with capitalized values like `"Everyone"`, you have two options:

### Option 1: Database Migration (Recommended for production)
Write a script to update all existing records:
```swift
// Fetch all UserProfile records
// For each record:
if record["profileVisibility"] == "Everyone" {
    record["profileVisibility"] = "everyone"
}
if record["profileVisibility"] == "Friends Only" {
    record["profileVisibility"] = "friendsOnly"
}
// Save back to CloudKit
```

### Option 2: Backward Compatible Reading (Quick fix)
Update the `init?(from:)` in `UserProfile` to normalize values:
```swift
let rawVisibility = record["profileVisibility"] as? String ?? "friendsOnly"
self.profileVisibility = rawVisibility.lowercased()
    .replacingOccurrences(of: " ", with: "")
    .replacingOccurrences(of: "only me", with: "nobody")
```

---

## Testing Checklist

- [ ] Create new profile → Check CloudKit shows `profileVisibility = "everyone"`
- [ ] Change to "Friends Only" → Check CloudKit shows `"friendsOnly"`
- [ ] Change to "Only Me" → Check CloudKit shows `"nobody"`
- [ ] Search users → Verify filter `!= "nobody"` works
- [ ] UI pickers show proper capitalized text ("Everyone", not "everyone")
- [ ] Settings save and load correctly

---

## Answer to Your Question

> "test should be in quotes or without quotes? 'everyone'"

**Answer:** In your Swift code, **ALWAYS with quotes** `"everyone"` because it's a string literal.

**Examples:**
```swift
// ✅ CORRECT - With quotes in code
let visibility = "everyone"
profile.profileVisibility = "everyone"
if value == "friendsOnly" { ... }

// ❌ WRONG - Without quotes (compiler error)
let visibility = everyone  // Error: Use of unresolved identifier
```

**In CloudKit Dashboard/Database:**
- You'll see values displayed without quotes: `everyone`
- But they're stored as String type
- When querying, you still use quotes: `profileVisibility = "everyone"`

---

## Summary

- **Code:** Always use quotes: `"everyone"`, `"friendsOnly"`, `"nobody"` ✅
- **Storage:** Lowercase/camelCase raw values in CloudKit
- **Display:** Use `.displayName` for user-facing text
- **Comparisons:** Always use lowercase raw values with quotes

This ensures consistency and prevents string comparison bugs! 🎯
