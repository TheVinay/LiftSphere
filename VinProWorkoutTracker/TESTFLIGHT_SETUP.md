# TestFlight Setup Checklist ✅

## PART 1: XCODE SETUP (Do This First!)

### Step 1: Add Sign in with Apple Capability
1. Open project in Xcode
2. Click your project name in Navigator (top left)
3. Select your app target
4. Click **"Signing & Capabilities"** tab
5. Click **"+ Capability"** button
6. Search for **"Sign in with Apple"**
7. Click to add it

### Step 2: Configure Bundle Identifier
1. Stay in **"Signing & Capabilities"** tab
2. Look at **"Bundle Identifier"**
3. Set it to: `com.yourname.VinProWorkoutTracker`
   - Replace "yourname" with your actual name or company (no spaces)
   - Example: `com.vinay.VinProWorkoutTracker`
4. ✅ Check **"Automatically manage signing"**
5. Select your **Team** from dropdown (your Apple Developer account)

### Step 3: Add App Icon
1. In Navigator, click **"Assets.xcassets"**
2. Click **"AppIcon"**
3. Drag icon images into the slots
   - Need a 1024×1024 icon minimum
   - Use https://appicon.co/ to generate all sizes from one image

### Step 4: Set Version & Build
1. Click your project name
2. Select target
3. **"General"** tab
4. Set **Version**: `1.0`
5. Set **Build**: `1`

---

## PART 2: APP STORE CONNECT

### Step 1: Create App
1. Go to https://appstoreconnect.apple.com
2. Click **"My Apps"**
3. Click **"+"** → **"New App"**
4. Fill in:
   - **Platform**: iOS
   - **Name**: VinPro Workout Tracker
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select the one from Step 1 above
   - **SKU**: `vinpro-workout-tracker`
   - **User Access**: Full Access
5. Click **"Create"**

---

## PART 3: ARCHIVE & UPLOAD

### Step 1: Archive in Xcode
1. In Xcode, at the top toolbar, click the device selector
2. Select **"Any iOS Device (arm64)"** (NOT simulator!)
3. Menu bar → **Product** → **Archive**
4. Wait 5-10 minutes for build
5. Organizer window will open automatically

### Step 2: Upload to App Store Connect
1. In Organizer, select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"** → Next
4. Select **"Upload"** → Next
5. ✅ Check all options (recommended)
6. Click **"Next"**
7. Click **"Upload"**
8. Wait for upload to complete
9. You'll get email when processing is done (5-30 min)

---

## PART 4: CONFIGURE TESTFLIGHT

### Step 1: Wait for Processing
- Check email for "Your build has finished processing"
- Or refresh App Store Connect → Your App → TestFlight

### Step 2: Add Internal Testers
1. In App Store Connect → Your App → **TestFlight**
2. Click **"Internal Testing"**
3. Click **"+"** to add testers
4. Enter email addresses of testers
5. Select your build
6. Click **"Add"**
7. Testers will receive email invite

### Step 3: Configure External Testing (Optional)
1. Click **"External Testing"**
2. Click **"+"** to create group
3. Name it: "Public Beta"
4. Add "What to Test" notes (see below)
5. Select build
6. Click **"Submit for Review"**
7. Wait 24-48 hours for approval

---

## PART 5: TESTING

### What Testers Need:
1. Install **TestFlight** app from App Store
2. Open invite email
3. Tap link → Opens TestFlight
4. Tap **"Accept"** → **"Install"**
5. Test the app!

---

## WHAT TO TEST (Copy this into TestFlight notes)

```
Welcome to VinPro Workout Tracker Beta!

KEY FEATURES TO TEST:
✅ Sign in with Apple
✅ Create workouts using templates (Vinay Push/Pull, PPL, Bro Split)
✅ Log exercises with weight and reps
✅ Progressive overload indicators (green/red arrows)
✅ Favorite exercises (star icon)
✅ Workout streaks in Profile
✅ Analytics charts
✅ PDF export (share button in workout)
✅ Recently used exercises in Learn tab
✅ Collapsible sections

KNOWN ISSUES:
- None yet!

PLEASE REPORT:
- Any crashes
- Confusing UI
- Missing features
- Bug reports

Contact: your-email@example.com
```

---

## TROUBLESHOOTING

### "No accounts with App Store Connect access"
- Make sure you're enrolled in Apple Developer Program ($99/year)
- Check at developer.apple.com

### "Failed to create provisioning profile"
- Try unchecking and rechecking "Automatically manage signing"
- Make sure Bundle ID doesn't have spaces or special characters

### "Archive option is grayed out"
- Make sure you selected "Any iOS Device", NOT simulator
- Make sure your scheme is set to Release (usually automatic)

### "Build disappeared from App Store Connect"
- Check for email about export compliance
- Check for missing compliance information

---

## NEXT STEPS AFTER TESTFLIGHT

1. Test with 5-10 people for 1-2 weeks
2. Fix any bugs they find
3. Upload new build if needed
4. Once stable → Submit for App Store Review
5. Fill out all App Store metadata
6. Submit → Wait 24-48 hours
7. 🎉 LAUNCH!

---

**You've got this! 🚀**
