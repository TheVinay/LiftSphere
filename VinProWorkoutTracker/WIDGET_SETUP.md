# Widget Setup Instructions

## Adding the Widget Extension to Your Xcode Project

The widget code has been created in `WorkoutWidget.swift`, but you'll need to add a Widget Extension target to your project to make it work.

### Steps to Add Widget Extension:

1. **Add Widget Extension Target:**
   - In Xcode, go to File → New → Target
   - Select "Widget Extension"
   - Name it "LiftSphereWidget"
   - Uncheck "Include Configuration Intent" (we're using static widgets)
   - Click Finish

2. **Replace the Generated Widget Code:**
   - Xcode will create a widget file in the new extension folder
   - Replace its contents with the code from `WorkoutWidget.swift`
   - Or simply copy `WorkoutWidget.swift` into the widget extension target

3. **Add SwiftData Framework:**
   - Select your widget extension target
   - Go to "Frameworks and Libraries"
   - Add SwiftData framework

4. **Share Data Between App and Widget (Optional for v1.0):**
   For now, the widget shows placeholder data. To show real data:
   
   - Add an App Group:
     - Select your main app target → Signing & Capabilities → + Capability → App Groups
     - Add group: `group.com.yourcompany.liftsphere`
     - Do the same for your widget extension target
   
   - Update SwiftData container to use shared storage:
     ```swift
     let container = try! ModelContainer(
         for: Workout.self, SetEntry.self,
         configurations: ModelConfiguration(
             groupContainer: .identifier("group.com.yourcompany.liftsphere")
         )
     )
     ```

5. **Build and Run:**
   - Select your main app scheme
   - Build and run
   - Long-press on your home screen → Add Widget → LiftSphere

### Widget Features:

- **Small Widget:** Shows today's workout name and total workout count
- **Medium Widget:** Adds this week's volume stats
- **Large Widget:** Shows full stats with a cleaner layout

### Notes:

- Widgets update every hour by default
- For v1.0, the widget shows placeholder/sample data
- Future versions can integrate real workout data via shared App Group containers
- Widgets automatically adapt to Light/Dark mode

### Why Widgets?

Widgets provide quick access to your workout stats without opening the app:
- See today's planned workout
- Track weekly progress
- Quick motivation check from home screen
- Professional, polished app experience
