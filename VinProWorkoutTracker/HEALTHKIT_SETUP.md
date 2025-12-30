# HealthKit Setup Guide

## 🏥 Enable HealthKit in Xcode

Follow these steps to enable HealthKit in your app:

### 1. Add HealthKit Capability
1. Open your project in Xcode
2. Select your **app target** (VinProWorkoutTracker)
3. Go to the **Signing & Capabilities** tab
4. Click the **+ Capability** button
5. Search for and add **HealthKit**
6. Make sure the "Clinical Health Records" checkbox is **unchecked** (unless you need it)

### 2. Add Privacy Descriptions to Info.plist
You need to add two privacy usage descriptions:

**Option A: Using Xcode**
1. Select your **Info.plist** file (or in newer Xcode, go to target > Info tab)
2. Add these two keys:

```
Key: Privacy - Health Share Usage Description
Value: LiftSphere needs access to read your health data to display body composition, activity, and fitness metrics alongside your workout stats.

Key: Privacy - Health Update Usage Description  
Value: LiftSphere may write workout data to the Health app.
```

**Option B: Raw Info.plist XML**
If you're editing the raw plist file, add:
```xml
<key>NSHealthShareUsageDescription</key>
<string>LiftSphere needs access to read your health data to display body composition, activity, and fitness metrics alongside your workout stats.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>LiftSphere may write workout data to the Health app.</string>
```

### 3. Build and Run
- HealthKit only works on **real devices** and **simulators** (but simulators need sample data)
- HealthKit is **NOT available** on Mac Catalyst or iPad (unless it's an iPad with cellular)

## 📊 What Health Data Is Tracked

### Body Composition
- ✅ Weight
- ✅ Height  
- ✅ BMI (Body Mass Index)
- ✅ Body Fat Percentage
- ✅ Lean Body Mass
- ✅ Muscle Mass (calculated)
- ✅ Bone Mass (calculated)

### Metabolic
- ✅ BMR (Basal Metabolic Rate)
- ✅ Active Energy Burned

### Activity (Today)
- ✅ Steps
- ✅ Distance Walking/Running
- ✅ Exercise Time

### Heart & Fitness
- ✅ Resting Heart Rate
- ✅ Heart Rate Variability (HRV)
- ✅ VO2 Max

### Sleep
- ✅ Sleep Hours (last night)

### Nutrition (Today)
- ✅ Calories
- ✅ Protein
- ✅ Carbs
- ✅ Fat

## 📱 Testing with Simulator

To test HealthKit in the simulator:
1. Open the **Health app** on the simulator
2. Tap **Browse** tab
3. Manually add sample data for:
   - Body Measurements (Weight, Height, Body Fat %, etc.)
   - Activity (Steps, Exercise Minutes)
   - Heart (Resting Heart Rate)
   - Sleep
   - Nutrition (Protein, etc.)

## 🎯 How to Use

1. Go to the **Profile** tab
2. Tap the **"Health Stats"** button
3. Tap **"Connect to Health App"**
4. Grant permissions for the health data you want to share
5. Your health stats will load automatically
6. Tap the refresh button to update data

## 📝 Notes

- **Visceral Fat, Subcutaneous Fat, Metabolic Age**: These are not standard HealthKit types. They're proprietary metrics from smart scales (like Withings, Fitbit Aria, etc.). If your scale syncs these to a third-party app, they may not appear in Apple Health.
  
- **Muscle Mass & Bone Mass**: If not available from your scale, the app will estimate these based on your lean body mass.

- **Data Privacy**: All health data stays on your device. We only read the data for display - nothing is sent to any servers.

## 🔧 Troubleshooting

**Problem**: "HealthKit Not Available"
- HealthKit doesn't work on some devices (like iPod touch)
- Try on iPhone or simulator

**Problem**: No data appears after granting permission
- Make sure you have data in the Health app
- Tap the refresh button
- Check that you granted "Read" permissions (not just "Write")

**Problem**: Some metrics are missing
- Not all devices track all metrics (e.g., VO2 Max needs Apple Watch)
- Smart scale metrics may not sync to Apple Health
- Add data manually in Health app for testing

## 🚀 Future Enhancements

Possible additions:
- Write workout data back to Health app
- Historical trends and charts
- Weekly/monthly averages
- Body composition progress tracking
- Integration with profile analytics
