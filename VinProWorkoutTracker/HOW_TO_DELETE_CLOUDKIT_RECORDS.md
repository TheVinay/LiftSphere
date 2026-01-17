# How to Delete Old CloudKit Records

## 🎯 Quick Answer

You have **3 options** to delete old CloudKit records:

---

## ✅ **Method 1: CloudKit Dashboard (Recommended for Bulk Delete)**

### **Step-by-Step:**

1. **Open CloudKit Dashboard:**
   - Go to: https://icloud.developer.apple.com/dashboard
   - Sign in with your Apple Developer account

2. **Select Container:**
   - Click: `iCloud.com.vinay.VinProWorkoutTracker`

3. **Choose Environment:**
   - Select: **Development** (top of page)
   - This is where your test data is

4. **Go to Public Database:**
   - Left sidebar: Click **Data**
   - Database: **Public Database**

5. **Select Record Type:**
   - Dropdown: **Record Type**
   - Choose: `UserProfile`

6. **View All Records:**
   - You'll see a table of all UserProfile records
   - Shows: Record Name, Fields, Created Date

7. **Delete Records:**

   **Option A - Delete Specific Record:**
   - Click on the record row
   - Click trash icon 🗑️ (top right)
   - Confirm deletion
   
   **Option B - Delete Multiple:**
   - Check boxes next to records
   - Click "Delete" button
   - Confirm deletion
   
   **Option C - Delete All:**
   - Click "Select All" (if available)
   - Click "Delete"
   - Confirm

8. **Repeat for Other Record Types:**
   - `FriendRelationship`
   - `PublicWorkout`
   - Any other test data

### **Screenshot Guide:**
```
CloudKit Dashboard
├─ iCloud.com.vinay.VinProWorkoutTracker
   ├─ Development ← Select this
   │  ├─ Public Database
   │  │  ├─ Data ← Click here
   │  │  │  ├─ Record Type: UserProfile ← Select
   │  │  │  ├─ [List of records] ← Delete these
```

---

## ⚡ **Method 2: In-App Debug Menu (Easiest During Testing)**

I just added a debug menu to your app!

### **How to Use:**

1. **Run app in Debug mode** (from Xcode)
2. **Go to Friends tab**
3. **Look for ⋯ button** (top right, three dots)
4. **Tap it to see menu:**
   - 🗑️ **Delete My Profile** - Deletes your current profile from CloudKit
   - 🗑️ **Cleanup Old Profiles** - Deletes all orphaned profiles (without appleUserID)
   - 🔄 **Clear Local Cache** - Clears UserDefaults cache

### **When to Use Each:**

**Delete My Profile:**
- Use when you want to start fresh
- Deletes your profile from CloudKit
- Clears local cache
- Next time you'll see "Create Profile" prompt

**Cleanup Old Profiles:**
- Automatically finds profiles created BEFORE the fix
- These are profiles without `appleUserID` field
- Deletes them all at once
- Safe - only deletes broken/orphaned profiles

**Clear Local Cache:**
- Just clears your device's cache
- Doesn't touch CloudKit
- Forces app to re-fetch from CloudKit
- Useful for testing

### **Code Added:**
```swift
#if DEBUG
// Only available in debug builds
func deleteCurrentUserProfile() async throws
func cleanupOrphanedProfiles() async throws
#endif
```

**Safety:** These functions only exist in DEBUG builds. Production builds won't have them.

---

## 💻 **Method 3: Using CloudKit API Directly**

If you want more control, you can use the API:

### **In Xcode Console (lldb):**

While app is running, pause execution:
```lldb
(lldb) po await socialService.deleteCurrentUserProfile()
```

### **Or Add Temporary Code:**

In your `FriendsView.swift` or anywhere:
```swift
.onAppear {
    Task {
        try? await socialService.deleteCurrentUserProfile()
    }
}
```

Remove after testing!

---

## 🧹 **Recommended Cleanup Flow**

### **For Testing the Fix:**

1. **Run app**
2. **Go to Friends tab**
3. **Tap ⋯ menu (top right)**
4. **Select "Cleanup Old Profiles"**
   - This removes all broken profiles
5. **Select "Clear Local Cache"**
   - Ensures fresh start
6. **Create new profile**
   - Will use new system with Apple ID
7. **Test persistence:**
   - Close app
   - Reopen
   - Profile should still be there ✅

---

## 🎯 **What to Delete**

### **Must Delete:**
- ✅ Old `UserProfile` records (without `appleUserID` field)

### **Optional Delete:**
- ⚠️ `FriendRelationship` records (if you tested friend requests)
- ⚠️ `PublicWorkout` records (if you tested workout sharing)

### **Don't Delete:**
- ❌ Schema definitions (you need these!)
- ❌ Indexes (required for queries)

---

## 📋 **Verification After Deletion**

### **In CloudKit Dashboard:**
1. Go to Data → UserProfile
2. Should see: "No records found" OR only new records with `appleUserID`

### **In App:**
1. Go to Friends tab
2. Should see: "Create Profile" prompt
3. Create new profile
4. Check console logs:
   ```
   ✅ Got Apple User ID: _xxxxxxxxxxxxx
   ✅ Profile saved successfully!
   ✅ Cached profile locally
   ```

---

## ⚠️ **Important Notes**

### **Development vs Production:**
- Deleting from Development doesn't affect Production
- Each environment has separate data
- Safe to experiment in Development

### **Can't Undo:**
- CloudKit deletions are permanent
- No trash/recycle bin
- Make sure you're deleting the right records

### **Local Cache:**
- Deleting from CloudKit doesn't clear app cache
- Use "Clear Local Cache" in debug menu
- Or delete/reinstall app

---

## 🐛 **Troubleshooting**

### **"Record not found" error:**
- Record already deleted
- Check you're in right environment (Development vs Production)

### **"Permission denied" error:**
- Not signed into iCloud on device
- Wrong Apple ID
- Check Settings → iCloud

### **App still shows old profile:**
- Local cache not cleared
- Use "Clear Local Cache" in debug menu
- Or: Delete app and reinstall

### **Can't see debug menu:**
- Make sure you're running DEBUG build
- Build from Xcode (not TestFlight)
- Menu only shows in debug mode

---

## ✅ **Quick Command Reference**

| Task | Method | Command |
|------|--------|---------|
| Delete my profile | In-app | Friends tab → ⋯ → Delete My Profile |
| Delete old profiles | In-app | Friends tab → ⋯ → Cleanup Old Profiles |
| Clear cache | In-app | Friends tab → ⋯ → Clear Local Cache |
| Delete from dashboard | Web | CloudKit Dashboard → Data → Select → Delete |
| Delete all | Web | CloudKit Dashboard → Select All → Delete |

---

## 🎉 **After Cleanup**

Once you've deleted old records:

1. ✅ CloudKit is clean
2. ✅ Local cache is clear
3. ✅ Ready to test new fix
4. ✅ Create profile → should persist! 

Try creating a profile now and test the persistence fix! 🚀
