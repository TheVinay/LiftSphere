# Tabata HIIT Workouts - Added to Browse Workouts

## ✅ What Was Added

A complete **Tabata HIIT** program with **8 different workout variations** has been added to the Browse Workouts section.

## 📍 Location

**Browse Workouts** → Scroll to bottom → **"Tabata HIIT"** (timer icon)

## 🔥 The 8 Tabata Workouts

### 1. Core Crusher
**Focus:** Abs and core stability  
**Exercises:**
- Mountain Climber
- Russian Twist
- Bicycle Crunch
- Plank Shoulder Tap

**Format:** 4 minutes total (8 rounds of 20s work / 10s rest)

---

### 2. Full Body Burn
**Focus:** Total body conditioning  
**Exercises:**
- Burpee
- Jump Squat
- Push-Up
- High Knee

**Format:** 4 minutes of maximum intensity

---

### 3. Leg Destroyer
**Focus:** Lower body power and endurance  
**Exercises:**
- Jump Squat
- Lunge Jump
- Bodyweight Squat
- Single Leg Glute Bridge

**Format:** 4 minutes of leg-focused intensity

---

### 4. Upper Body Blast
**Focus:** Push strength and endurance  
**Exercises:**
- Push-Up
- Pike Push-Up
- Plank to Push-Up
- Bench Dip (feet on floor)

**Format:** 4 minutes of upper body work

---

### 5. Cardio Crusher
**Focus:** Maximum heart rate and conditioning  
**Exercises:**
- High Knee
- Butt Kick
- Jumping Jack
- Mountain Climber

**Format:** 4 minutes of cardio blast

---

### 6. Total Body Tabata
**Focus:** Everything at once  
**Exercises:**
- Burpee
- Mountain Climber
- Jump Squat
- Push-Up

**Format:** 4 minutes of complete body work

---

### 7. Ab Ripper
**Focus:** Core endurance and stability  
**Exercises:**
- Bicycle Crunch
- Front Plank (hold)
- Russian Twist
- Dead Bug

**Format:** 4 minutes of core destruction

---

### 8. Power Builder
**Focus:** Explosive strength and power  
**Exercises:**
- Jump Squat
- Burpee
- Lunge Jump
- Plank to Push-Up

**Format:** 4 minutes of explosive movements

---

## 📋 Tabata Protocol Details

Each workout follows the **classic Tabata structure**:

- **Work Interval:** 20 seconds (maximum effort)
- **Rest Interval:** 10 seconds
- **Rounds:** 8 rounds
- **Total Time:** 4 minutes
- **Warmup:** 3 minutes
- **Cooldown/Stretch:** 3 minutes

### Total Session Time: ~10 minutes

---

## 🎯 How to Use

1. Go to **Workouts tab**
2. Tap **"Browse Workouts"** button
3. Scroll down to **"Tabata HIIT"** (timer icon)
4. Choose from 8 different workouts
5. Tap a workout to see exercises
6. Tap **"Done"** to create it

---

## 💡 Tabata Tips

### Intensity Level:
- **Beginner:** 70-80% max effort
- **Intermediate:** 80-90% max effort
- **Advanced:** 95-100% max effort (original protocol)

### Frequency:
- 2-3 times per week
- Allow 48 hours rest between sessions
- Can be done as standalone or as a finisher

### Tracking:
- In the workout notes, you can track:
  - How many reps completed each round
  - Total reps across all 8 rounds
  - Your personal best for comparison

### Example Notes Format:
```
Core Crusher Tabata
Round 1: 12 mountain climbers
Round 2: 10 Russian twists
Round 3: 11 bicycle crunches
Round 4: 8 plank shoulder taps
Round 5: 10 mountain climbers
Round 6: 9 Russian twists
Round 7: 10 bicycle crunches
Round 8: 7 plank shoulder taps

Total: 77 reps
Goal: Beat 77 next time!
```

---

## 🏋️ Progression Ideas

### Week 1-2:
- Focus on form
- 80% max effort
- Rest 2-3 min between exercises if needed

### Week 3-4:
- Increase intensity to 90%
- Minimal rest between exercises
- Track total reps

### Week 5+:
- Full intensity (95-100%)
- Try "Double Tabata" (do 2 workouts back-to-back)
- Beat your previous rep counts

---

## 📊 Why Tabata?

### Benefits:
- ✅ Only 4 minutes of work
- ✅ Massive calorie burn (continues post-workout)
- ✅ Improves VO2 max
- ✅ Builds anaerobic and aerobic capacity
- ✅ Time-efficient
- ✅ No equipment needed
- ✅ Can be done anywhere

### Science:
- Developed by Dr. Izumi Tabata (1996)
- Research showed 28% increase in anaerobic capacity
- 14% increase in VO2 max in 6 weeks
- Only 4 minutes of actual work per session!

---

## 🎨 Visual Design

The Tabata program appears in the list with:
- **Icon:** Timer (⏱️)
- **Name:** "Tabata HIIT"
- **Days:** "8 days" (8 different workouts)

Each workout day shows:
- **Name:** e.g., "Core Crusher"
- **Description:** "4 min - 8 rounds × (20s work / 10s rest)"
- **Exercises:** 4 exercises per Tabata
- **Stretches:** Appropriate cool-down stretches

---

## 🔧 Technical Details

### Implementation:
- Added to `BrowseWorkoutsViewNew.swift`
- Uses existing `WorkoutProgram` and `ProgramDay` structure
- Creates standard `Workout` objects
- All exercises are bodyweight (no equipment)

### Structure:
```swift
private var tabataProgram: WorkoutProgram {
    WorkoutProgram(
        name: "Tabata HIIT",
        icon: "timer",
        days: [ /* 8 ProgramDay objects */ ]
    )
}
```

### Each ProgramDay:
- 4 exercises in `exercises` array
- No core exercises (main work is the tabata)
- 3-4 stretches for cooldown
- 3 min warmup, 4 min core, 3 min stretch

---

## ✅ Ready to Use!

The Tabata workouts are now live in your app! Users can:
- Browse all 8 workouts
- See exercise lists
- Create workouts with one tap
- Track their Tabata sessions
- Log reps/rounds in notes

**Perfect for:**
- Quick workouts when short on time
- High-intensity finishers
- Cardio-focused training days
- Hotel/travel workouts
- Breaking through plateaus

---

**Enjoy crushing those Tabatas! 💪🔥**
