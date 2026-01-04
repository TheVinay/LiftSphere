# HealthKit Write Troubleshooting Guide

## 🔍 Problem: "No Data Found" in Health App

You've checked:
- ✅ Health app → Apps → LiftSphere 
- ✅ "Allow LiftSphere to Write" → Active Energy ✓
- ✅ "Allow LiftSphere to Write" → Workouts ✓
- ❌ Health app → Apps → LiftSphere → "Data from LiftSphere" → **No Data Found**

## 🐛 What We Fixed

### Issue 1: Authorization Check Bug
**Problem:** The `saveWorkout()` function was checking `isAuthorized` property, which is only set when the user goes through the in-app Health Stats authorization flow. If the user granted permissions directly in Settings or Health app, this flag would be false.

**Fix:** Removed the `isAuthorized` guard from `saveWorkout()`. Now it attempts to save and lets HealthKit tell us if permissions aren't granted.

### Issue 2: Silent Failures
**Problem:** Errors were being logged but not detailed enough to debug.

**Fix:** Added comprehensive logging that shows:
- Workout details being saved
- Exact error codes from HealthKit
- Specific guidance based on error type

## 🧪 Testing Steps

### Step 1: Use the Debug View

I've created `HealthKitDebugView.swift` for testing. To use it:

1. Add it to your app temporarily (e.g., as a sheet from Profile)
2. Run the app
3. Open the debug view
4. Tap "Test Write Workout"
5. Read the detailed log output

This will tell you exactly what's happening when trying to write.

### Step 2: Complete a Real Workout

1. Go to your workout list
2. Find any workout (or create a new one)
3. Make sure it has at least one set logged
4. Swipe on the workout
5. Tap the green **"Complete"** button
6. Open **Xcode Console** and look for these logs:

```
📝 Attempting to save workout to HealthKit:
   Name: [workout name]
   Date: [date]
   Duration: [X] minutes
   Volume: [Y] lbs
   Sets: [Z]
```

Then you should see either:
- `✅ Successfully saved workout to Apple Health!`
- Or an error with details

### Step 3: Check Health App

**Option A: View in Workouts**
1. Open Health app
2. Tap **Browse** (bottom)
3. Scroll to **Activity**
4. Tap **Workouts**
5. Look for your workout with today's date

**Option B: View in Apps**
1. Open Health app
2. Tap **profile icon** (top right)
3. Tap **Apps**
4. Tap **LiftSphere**
5. Tap **Data from "LiftSphere"**
6. Should show workouts

## 🔧 Common Issues & Solutions

### Issue: HKError Code 4 (Authorization Denied)

**Symptoms:**
```
⚠️ Failed to save workout to HealthKit:
   HKError Code: 4
   → User needs to grant write permission in Health app
```

**Solution:**
1. Open **Health app**
2. Tap **profile icon** (top right)
3. Tap **Apps**
4. Tap **LiftSphere**
5. Under "Allow LiftSphere to Write":
   - Enable **Workouts** ✓
   - Enable **Active Energy** ✓
6. Scroll down and tap **Turn On All** (easier)
7. Go back to your app
8. Try marking a workout complete again

### Issue: No Logs Appearing

**Symptoms:**
- No console logs when marking workout complete

**Possible Causes:**
1. **Workout already completed:** The save only happens when toggling from incomplete → complete
2. **Not viewing console:** Make sure Xcode console is visible (View → Debug Area → Show Debug Area)

**Solution:**
- Find a workout that's NOT completed yet
- Make sure it has the checkbox empty
- Swipe and tap Complete
- Watch the console

### Issue: Duration is 0 or Very Short

**Symptoms:**
```
Duration: 0.0 minutes
```

**Cause:** Workout has no sets and all the time fields (warmup, core, stretch) are 0.

**Solution:**
- Either add sets to the workout before completing it
- Or make sure the workout template has some time values set

### Issue: Can't Find Workouts in Health App

**Symptoms:**
- Console says "✅ Successfully saved"
- But can't find workout in Health app

**Possible Causes:**
1. Looking in wrong place
2. Workout saved with old date
3. Health app needs refresh

**Solutions:**

**Try all these locations:**

A. **Browse → Activity → Workouts**
   - Should show ALL workouts
   - Sort by "Most Recent"

B. **Browse → Activity → Workouts → Show All Data**
   - Shows detailed list
   - Look for "Strength Training"
   - Source should say "LiftSphere"

C. **Summary tab → Activity rings → Workouts (tap)**
   - Only shows recent workouts

D. **Apps → LiftSphere → Workouts**
   - Should show all workouts from your app

**Force Refresh:**
- Close Health app completely (swipe up)
- Wait 5 seconds
- Reopen Health app
- Check again

### Issue: Workouts Appearing with Wrong Date

**Symptoms:**
- Workout saved but date is in the past

**Cause:** The workout's `date` property is being used, which is when the workout was created, not when it was completed.

**Consideration for Future:**
You might want to add a `completedDate` property to track when it was actually finished, separate from when it was created.

## 📊 Expected Workout Data in Health

When a workout is successfully saved, you should see:

| Field | Value |
|-------|-------|
| **Activity Type** | Traditional Strength Training |
| **Source** | LiftSphere |
| **Duration** | Warmup + Core + Stretch + (Sets × 2 min) |
| **Energy Burned** | Volume × 0.04 kcal |
| **Indoor** | Yes |
| **Metadata** | WorkoutName field |

## 🎯 Verification Checklist

Run through this checklist:

- [ ] HealthKit capability enabled in Xcode
- [ ] `NSHealthUpdateUsageDescription` in Info.plist
- [ ] Health app → Apps → LiftSphere → Write permissions granted
- [ ] At least one workout exists in the app
- [ ] Workout has sets logged (recommended)
- [ ] Workout is NOT already marked complete
- [ ] Swipe on workout → tap green Complete button
- [ ] Check Xcode console for "✅ Successfully saved"
- [ ] Open Health app → Browse → Activity → Workouts
- [ ] See workout with "LiftSphere" as source

## 🚨 If Still Not Working

### Nuclear Option: Reset HealthKit Permissions

1. Open iPhone **Settings**
2. Scroll down to **Health**
3. Tap **Data Access & Devices**
4. Find **LiftSphere**
5. Tap **Delete All Data from LiftSphere**
6. Confirm deletion
7. Go back to your app
8. Go to Profile → Health Stats
9. Tap "Connect to Health App"
10. Grant ALL permissions
11. Try completing a workout again

### Check Info.plist

Make sure these keys exist:

```xml
<key>NSHealthShareUsageDescription</key>
<string>LiftSphere needs access to read your health data to display body composition, activity, and fitness metrics alongside your workout stats.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>LiftSphere writes workout data to the Health app so you can track your strength training progress.</string>
```

### Verify Capability

1. Open Xcode
2. Select your target
3. Go to "Signing & Capabilities"
4. Verify "HealthKit" capability is present
5. Make sure "Clinical Health Records" is UNCHECKED

## 📝 Debug Command

If you want to test HealthKit write permissions quickly, add this button temporarily to your ProfileView:

```swift
Button("Test HealthKit Write") {
    showHealthKitDebug = true
}
.sheet(isPresented: $showHealthKitDebug) {
    HealthKitDebugView()
}
```

The debug view will give you instant feedback on what's working and what isn't.

## 💡 Pro Tips

1. **Always check the console:** Xcode logs are your best friend
2. **Use the debug view first:** It's faster than completing real workouts
3. **Check multiple places in Health:** Workouts can be found in several locations
4. **Give it a second:** Sometimes Health app needs a moment to refresh
5. **Close and reopen Health:** iOS can be finicky about refreshing data

## 🎓 Understanding HealthKit Permissions

HealthKit permissions are tricky:

- **Write permission** can be granted without ever calling `requestAuthorization()`
- Users can grant permissions in Settings/Health app directly
- Your app's `isAuthorized` flag might be false even if permissions are granted
- HealthKit doesn't tell you if write permissions are granted (privacy feature)
- You only know by trying to write and seeing if it succeeds

This is why we removed the `isAuthorized` check from the write function!

## 🎉 Success Indicators

You know it's working when:

1. ✅ Console shows "Successfully saved workout to Apple Health!"
2. ✅ Health app → Browse → Activity → Workouts shows your workout
3. ✅ Workout has "LiftSphere" as the source
4. ✅ Energy burned amount appears
5. ✅ Duration matches your workout

---

**Last Updated:** December 31, 2025  
**Tested On:** iOS 18+
