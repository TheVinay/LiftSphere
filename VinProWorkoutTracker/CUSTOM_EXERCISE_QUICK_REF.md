# Custom Exercise Quick Reference

## 🚀 Quick Start

### **User Creates Exercise:**
1. Tap floating **+ button** in LearnView
2. Fill required fields: Name, Muscles
3. Tap **Save**
4. Exercise appears instantly with **[CUSTOM]** badge

### **User Deletes Exercise:**
1. Swipe left on custom exercise
2. Tap **Delete**
3. System shows smart alert:
   - **No history** → "Permanently delete?"
   - **Has history** → "Archive to preserve data?"
4. Confirm → Done!

---

## 📚 Key Classes

### **CustomExercise** (Model)
SwiftData model that stores all exercise data.

**Key Properties:**
- `name: String`
- `primaryMuscle: MuscleGroup` (computed from raw value)
- `equipment: Equipment` (computed from raw value)
- `isArchived: Bool`
- `musclesDescription: String`
- `instructions: String?` (newline-separated)
- `formTips: String?` (newline-separated)

**Key Methods:**
- `toTemplate() -> ExerciseTemplate` - Convert for use in app
- `hasHistory(in context:) -> Bool` - Check if used in workouts
- `historyCount(in context:) -> Int` - Count of sets logged

---

### **CustomExerciseManager** (Business Logic)

**Save:**
```swift
try CustomExerciseManager.saveExercise(
    name: "Dragon Flag",
    primaryMuscle: .abs,
    secondaryMuscle: nil,
    equipment: .bodyweight,
    isCalisthenic: true,
    lowBackSafe: false,
    machineName: nil,
    info: "Advanced core exercise",
    musclesDescription: "Core, Hip Flexors",
    instructions: "Step 1\nStep 2\nStep 3",
    formTips: "Tip 1\nTip 2",
    context: context
)
```

**Fetch:**
```swift
let active = CustomExerciseManager.fetchActiveExercises(from: context)
let archived = CustomExerciseManager.fetchArchivedExercises(from: context)
```

**Delete:**
```swift
// Get info first
let info = CustomExerciseManager.getDeleteInfo(for: exercise, context: context)

// Show alert with info.message

// Then delete
try CustomExerciseManager.deleteExercise(exercise, context: context)
```

**Restore:**
```swift
try CustomExerciseManager.restoreExercise(exercise, context: context)
```

**Get All Exercises (Built-in + Custom):**
```swift
let all = CustomExerciseManager.getAllExercises(context: context)
```

---

### **CreateExerciseView** (UI)

**Required Fields:**
- Exercise name
- Muscles description

**Optional Fields:**
- Secondary muscle
- Machine name
- Brief info
- Instructions
- Form tips

**Features:**
- Live preview
- Validation
- Error alerts
- Haptic feedback
- Auto-population (bodyweight → calisthenic)

---

## 🎯 Integration Points

### **LearnView**
- Queries `@Query` for `CustomExercise`
- Merges with built-in exercises
- Shows [CUSTOM] badge
- Adds swipe-to-delete
- Shows floating + button

### **ExerciseDatabase**
- Extended with methods to check custom exercises
- Falls back to custom if built-in not found

### **ExerciseLibrary**
- Custom exercises merge seamlessly
- Work with all filters (muscle, equipment, mode)

---

## 🗂️ Data Storage

**SwiftData Schema:**
```swift
Schema([
    Workout.self,
    SetEntry.self,
    CustomWorkoutTemplate.self,
    CustomExercise.self  // ← New!
])
```

**Sync:**
- Automatic CloudKit sync via SwiftData
- Works across devices
- Falls back to local if CloudKit unavailable

---

## 🎨 UI Patterns

### **Custom Badge:**
```swift
Text("CUSTOM")
    .font(.caption2.weight(.semibold))
    .foregroundStyle(.white)
    .padding(.horizontal, 6)
    .padding(.vertical, 2)
    .background(
        Capsule()
            .fill(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    )
```

### **Floating Action Button:**
```swift
Button {
    showCreateExercise = true
} label: {
    Image(systemName: "plus")
        .font(.title2.weight(.semibold))
        .foregroundColor(.white)
        .frame(width: 56, height: 56)
        .background(
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
}
```

---

## ⚠️ Important Notes

1. **Enum Storage:** Enums (MuscleGroup, Equipment) stored as raw String values for SwiftData
2. **Multi-line Text:** Instructions/tips stored as newline-separated strings
3. **Deletion Safety:** Always check history before hard delete
4. **Archive vs Delete:** Archive = soft delete (hide but preserve)
5. **Validation:** Duplicate names checked against built-in + custom exercises

---

## 🔍 Debugging

**Check if exercise is custom:**
```swift
let isCustom = CustomExerciseManager.isCustomExercise("Dragon Flag", context: context)
```

**Get exercise data:**
```swift
let muscles = CustomExerciseManager.getPrimaryMuscles(for: "Dragon Flag", context: context)
let instructions = CustomExerciseManager.getInstructions(for: "Dragon Flag", context: context)
let tips = CustomExerciseManager.getFormTips(for: "Dragon Flag", context: context)
```

**Check history:**
```swift
let count = exercise.historyCount(in: context)
print("Exercise has \(count) sets logged")
```

---

## 🎯 Future TODOs

- [ ] Settings section for archived exercises
- [ ] Edit custom exercises
- [ ] Export/import custom exercises
- [ ] Share exercises with friends
- [ ] Add images/videos to exercises
- [ ] Exercise categories/tags

---

## 📝 Testing Commands

```swift
// Create test exercise
let test = CustomExercise(
    name: "Test Exercise",
    primaryMuscle: .chest,
    equipment: .barbell,
    musclesDescription: "Chest, Shoulders"
)
context.insert(test)
try context.save()

// Query
let descriptor = FetchDescriptor<CustomExercise>()
let all = try context.fetch(descriptor)
print("Total custom exercises: \(all.count)")

// Delete
context.delete(test)
try context.save()
```

---

## ✅ Checklist

**Before Release:**
- [ ] Test creating exercise
- [ ] Test deleting exercise with no history (hard delete)
- [ ] Test deleting exercise with history (archive)
- [ ] Test custom badge appears
- [ ] Test integration with workout picker
- [ ] Test duplicate name validation
- [ ] Test CloudKit sync
- [ ] Test empty optional fields
- [ ] Test long exercise names
- [ ] Test special characters in names

---

**That's it! You're ready to ship custom exercises! 🚀**
