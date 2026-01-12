# FEATURE MANIFEST - LiftSphere
**Version 1.0 - Complete Feature Inventory**
*Last Updated: January 9, 2026*

---

## 📋 PURPOSE
This document is a comprehensive, exhaustive inventory of every feature, screen, component, and capability in the LiftSphere app. Use this as a reference for feature discussions, version planning, and ensuring no duplicate work.

---

## 🏗️ ARCHITECTURE & DATA MODELS

### SwiftData Models

#### **Workout** (`Models.swift`)
- **Properties:**
  - `date: Date` - When workout occurred
  - `name: String` - Workout name/title
  - `isCompleted: Bool` - Completion status
  - `isArchived: Bool` - Archive status
  - `warmupMinutes: Int` - Warmup duration
  - `coreMinutes: Int` - Core workout duration
  - `stretchMinutes: Int` - Stretch duration
  - `mainExercises: [String]` - List of primary exercises
  - `coreExercises: [String]` - List of accessory/core exercises
  - `stretches: [String]` - List of stretches
  - `notes: String` - User notes field
  - `sets: [SetEntry]` - Relationship to logged sets (cascade delete)
- **Computed Properties:**
  - `totalVolume: Double` - Sum of all set volumes (weight × reps)
- **Features:**
  - CloudKit sync support (with local fallback)
  - Cascade deletion of related sets

#### **SetEntry** (`Models.swift`)
- **Properties:**
  - `exerciseName: String` - Exercise name
  - `weight: Double` - Weight used (kg)
  - `reps: Int` - Repetitions performed
  - `timestamp: Date` - When set was logged
- **Computed Properties:**
  - `volume: Double` - Set volume (weight × reps)

#### **CustomWorkoutTemplate** (`Models.swift`)
- **Properties:**
  - `name: String` - Template name
  - `dayOfWeek: String?` - Optional day assignment
  - `createdDate: Date` - Creation timestamp
  - `warmupMinutes: Int` - Template warmup duration
  - `coreMinutes: Int` - Template core duration
  - `stretchMinutes: Int` - Template stretch duration
  - `mainExercises: [String]` - Template main exercises
  - `coreExercises: [String]` - Template accessory exercises
  - `stretches: [String]` - Template stretches
- **Methods:**
  - `toWorkout() -> Workout` - Convert template to workout instance
- **Features:**
  - User-created custom workout templates
  - Can be reused to create new workouts

### Storage Configuration
- **Primary:** CloudKit automatic sync
- **Fallback 1:** Local-only storage
- **Fallback 2:** In-memory storage (last resort)
- **Schema:** Workout, SetEntry, CustomWorkoutTemplate

---

## 🔐 AUTHENTICATION & USER MANAGEMENT

### Sign In with Apple (`SignInView.swift`, `AuthenticationManager.swift`)
- **Features:**
  - Sign in with Apple integration
  - Privacy-focused authentication
  - User credential management
  - Authentication state management
- **User Properties:**
  - User ID
  - Email (optional)
  - Full name (optional)
  - Display name (custom)
- **Features:**
  - Automatic name prompt for new users
  - Display name customization
  - Authentication persistence
  - Name sync between auth and profile

### Display Name Flow (`RootView.swift`)
- **First Launch for New Users:**
  1. Sign in with Apple
  2. Name prompt sheet (pre-filled if available)
  3. Onboarding screens
  4. Main app
- **Features:**
  - Suggested name from Apple ID
  - Custom name input
  - Can be changed later in profile
  - Syncs to display name storage

---

## 🎯 APP NAVIGATION & STRUCTURE

### Root Structure (`VinProWorkoutTrackerApp.swift`, `RootView.swift`)
- **App Entry Point:**
  - Authentication check
  - Onboarding check
  - Theme application
- **Onboarding Flow:**
  - Shown once on first launch
  - Skippable after initial view
  - Can create sample workout
- **Name Prompt Flow:**
  - Shown for new authenticated users
  - Pre-fills suggested name
  - Mandatory before onboarding

### Tab Navigation (`RootTabView.swift`)
5 main tabs:
1. **Profile** - User profile and stats
2. **Workouts** - Workout list and management
3. **Analytics** - Charts and insights
4. **Friends** - Social features
5. **Learn** - Exercise library and education

---

## 👤 PROFILE TAB

### Profile View (`ProfileView.swift`)

#### **Header Section**
- **Avatar Display:**
  - Circle avatar with user initial
  - Auto-generated from display name
  - Blue background
  - 72x72 size
  
- **Display Name Logic (cascading priority):**
  1. Stored display name (`@AppStorage("displayName")`)
  2. Apple ID name from AuthenticationManager
  3. Email username (formatted and capitalized)
  4. Device name (strips "'s iPhone" suffix)
  5. Fallback: "V"

- **Stats Row:**
  - Total workouts count (from SwiftData)
  - Followers count (stored in AppStorage)
  - Following count (stored in AppStorage)

- **Bio & Link:**
  - Optional bio text (`@AppStorage("profile.bio")`)
  - Optional clickable link (`@AppStorage("profile.link")`)
  - Only shows section if either field has content

#### **Profile Cards (All Collapsible)**

**1. Apple Health Integration Card**
- Links to HealthStatsView
- Gradient heart icon (red to pink)
- "View body composition & activity" subtitle
- Always visible (not collapsible)
- Navigates via sheet presentation

**2. Last 30 Days Volume Card**
- Collapsible (state: `isVolumeCardExpanded`)
- Line + area chart showing daily volume
- Filters sets from last 30 days
- Groups by day and sums volume
- Shows "No sets logged" if empty
- Chart height: 160pt
- Blue color scheme

**3. Weekly Summary Card**
- Collapsible (state: `isWeeklySummaryExpanded`)
- Shows:
  - This week workout count
  - This week total volume
  - Percentage change vs last week
  - Up/down arrow indicator (green/red)
- Compares current week to previous week
- 2-column grid layout

**4. Top Exercises (All Time) Card**
- Collapsible (state: `isTopExercisesExpanded`)
- Horizontal bar chart of top 3 exercises by volume
- Lists exercise names with volume numbers
- Sorts all-time sets by exercise volume
- Shows "No sets logged" if empty
- Green color scheme
- Dynamic height based on exercise count

**5. Workout Streak Card**
- Collapsible (state: `isStreakCardExpanded`)
- **Main Display:**
  - Large flame icon (orange/red gradient if active, gray if 0)
  - Current streak number (large, bold)
  - "Day Streak" or "Days Streak" label
- **Mini Stats Grid (3 columns):**
  - Best streak (trophy icon, yellow)
  - This month count (calendar icon, blue)
  - This week count (running icon, green)
- **Streak Logic:**
  - Current: consecutive days from most recent workout
  - Allows 1-day gap (yesterday or today counts)
  - Longest: all-time best consecutive days
  - Resets if gap > 1 day

#### **Toolbar Actions**
- **Edit Profile Button** (pencil icon)
  - Opens EditProfileView sheet
  - Allows editing name, bio, link
  - No bindings passed (uses @AppStorage directly)
  
- **Settings Button** (gear icon)
  - Opens SettingsView sheet

#### **Data Queries**
- `@Query` all workouts (sorted by date, descending)
- `@Query` all sets (sorted by timestamp, descending)
- Filters in-memory for date ranges

#### **Profile Data Storage**
All stored in `@AppStorage`:
- `displayName` - User's chosen name
- `isSignedIn` - Sign-in status flag
- `profile.bio` - Profile biography
- `profile.link` - Profile link/URL
- `profile.followers` - Follower count (manual)
- `profile.following` - Following count (manual)

---

## 💪 WORKOUTS TAB

### Workout List View (`ContentView.swift`)

#### **Display Logic**
- **Empty State:**
  - Shows when no workouts exist (filtered by archive setting)
  - Custom empty state view with call-to-action
  
- **Workout List:**
  - Sorted by date (newest first)
  - Grouped by time periods (auto-grouped)
  - Shows archived if `showArchivedWorkouts` setting enabled

#### **Bulk Selection Mode**
- **Activation:**
  - "Select" button in toolbar (toggles to "Done")
  - Tappable checkboxes appear on each workout
  
- **Features:**
  - Multi-select workouts with checkboxes
  - Select All / Deselect All menu
  - Bulk delete with confirmation
  - Cancel to exit mode
  - Visual selection state tracking
  - State: `Set<Workout.ID>` for selected items

#### **Toolbar Actions**

**Left Side (Menu):**
- **Normal Mode:**
  - Import Workouts (square.and.arrow.down icon)
  - Export All (square.and.arrow.up icon)
  
- **Selection Mode:**
  - Select All
  - Deselect All
  - Cancel (role: cancel)

**Right Side:**
- **Select/Done Toggle Button**
  - Shows only when workouts exist
  - Toggles selection mode
  - Clears selections when exiting

*[CONTINUED IN NEXT CHUNK - Need to document workout row actions, new workout, workout detail, etc.]*

---

**🔄 AUDIT STATUS: 30% Complete**
- ✅ Data models documented
- ✅ Authentication documented
- ✅ App structure documented
- ✅ Profile tab complete
- ⏳ Workouts tab (in progress - 40%)
- ⏳ Analytics tab
- ⏳ Friends tab
- ⏳ Learn tab
- ⏳ Settings & utilities
- ⏳ Export features
- ⏳ HealthKit integration
- ⏳ Helper views & components

---

*Type "yes" or "continue" for Chunk 3...*
