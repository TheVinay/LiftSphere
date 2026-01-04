# CloudKit Manual Setup - Step by Step

## 🚨 You Got This Error:
```
Couldn't get container configuration from the server for container 
icloud.com.vinay.vinproworkouttracker
```

This means the CloudKit container needs to be manually configured. Here's how:

---

## ✅ Step-by-Step Solution

### **STEP 1: Run the Diagnostic Tool**

I've just added a diagnostic tool to your app:

1. Build and run your app
2. Go to **Settings** tab (gear icon)
3. Scroll down to "Data & Sync" section
4. Tap **"CloudKit Diagnostics"**
5. Tap **"Run Full Diagnostics"**
6. Take a screenshot of the results and read them carefully

This will tell you:
- ✅ If your container exists
- ✅ If you're signed into iCloud
- ✅ If the record types are created
- ✅ What exactly is missing

---

### **STEP 2: Fix iCloud Account (If Needed)**

If diagnostics show "No iCloud account":

1. Open **Settings** app on your iPhone
2. Tap **[Your Name]** at the top
3. If not signed in:
   - Tap "Sign in to your iPhone"
   - Enter your Apple ID and password
4. Tap **iCloud**
5. Make sure **iCloud Drive** is turned **ON** (green)
6. Scroll down and make sure your app has permission

Go back to app and run diagnostics again.

---

### **STEP 3: Create CloudKit Schema Manually**

This is the most important step! Even if your container exists, the **record types** must be created.

#### A. Open CloudKit Dashboard

1. Go to: https://icloud.developer.apple.com/dashboard
2. Sign in with your **Apple Developer account** (same as Xcode)
3. At the top, select your container from dropdown
   - Should be like: `iCloud com vinay VinProWorkoutTracker` or similar
   - If you don't see any containers, your container hasn't been created yet (see Step 4)

#### B. Select Database

- In the left sidebar, you'll see:
  - Development (for testing)
  - Production (for App Store)
- Click **"Development"** first
- Make sure you're in the **"Public Database"** section (not Private)

#### C. Create UserProfile Record Type

1. Click **"Add Record Type"** button (or "+" icon)
2. Name it exactly: `UserProfile`
3. Click "Add Field" and add these fields:

| Field Name | Type | Indexed? | Sortable? |
|------------|------|----------|-----------|
| username | String | ✓ Yes | ✓ Yes |
| displayName | String | ✓ Yes | ✗ No |
| bio | String | ✗ No | ✗ No |
| avatarURL | String | ✗ No | ✗ No |
| createdDate | Date/Time | ✗ No | ✓ Yes |
| isPublic | Int(64) | ✓ Yes | ✗ No |
| totalWorkouts | Int(64) | ✗ No | ✓ Yes |
| totalVolume | Double | ✗ No | ✓ Yes |

4. Click **"Save"**

#### D. Set UserProfile Permissions

1. Click on **"UserProfile"** in the record types list
2. Click **"Security Roles"** tab
3. Configure permissions:
   - **World (Everyone)**: 
     - Read: ✓ Checked
     - Write: ✗ Unchecked
     - Create: ✗ Unchecked
   - **Authenticated (Signed-in users)**:
     - Read: ✓ Checked
     - Write: ✓ Checked
     - Create: ✓ Checked
4. Click **"Save"**

#### E. Create FriendRelationship Record Type

1. Click **"Add Record Type"** again
2. Name it exactly: `FriendRelationship`
3. Add these fields:

| Field Name | Type | Indexed? | Sortable? |
|------------|------|----------|-----------|
| followerID | String | ✓ Yes | ✗ No |
| followingID | String | ✓ Yes | ✗ No |
| createdDate | Date/Time | ✗ No | ✓ Yes |
| status | String | ✓ Yes | ✗ No |

4. Click **"Save"**
5. Set same permissions as UserProfile (World: Read, Authenticated: Read/Write/Create)

#### F. Create PublicWorkout Record Type

1. Click **"Add Record Type"** again
2. Name it exactly: `PublicWorkout`
3. Add these fields:

| Field Name | Type | Indexed? | Sortable? |
|------------|------|----------|-----------|
| userID | String | ✓ Yes | ✗ No |
| workoutName | String | ✗ No | ✗ No |
| date | Date/Time | ✗ No | ✓ Yes |
| totalVolume | Double | ✗ No | ✓ Yes |
| exerciseCount | Int(64) | ✗ No | ✗ No |
| isCompleted | Int(64) | ✗ No | ✗ No |

4. Click **"Save"**
5. Set same permissions (World: Read, Authenticated: Read/Write/Create)

#### G. Verify Record Types

In the CloudKit Dashboard, you should now see three record types:
- ✅ UserProfile
- ✅ FriendRelationship
- ✅ PublicWorkout

---

### **STEP 4: If Container Doesn't Exist**

If you went to CloudKit Dashboard and saw **no containers**, or can't find yours:

#### Option 1: Force Create Container in Xcode

1. Open your project in Xcode
2. Select your target → Signing & Capabilities
3. In the iCloud section:
   - **Remove** the iCloud capability (click the X)
   - Click "+" and **add it back**
   - Check "CloudKit"
4. Click on the container dropdown
5. Select **"Create Custom Container..."**
6. Name it: `iCloud.com.vinay.LiftSphere`
7. Make sure it's **checked**
8. Clean build folder: Product → Clean Build Folder (⇧⌘K)
9. Build and run on **real device**
10. Wait 2-3 minutes
11. Check CloudKit Dashboard again

#### Option 2: Wait for Automatic Provisioning

Sometimes it just takes time:
1. Build on real device
2. Let the app run for a few minutes
3. Close the app
4. Wait 5-10 minutes
5. Check CloudKit Dashboard again
6. Refresh the page

---

### **STEP 5: Test Again**

After setting up the record types:

1. Go back to your app
2. Go to Settings → CloudKit Diagnostics
3. Tap **"Test Record Types"**
4. You should see:
   - ✅ UserProfile exists
   - ✅ FriendRelationship exists
   - ✅ PublicWorkout exists

If all three show green checkmarks, you're good to go!

---

### **STEP 6: Create Your Profile**

Now try creating your profile again:

1. Go to **Friends** tab
2. Tap **"Create Profile"**
3. Enter:
   - Username: (3+ characters, letters and numbers only)
   - Display Name: (any name)
   - Bio: (optional)
4. Tap **"Create Profile"**

It should work now! 🎉

---

## 🐛 Common Errors & Solutions

### "Not authenticated to iCloud"

**Fix:**
- Settings → [Your Name] → Sign in
- Make sure iCloud Drive is ON
- Try airplane mode ON then OFF to refresh connection

### "Unknown item: UserProfile"

**Fix:**
- Record type doesn't exist
- Go back to Step 3 and create it
- Make sure spelling is EXACT: `UserProfile` (capital U and P)

### "Permission denied"

**Fix:**
- Permissions not set correctly
- Go to CloudKit Dashboard
- Click UserProfile → Security Roles
- Make sure Authenticated users can Read/Write/Create

### "Network error" or "Request timeout"

**Fix:**
- Check internet connection
- Turn off VPN if using one
- Try on cellular data instead of WiFi
- Wait a few minutes and try again

### Container still doesn't appear

**Fix:**
- Make sure you're signed in with correct Apple ID in Xcode
- Check Team in Signing & Capabilities matches your Apple ID
- Try creating a new container with different name
- Contact Apple Developer Support if stuck

---

## 📸 Visual Checklist

Before creating a profile, verify:

**In Xcode:**
- [ ] iCloud capability present
- [ ] CloudKit checkbox checked
- [ ] Container shown and checked
- [ ] Building on real device (not simulator)
- [ ] Signed in with Apple ID in Xcode

**On Device:**
- [ ] Signed in to iCloud (Settings → [Your Name])
- [ ] iCloud Drive is ON
- [ ] Internet connected
- [ ] App has iCloud permission

**In CloudKit Dashboard:**
- [ ] Container appears in dropdown
- [ ] Development database selected
- [ ] Public Database selected (not Private)
- [ ] UserProfile record type exists with 8 fields
- [ ] FriendRelationship record type exists with 4 fields
- [ ] PublicWorkout record type exists with 6 fields
- [ ] All three have proper permissions set

**In Your App:**
- [ ] Settings → CloudKit Diagnostics shows all green
- [ ] "Test Record Types" shows all three exist
- [ ] iCloud account status shows "Available"

If all checkboxes are checked, profile creation will work!

---

## 🎥 Screenshot Guide

When creating record types in CloudKit Dashboard, it should look like this:

```
CloudKit Dashboard
├── Container: iCloud.com.vinay.VinProWorkoutTracker
├── Environment: Development
├── Database: Public
└── Record Types:
    ├── UserProfile (8 fields)
    │   ├── username: String (Indexed, Sortable)
    │   ├── displayName: String (Indexed)
    │   ├── bio: String
    │   ├── avatarURL: String
    │   ├── createdDate: Date/Time (Sortable)
    │   ├── isPublic: Int64 (Indexed)
    │   ├── totalWorkouts: Int64 (Sortable)
    │   └── totalVolume: Double (Sortable)
    │
    ├── FriendRelationship (4 fields)
    │   ├── followerID: String (Indexed)
    │   ├── followingID: String (Indexed)
    │   ├── createdDate: Date/Time (Sortable)
    │   └── status: String (Indexed)
    │
    └── PublicWorkout (6 fields)
        ├── userID: String (Indexed)
        ├── workoutName: String
        ├── date: Date/Time (Sortable)
        ├── totalVolume: Double (Sortable)
        ├── exerciseCount: Int64
        └── isCompleted: Int64
```

---

## 📞 Still Stuck?

If you've followed all steps and it still doesn't work:

1. Run **CloudKit Diagnostics** in the app
2. Take screenshot of the diagnostic log
3. Check Xcode console for error messages
4. Note the **exact error message** you see
5. Share that information for more specific help

The diagnostic tool will tell us exactly what's missing!

---

**Last Updated:** December 31, 2025  
**Tested On:** iOS 17+, Xcode 15+
