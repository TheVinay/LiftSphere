# LiftSphere - Version 1.0

**Your friendly fitness companion with powerful analytics**

LiftSphere is a comprehensive fitness tracking app designed with a focus on smart exercises and intelligent workout analytics. Track your progress, analyze muscle balance, and build strength safely.

---

## ✨ Features

### Core Functionality
- **Workout Logging**: Create and track workouts with exercises, sets, reps, and weight
- **Exercise Library**: Browse 100+ exercises with detailed muscle group and equipment information
- **SwiftData Persistence**: All data stored locally and securely on device
- **Smart Organization**: Workouts grouped by "This Week", "Last Week", and "Earlier"

### Workout Management
- **Quick Actions**: Swipe to complete, duplicate, archive, or delete workouts
- **Workout Templates**: Pre-built templates for Push, Pull, Legs, and more
- **Custom Workouts**: Build your own workouts with custom exercises
- **Repeat Workouts**: Duplicate previous workouts with one tap
- **Archive System**: Keep your workout list clean without losing data

### Analytics Dashboard
- **Muscle Distribution**: Visualize which muscle groups you're training
- **Volume Tracking**: Monitor total training volume over time
- **Weekly Summaries**: Compare this week vs last week
- **Consistency Calendar**: See your workout frequency at a glance
- **Muscle Balance Alerts**: Get notified about undertrained muscle groups
- **Coach Recommendations**: AI-powered suggestions for balanced training
- **Top Exercises**: See which exercises you perform most
- **Muscle Heatmap**: Visual representation of muscle activation

### Profile & Settings
- **Personal Profile**: Track total workouts, followers, and following
- **Profile Analytics**: 30-day volume trends and top exercises
- **Theme Selection**: Light, Dark, or System appearance
- **Customizable Settings**: Archive visibility, delete confirmations, and more

### Data Management
- **Export Options**: 
  - Detailed CSV (all sets and exercises)
  - Summary CSV (workout overview)
  - JSON (complete backup)
- **Data Portability**: Export your data anytime for backup or analysis
- **No Lock-in**: Your data belongs to you

### User Experience
- **Onboarding**: First-launch tutorial with sample workout option
- **Empty States**: Helpful guidance when starting out
- **Haptic Feedback**: Tactile responses for key actions
- **Accessibility**: VoiceOver labels and Dynamic Type support
- **Error Handling**: Graceful error messages and recovery

### Home Screen Widgets (iOS 17+)
- **Small Widget**: Today's workout and total count
- **Medium Widget**: Add weekly volume stats
- **Large Widget**: Full dashboard with beautiful layout
- See setup instructions in `WIDGET_SETUP.md`

---

## 📱 Requirements

- iOS 17.0 or later
- iPhone or iPad
- Xcode 15+ (for development)

---

## 🏗️ Architecture

### Tech Stack
- **SwiftUI**: Modern declarative UI
- **SwiftData**: Persistent storage with relationships
- **Swift Charts**: Beautiful data visualizations
- **WidgetKit**: Home screen widgets
- **Sign in with Apple**: Privacy-focused authentication

### Data Models
```swift
@Model class Workout {
    var date: Date
    var name: String
    var isCompleted: Bool
    var isArchived: Bool
    var mainExercises: [String]
    var sets: [SetEntry]
    // ... more properties
}

@Model class SetEntry {
    var exerciseName: String
    var weight: Double
    var reps: Int
    var timestamp: Date
}
```

### Project Structure
```
LiftSphere/
├── Models/
│   └── Models.swift              # Core SwiftData models
├── Views/
│   ├── RootView.swift            # App entry with onboarding check
│   ├── RootTabView.swift         # Main tab navigation
│   ├── ContentView.swift         # Workout list
│   ├── WorkoutDetailView.swift   # Workout editing and logging
│   ├── AnalyticsView.swift       # Charts and insights
│   ├── ProfileView.swift         # User profile
│   ├── LearnView.swift           # Exercise library
│   └── SettingsView.swift        # App settings
├── Onboarding/
│   └── OnboardingView.swift      # First-time user experience
├── Legal/
│   ├── PrivacyPolicyView.swift   # Privacy policy
│   └── TermsOfServiceView.swift  # Terms of service
├── Utilities/
│   ├── ExerciseLibrary.swift     # Exercise database
│   ├── WorkoutGenerator.swift    # Template generation
│   └── WorkoutExportSupport.swift # Export functionality
└── Widgets/
    └── WorkoutWidget.swift       # Home screen widgets
```

---

## 🚀 Getting Started

### For Users
1. Download from the App Store (coming soon)
2. Complete the onboarding tutorial
3. Create your first workout or use a template
4. Log your sets during your workout
5. View analytics to track progress

### For Developers
1. Clone the repository
2. Open `VinProWorkoutTracker.xcodeproj` in Xcode 15+
3. Build and run on simulator or device
4. (Optional) Add widget extension - see `WIDGET_SETUP.md`

---

## 📊 Export Formats

### Detailed CSV
Contains every set from every workout:
```csv
Date,Workout Name,Exercise,Set Number,Weight,Reps,Volume,Duration (Warmup),Duration (Core),Duration (Stretch)
2024-12-20,Push Day,Bench Press,1,135,10,1350,5,5,5
```

### Summary CSV
High-level workout overview:
```csv
Date,Workout Name,Total Sets,Total Volume,Completed,Archived,Warmup (min),Core (min),Stretch (min)
2024-12-20,Push Day,12,5420,Yes,No,5,5,5
```

### JSON
Complete backup of all workout data with full fidelity.

---

## 🔒 Privacy & Security

- **Local-First**: All data stored on your device
- **No Cloud Sync**: Your data never leaves your device (unless you export it)
- **No Analytics Tracking**: We don't collect usage data
- **Sign in with Apple**: Optional, privacy-focused authentication
- **Open Data**: Export your data anytime in multiple formats

See `PrivacyPolicyView.swift` for full privacy policy.

---

## 🛣️ Roadmap

### Version 1.1
- [ ] HealthKit integration
- [ ] Apple Watch companion app
- [ ] Real-time widget data (via App Groups)
- [ ] Rest timer between sets
- [ ] Personal records (PRs) tracking

### Version 1.2
- [ ] Body weight tracking
- [ ] Progress photos
- [ ] Custom exercise creation
- [ ] Workout notes and tags
- [ ] 1RM calculator

### Version 2.0
- [ ] iCloud sync
- [ ] Social features (share workouts)
- [ ] Workout programs and plans
- [ ] Video exercise demonstrations
- [ ] Advanced analytics and AI insights

---

## 📝 Version History

### Version 1.0.0 (December 2024)
- Initial release
- Core workout tracking
- Comprehensive analytics
- Exercise library with 100+ exercises
- Data export in CSV and JSON
- Onboarding experience
- Privacy policy and terms
- Home screen widgets
- Archive system
- Profile with stats

---

## 🤝 Contributing

This is a personal project by Vin. If you have feedback or suggestions, please reach out through the App Store.

---

## 📄 License

Copyright © 2024 Vin. All rights reserved.

---

## 🙏 Acknowledgments

- Built with SwiftUI and SwiftData
- Exercise data curated for back safety
- Design inspired by modern iOS patterns
- Chart visualizations powered by Swift Charts

---

## 📧 Support

For support, questions, or feedback:
- Contact through the App Store
- See Privacy Policy and Terms of Service in the app

---

**LiftSphere - Build strength, track progress, protect your back.** 💪
