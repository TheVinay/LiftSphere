# VinPro / LiftSphere - Complete Project Manifest

**Last Updated:** January 17, 2026 (Saturday Evening)  
**Manifest Version:** 2.6  
**Purpose:** Comprehensive documentation of all files, features, models, and cross-references

**🆕 LATEST UPDATES (January 18, 2026 - Sunday Evening):**
- **WEIGHT UNIT PREFERENCE:**
  - ✅ Added weight unit toggle in Settings → Workouts (lbs ↔ kg)
  - ✅ Updates display throughout app: ExerciseHistoryView, WorkoutDetailView
  - ✅ Shows "Weight (lbs)" or "Weight (kg)" in TextField placeholders
  - ✅ Shows "80.0 lbs × 10" or "80.0 kg × 10" in set history
  - ✅ Shows "Last: 80.0 lbs × 10" and "PR: 90 lbs × 2" in workout rows
  - ✅ Data stored as numbers (no conversion), just display preference
  - ✅ Persisted in AppStorage("weightUnit"), defaults to "lbs"
  - ✅ Zero breaking changes - UI-only update
- **BODYWEIGHT EXERCISE AUTO-FILL:**
  - ✅ Weight field now auto-fills with user's bodyweight from HealthKit
  - ✅ Works for ALL bodyweight exercises (equipment == .bodyweight)
  - ✅ Includes: Push-Ups, Squats, Burpees, Planks, Dead Bug, Bird Dog, etc.
  - ✅ Smart detection via ExerciseTemplate.usesBodyweight property
  - ✅ Only pre-fills when weight field is empty (user can still override)
  - ✅ Zero breaking changes - no data model modifications
  - ✅ Uses existing HealthKitManager integration

**Earlier (January 17, 2026):**
- **TABATA HIIT WORKOUTS ADDED:**
  - ✅ Added comprehensive Tabata HIIT program to Browse Workouts
  - ✅ 8 different Tabata workouts: Core Crusher, Full Body Burn, Leg Destroyer, Upper Body Blast, Cardio Crusher, Total Body Tabata, Ab Ripper, Power Builder
  - ✅ Each workout follows classic Tabata protocol: 8 rounds × (20s work / 10s rest) = 4 minutes
  - ✅ All bodyweight exercises, no equipment needed
  - ✅ Includes proper warmup (3 min) and stretching (3 min)
  - ✅ Located in BrowseWorkoutsViewNew with timer icon
- **JSON IMPORT ENHANCEMENTS:**
  - ✅ Made JSON import available on real devices (removed simulator-only restriction)
  - ✅ Replaced read-only Text with editable TextEditor for manual paste
  - ✅ Added comprehensive validation to prevent crashes on malformed JSON
  - ✅ Added detailed error messages for JSON parsing failures
  - ✅ Added "Load Sample JSON" button for easy testing
  - ✅ Enhanced clipboard debugging with detailed logging
  - ✅ Validates workout structure, exercise names, weight/rep ranges, duration values
  - ✅ Shows helpful error messages instead of crashing

**Earlier (January 14, 2026 - Late Evening):**
- **SOCIAL MODELS COMPLETION:**
  - ✅ Added FollowRelationship model to SocialModels.swift (was missing!)
  - ✅ Documented complete social data model architecture
  - ✅ Added comprehensive SocialService documentation to manifest
  - ✅ Clarified distinction between FollowRelationship (active) and FriendRelationship (legacy)
  - ✅ Documented Apple ID integration system with caching
  - ✅ Documented CloudKit schema requirements
  - 🔧 Fixed: "Cannot find 'FollowRelationship' in scope" error in SocialService.swift
  - 📝 Manifest now fully documents all social networking components

**Earlier (January 14, 2026 - Evening):**
- **SOCIAL PRIVACY CONTROLS ADDED:**
  - ✅ Created SocialPrivacySettings.swift - Complete privacy model with presets
  - ✅ Created SocialPrivacySettingsView.swift - Beautiful privacy UI with quick presets
  - ✅ Added privacy controls to Settings → Social Privacy
  - ✅ Added quick access in Friends tab (⋯ menu)
  - ✅ Users can control: profile visibility, stats sharing, workout sharing, social interactions
  - ✅ Three presets: Public, Friends Only, Private
  - ✅ Real-time privacy summary showing what others can see
- **SOCIAL FEATURES ROADMAP:**
  - Created SOCIAL_IMPLEMENTATION_ROADMAP.md
  - Documented complete plan for finishing social features
  - Privacy foundation complete, integration next

**Earlier Today (January 14, 2026):**
- **SOCIAL FEATURES FIXED:**
  - ✅ Created SocialModels.swift with proper data models
  - ✅ Fixed profile persistence by linking to Apple ID (CloudKit userRecordID)
  - ✅ Added local caching with UserDefaults (profiles persist offline)
  - ✅ Added username uniqueness validation
  - ✅ Profiles now properly tied to authenticated iCloud user
  - ✅ fetchCurrentUserProfile() now queries by appleUserID instead of grabbing first record
  - ✅ Added FollowRelationship model (simplified following, no bidirectional friends)
  - ✅ Improved error handling with descriptive SocialError cases
  - ✅ Added automatic cache management (load on init, save on create/update)
  - ✅ Added simulator debug mode for UI testing
- **AUTHENTICATION UX FIXES:**
  - Fixed "Guest User" incorrectly showing when signed in with Apple ID
  - Changed detection logic from `userEmail.isEmpty` to `userID.hasPrefix("guest-")`
  - Guest users now see "Sign in with Apple" button in Account Settings (not "Sign Out")
  - Apple ID users see "Sign Out" and "Delete Account" options
  - Updated sign-in sheet to use AuthenticationManager properly
  - Added AuthenticationServices import to SettingsView
- **EMPTY STATE IMPROVEMENTS:**
  - Added "Browse Workouts" button to empty state in ContentView
  - First-time users now see both "Create Workout" (primary) and "Browse Workouts" (secondary) options
  - Matches the button styling from WorkoutCreationButtonRow
  - Makes it easier for new users to discover pre-made workout templates

**Previous Updates (January 10, 2026):**
- **DARK MODE SUPPORT:** Complete dark mode implementation across all views
- Fixed icon and text colors in SettingsView (all labels now use `.foregroundStyle(.primary)`)
- Fixed bulk action buttons in ContentView (Archive, Unarchive, Export now blue)
- Fixed "Add exercise" buttons in WorkoutDetailView (Primary & Accessory editors)
- Fixed "Add set" button and Exercise Information icon in ExerciseHistoryView
- Fixed all Analytics collapsible section headers and text colors
- Converted all `.foregroundColor()` to `.foregroundStyle()` for better dark mode adaptation
- Fixed RadarChart labels and removed duplicate modifiers
- Fixed time range picker tint in AnalyticsView
- Added `.tint(.blue)` to TabView for consistent tab bar colors in dark mode
- **UI IMPROVEMENTS:**
- Updated SettingsView branding: "LiftSphere - Train smarter, track better."
- Changed "Health & Fitness" to "Apple Health"
- Made "Browse Workouts" button match "Repeat Recent" style (blue outline)
- Simplified CreateWorkoutView: removed "Options" header, auto-expanded generator, removed duration sliders
- Save button disabled until workout generated in CreateWorkoutView
- **BROWSE WORKOUTS UX:**
- Updated BrowseWorkoutsViewNew with collapsible days using DisclosureGroup
- Added visual selection indicator (blue checkmark) for selected day
- Dynamic workout name updates based on selected day
- Added "Done" button to confirm workout creation (disabled until day selected)
- Cleaned up debug statements

---

## 📋 TABLE OF CONTENTS
1. [Project Overview](#project-overview)
2. [Dark Mode Implementation](#dark-mode-implementation)
3. [Data Models](#data-models)
4. [Views & UI Components](#views--ui-components)
5. [Business Logic & Managers](#business-logic--managers)
6. [Export & Sharing](#export--sharing)
7. [Cross-References & Dependencies](#cross-references--dependencies)
8. [Feature Inventory](#feature-inventory)
9. [File Directory](#file-directory)

---

## PROJECT OVERVIEW

**App Name:** LiftSphere  
**Tagline:** Train smarter, track better.  
**Platform:** iOS 17+  
**Architecture:** SwiftUI-based with UIKit integration  
**Data Persistence:** SwiftData with CloudKit sync (3-tier fallback)  
**Primary Purpose:** Comprehensive workout tracking with analytics, social features, and Apple Health integration

**Design System:**
- Primary colors: Blue/Purple gradients
- Accent: Orange for accessory work, Green for completion/stretches
- Full dark mode support with adaptive colors
- SF Symbols icons throughout

---

## DARK MODE IMPLEMENTATION

**Status:** ✅ Fully implemented across all views (January 10, 2026)

### Color Strategy:
- **`.foregroundStyle(.primary)`** - Main text and icons (adapts black/white)
- **`.foregroundStyle(.secondary)`** - Subtle text and inactive elements
- **`.foregroundStyle(.blue)` / `.tint(.blue)`** - Interactive elements and buttons
- **Avoid `.foregroundColor()`** - Replaced with `.foregroundStyle()` for better adaptation

### Files Updated for Dark Mode:

#### SettingsView.swift
- All navigation icons use `.foregroundStyle(.primary)`:
  - Account, Workouts, Appearance, Data Export & Backup, Help & Support, Privacy Policy, Terms of Service
- Branding updated: "LiftSphere - Train smarter, track better."
- "Health & Fitness" renamed to "Apple Health"

#### RootTabView.swift
- Added `.tint(.blue)` to TabView for consistent selected tab color
- Prevents extremely dark selected tabs in dark mode

#### ContentView.swift
- Bulk action buttons (Archive, Unarchive, Export) use `.foregroundStyle(.blue)`
- Delete button retains destructive red color

#### WorkoutDetailView.swift
- "Add exercise" buttons in PrimaryPlanEditorView and AccessoryEditorView use `.foregroundStyle(.blue)`

#### ExerciseHistoryView.swift
- "Add set" button uses `.foregroundStyle(.blue)`
- Exercise Information DisclosureGroup label uses `.foregroundStyle(.blue)`

#### AnalyticsView.swift
- All collapsible section headers use `.foregroundStyle(.primary)` with `.buttonStyle(.plain)`
- Time range picker uses `.tint(.primary)` for dropdown visibility
- Converted all icon colors:
  - Training Insights: `.foregroundStyle(.blue)`
  - Needs Attention: `.foregroundStyle(.orange)`
  - Severity dots: `.foregroundStyle(severity.color)`
  - Streak icons (Trophy, Calendar, Figure Run): `.foregroundStyle(.yellow/.blue/.green)`
  - Clock icon: `.foregroundStyle(.secondary)`
- Fixed RadarChart labels: removed duplicate `.font()` modifier
- All `.foregroundColor()` converted to `.foregroundStyle()`

#### WorkoutCreationButtonRow.swift
- "Browse Workouts" button now matches "Repeat Recent" style (blue outline)

### Dark Mode Testing Checklist:
- [x] Settings page icons visible
- [x] Bulk action buttons visible
- [x] Add exercise buttons visible
- [x] Add set button visible
- [x] Analytics headers visible
- [x] Analytics text and icons visible
- [x] Tab bar selected items visible
- [x] Browse Workouts button visible

---

## DATA MODELS

### WorkoutExportSupport.swift (Current File)

#### `WorkoutExportFile`
- **Type:** Codable struct
- **Purpose:** Container for JSON export
- **Properties:**
  - `exportedAt: Date` - Timestamp of export
  - `workouts: [ExportedWorkout]` - Array of exported workouts

#### `ExportedWorkout`
- **Type:** Codable struct  
- **Purpose:** Serializable representation of Workout for export
- **Properties:**
  - `date: Date`
  - `name: String`
  - `warmupMinutes: Int`
  - `coreMinutes: Int`
  - `stretchMinutes: Int`
  - `mainExercises: [String]`
  - `coreExercises: [String]`
  - `stretches: [String]`
  - `sets: [ExportedSet]`
- **Initializer:** `init(from workout: Workout)` - Maps from core Workout model
- **Dependencies:** Requires `Workout` model (external)

#### `ExportedSet`
- **Type:** Codable struct
- **Purpose:** Serializable representation of workout set
- **Properties:**
  - `exerciseName: String`
  - `weight: Double`
  - `reps: Int`
  - `timestamp: Date`

#### `ShareItem`
- **Type:** Identifiable struct
- **Purpose:** Wrapper for shareable URLs
- **Properties:**
  - `id: UUID` (automatic)
  - `url: URL`

---

## BUSINESS LOGIC & MANAGERS

### CSVExporter (struct)
**Location:** WorkoutExportSupport.swift

#### Methods:
1. **`exportToCSV(workouts: [Workout]) -> String`**
   - Exports detailed workout data with sets
   - CSV Headers: Date, Workout Name, Exercise, Set Number, Weight, Reps, Volume, Duration (Warmup), Duration (Core), Duration (Stretch)
   - Groups sets by exercise name
   - Handles empty workouts
   - Uses ISO8601 date formatting

2. **`exportSummaryCSV(workouts: [Workout]) -> String`**
   - Exports high-level workout summaries
   - CSV Headers: Date, Workout Name, Total Sets, Total Volume, Completed, Archived, Warmup (min), Core (min), Stretch (min)
   - Uses ISO8601 date formatting

### PDFExporter (struct)
**Location:** WorkoutExportSupport.swift  
**Dependencies:** UIKit, PDFKit

#### Methods:
1. **`createPDF(for workouts: [Workout]) throws -> Data`**
   - Creates multi-page PDF (one page per workout)
   - **Page Format:** A4 size (595 x 842 points)
   - **Metadata:** Creator, Author, Title
   - **Layout Components:**
     - Title (24pt bold)
     - Date (12pt, long format)
     - Summary box (rounded rect, gray background) with:
       - Total sets
       - Total volume
       - Duration breakdown
     - Main Exercises section (with sets breakdown)
     - Accessory/Core section (with sets breakdown)
     - Stretches section
     - Notes section
     - Footer with page numbers
   - **Fonts Used:**
     - Title: 24pt bold
     - Heading: 16pt bold
     - Body: 12pt regular
     - Caption: 10pt regular
   - **Margins:** 40pt left, 40pt top

### ExportManager (struct)
**Location:** WorkoutExportSupport.swift

#### Enums:
- **`ExportFormat`**
  - Cases: `.json`, `.detailedCSV`, `.summaryCSV`, `.pdf`

#### Methods:
1. **`createExportFile(workouts: [Workout], format: ExportFormat) throws -> URL`**
   - Creates temporary file for export
   - File naming pattern: `liftsphere_workouts_{timestamp}.json` (etc.)
   - Uses `FileManager.default.temporaryDirectory`
   - Returns URL to temporary file

#### Error Types:
- **`ExportError: LocalizedError`**
  - `.encodingFailed` - "Failed to encode workout data"
  - `.noWorkouts` - "No workouts to export"

---

## VIEWS & UI COMPONENTS

### ActivityView (UIViewControllerRepresentable)
**Location:** WorkoutExportSupport.swift  
**Purpose:** SwiftUI wrapper for UIActivityViewController (iOS share sheet)
- **Properties:**
  - `activityItems: [Any]` - Items to share

---

## CROSS-REFERENCES & DEPENDENCIES

### External Model Dependencies (Not Yet Documented)
- **`Workout` model** - Referenced extensively but not defined in current file
  - Expected properties:
    - `date: Date`
    - `name: String`
    - `warmupMinutes: Int`
    - `coreMinutes: Int`
    - `stretchMinutes: Int`
    - `mainExercises: [String]`
    - `coreExercises: [String]`
    - `stretches: [String]`
    - `sets: [WorkoutSet]` (or similar)
    - `isCompleted: Bool`
    - `isArchived: Bool`
    - `totalVolume: Double` (computed?)
    - `notes: String`

### Framework Dependencies
- SwiftUI
- Foundation
- UniformTypeIdentifiers
- UIKit
- PDFKit

---

---

## DATA MODELS (CONTINUED)

### Models.swift

#### `SetEntry` (@Model - SwiftData)
- **Type:** SwiftData model class
- **Purpose:** Individual set record (weight × reps)
- **Properties:**
  - `exerciseName: String`
  - `weight: Double`
  - `reps: Int`
  - `timestamp: Date`
- **Computed Properties:**
  - `volume: Double` - Returns weight × reps
- **Relationships:** Owned by `Workout` via cascade delete

#### `Workout` (@Model - SwiftData)
- **Type:** SwiftData model class (PRIMARY DATA MODEL)
- **Purpose:** Core workout record with plan, execution, and metadata
- **Properties:**
  - `date: Date`
  - `name: String`
  - `isCompleted: Bool` (default: false)
  - `isArchived: Bool` (default: false)
  - `warmupMinutes: Int`
  - `coreMinutes: Int`
  - `stretchMinutes: Int`
  - `mainExercises: [String]` - Array of exercise names
  - `coreExercises: [String]` - Accessory/core exercises
  - `stretches: [String]` - Stretch names
  - `notes: String` (default: "")
  - `sets: [SetEntry]` - @Relationship with cascade delete
- **Computed Properties:**
  - `totalVolume: Double` - Sum of all sets' volume
- **Key Behaviors:**
  - Cascade deletes all SetEntry when deleted
  - Supports archiving without deletion
  - Completion tracking for HealthKit integration

#### `CustomWorkoutTemplate` (@Model - SwiftData)
- **Type:** SwiftData model class
- **Purpose:** Reusable workout templates
- **Properties:**
  - `name: String`
  - `dayOfWeek: String?` - Optional day assignment
  - `createdDate: Date`
  - `warmupMinutes: Int`
  - `coreMinutes: Int`
  - `stretchMinutes: Int`
  - `mainExercises: [String]`
  - `coreExercises: [String]`
  - `stretches: [String]`
- **Methods:**
  - `toWorkout() -> Workout` - Converts template to new Workout instance

---

## APP ARCHITECTURE
### VinProWorkoutTrackerApp.swift (@main)
- **Type:** App entry point
- **SwiftData Schema:** Workout, SetEntry, CustomWorkoutTemplate
- **Persistence Strategy:**
  1. Attempts CloudKit sync (`.automatic`)
  2. Falls back to local-only if CloudKit fails
  3. Last resort: in-memory storage
- **Authentication:** Uses `AuthenticationManager` (Observable)
- **Theme Support:** AppStorage with 3 modes (0=System, 1=Light, 2=Dark)
- **Root Logic:**
  - Shows `SignInView` if not authenticated
  - Shows `RootView` if authenticated
- **Model Container:** Shared across app via `.modelContainer()`

### AuthenticationManager.swift (@Observable)
- **Type:** Observable class
- **Purpose:** Manages Sign in with Apple authentication state
- **Properties:**
  - `isAuthenticated: Bool`
  - `userID: String`
  - `userName: String`
  - `userEmail: String`
  - `needsNamePrompt: Bool`
- **Methods:**
  - `signOut()` - Clears auth state
  - `handleSignInWithApple(result:)` - Processes Apple ID credentials
  - `setDisplayName(_:)` - Sets user display name
  - `debugSkipSignIn()` - Simulator-only bypass (conditional compilation)
  - `loadAuthState()` / `saveAuthState()` - UserDefaults persistence
- **Name Handling Logic:**
  - Extracts from Apple ID credentials (first sign-in only)
  - Falls back to email-based name extraction
  - Triggers name prompt if unavailable
- **Persistence:** UserDefaults keys:
  - `isAuthenticated`, `userID`, `userName`, `userEmail`, `needsNamePrompt`

---

## VIEWS & UI COMPONENTS (DETAILED)

### RootView.swift
- **Purpose:** Post-authentication root with onboarding orchestration
- **State Management:**
  - `@AppStorage("hasCompletedOnboarding")`
  - `@AppStorage("displayName")`
  - `@State` for sheet presentation
- **Flow Logic:**
  1. Check if name prompt needed → show name sheet
  2. Else check if onboarding needed → show onboarding
  3. Else sync display name and show main app
- **Sheets:**
  - Name prompt sheet (interactiveDismissDisabled)
  - Onboarding sheet (interactiveDismissDisabled)
- **Contains:** `RootTabView` as main content
- **Name Prompt Features:**
  - Gradient icon (blue→purple)
  - TextField with pre-filled suggestion
  - Continue button (disabled if empty)
  - Syncs to both AuthManager and displayName

### SignInView.swift
- **Purpose:** Initial sign-in screen
- **Features:**
  - Gradient app icon/logo
  - App branding text
  - Sign in with Apple button (.black style)
  - Privacy statement text
  - **Simulator Debug Button:** "Skip Sign In" (conditional compilation)
- **Design:** Centered vertical layout with spacers
- **Integration:** Calls `authManager.handleSignInWithApple()`

### RootTabView.swift
- **Purpose:** Main tab bar navigation
- **Tabs (5 total):**
  1. **Profile** - `ProfileView` (person.crop.circle)
  2. **Workouts** - `ContentView` (list.bullet.rectangle) ⭐ PRIMARY
  3. **Analytics** - `AnalyticsView` (chart.bar.xaxis)
  4. **Friends** - `FriendsView` (person.2.fill)
  5. **Learn** - `LearnView` (book.closed)

### OnboardingView.swift
- **Purpose:** 4-page onboarding flow
- **Pages:**
  1. Welcome to LiftSphere (intro)
  2. Smart Analytics (features)
  3. Exercise Library (education)
  4. Track Your Progress (tracking)
- **State:**
  - `@AppStorage("hasCompletedOnboarding")`
  - `currentPage: Int`
  - `showCreateSample: Bool`
- **Navigation:**
  - Custom page indicators (animated capsules)
  - Next button (1-3), Get Started (page 4)
  - Skip button on all pages
- **Sample Workout Creation:**
  - "Sample Push Day" workout
  - Includes 4 main exercises, 2 core, 2 stretches
  - Pre-populated with 5 sample sets
  - Uses ISO8601 timestamp offsets
- **Component:** `OnboardingPageView` - Individual page renderer
- **Component:** `OnboardingPage` - Data model for page content

### ContentView.swift (PRIMARY WORKOUT LIST)
- **Purpose:** Main workout list with comprehensive management
- **Query:** `@Query(sort: \Workout.date, order: .reverse)`
- **State Variables:**
  - `showArchivedWorkouts: Bool` (AppStorage)
  - `confirmBeforeDelete: Bool` (AppStorage)
  - `isSelecting: Bool` - Bulk selection mode
  - `selectedWorkouts: Set<Workout.ID>` - Selected IDs
  - `shareItem: ShareItem?` - Export sheet
  - `isImporting: Bool` - Import file picker
  - `pendingDelete: Workout?` - Delete confirmation
  - `showingBulkDeleteConfirmation: Bool`
  - `healthKitManager: HealthKitManager`

#### FEATURES:
1. **List Organization:**
   - "This Week" section
   - "Last Week" section
   - Monthly sections for older workouts (grouped, sorted descending)
   - Quick Repeat button at top
   - Empty state view with:
     - Gradient icon
     - "Create Workout" button (primary, gradient)
     - "Browse Workouts" button (secondary, blue outline)
     - Matches WorkoutCreationButtonRow styling

2. **Bulk Selection Mode:**
   - Toggle via "Select" button
   - Checkmark circles (Mail app style)
   - Bottom toolbar with actions:
     - Archive / Unarchive
     - Export
     - Delete (with confirmation if enabled)
   - Select All / Deselect All menu
   - Disables NavigationLinks during selection

3. **Swipe Actions:**
   - **Trailing (Right):** Complete, Duplicate, Delete
   - **Leading (Left):** Archive/Unarchive
   - Full swipe = complete action
   - Disabled during selection mode

4. **Import/Export:**
   - Export all workouts to JSON
   - Import JSON file with file picker
   - **🆕 Import from JSON String** (Added January 17, 2026):
     - Available on both simulator AND real devices (no longer simulator-only)
     - Editable TextEditor for direct paste (was read-only Text)
     - Native iOS paste support (long-press → Paste)
     - "Load Sample JSON" button for testing
     - Comprehensive validation prevents crashes
     - Detailed error messages for malformed JSON
     - Validates: structure, exercise names, weight/rep ranges, duration values
   - Bulk export selected workouts
   - Error/success alerts
   - Uses `ExportManager` and `WorkoutExportFile`

5. **HealthKit Integration:**
   - Saves workout when marked complete
   - Calculates total duration (warmup + core + stretch + estimated sets time)
   - Estimates 2 min per set
   - Comprehensive error logging
   - Checks HKHealthStore availability
   - Logs permission errors

6. **Workout Row Design:**
   - Gradient name (blue→purple)
   - Abbreviated date
   - Volume badge (orange gradient) with flame icon
   - Volume formatting (K notation for 1000+)
   - Checkmark seal for completed (green gradient)
   - Archived opacity (0.45)

7. **Toolbar Actions:**
   - Leading: Import/Export menu (when not selecting)
   - Leading: Edit menu with Select All/Deselect/Cancel (when selecting)
   - Trailing: "Select" / "Done" toggle
   - Trailing: "+" Add workout button

8. **Quick Repeat:**
   - Shows recent 10 workouts
   - Sheet with workout selection
   - Displays name, date, volume, exercise count
   - Creates duplicate with current date

9. **Methods:**
   - `toggleCompleted()` - Haptic + HealthKit save
   - `toggleArchive()` - Haptic feedback
   - `repeatWorkout()` - Duplicate with empty sets
   - `saveWorkoutToHealthKit()` - async HealthKit save
   - `handleDelete()` - Respects confirmation preference
   - `handleImport()` - Decodes WorkoutExportFile
   - **🆕 `handleJSONStringImport()`** - Validates and imports JSON with comprehensive error handling:
     - Validates JSON structure and data types
     - Checks workout names not empty
     - Validates duration ranges (0-999 minutes)
     - Validates weight (0-9999 kg) and reps (0-9999)
     - Provides detailed error messages on failure
     - Prevents crashes from malformed data
   - Bulk actions: archive, unarchive, delete, export

10. **Components:**
    - `QuickRepeatSheet` - Recent workouts selection
    - **🆕 `JSONImportSheet`** - JSON string import interface:
      - Editable TextEditor (not read-only)
      - "Paste from Clipboard" button with enhanced debugging
      - "Load Sample JSON" button for testing
      - Shows clipboard diagnostics on paste failure
      - Clear button to reset text
    - `View.if()` extension - Conditional modifiers

---

### 🆕 WORKOUT CREATION REFACTOR (v2.0 - January 2026)

#### WorkoutCreationButtonRow.swift
- **Purpose:** Three-button entry point for workout creation
- **Location:** Top of ContentView workout list
- **Design:** Apple-style button hierarchy
- **Buttons:**
  1. **Create Workout** - Primary (blue/purple gradient fill)
  2. **Repeat Recent** - Secondary (blue outline)
  3. **Browse Workouts** - Secondary (blue outline, matching Repeat Recent)
- **Implementation:** Closure-based callbacks with `.buttonStyle(.plain)`
- **Why `.plain`?** Prevents gesture propagation bugs
- **Replaces:** Old "+" toolbar button (removed)
- **Dark Mode:** All buttons properly visible with `.foregroundStyle(.blue)`

#### CreateWorkoutView.swift
- **Purpose:** Simplified, fast workout creation
- **Philosophy:** Generator REQUIRED - must generate exercises before saving
- **Pre-fills:** Workout name with "Mon, Jan 13 - Workout"
- **Sections:**
  1. Workout Name (editable TextField)
  2. Generator Section (always expanded, no header)
  3. Generated Plan (only shown after generation)
  4. Notes (optional TextEditor)
- **Generator Options:**
  - Goal picker (segmented style)
  - Equipment filters (bodyweight/machines/free weights - mutually exclusive)
  - Target Muscles (DisclosureGroup, collapsed by default)
  - "Generate Workout" button (blue/purple gradient)
- **Duration Settings:** Hidden (uses defaults: 5 min warmup, 5 min core, 5 min stretch)
- **Save Behavior:**
  - DISABLED until workout generated (`.disabled(generatedPlan == nil)`)
  - Creates workout only after exercises are filled
  - Enforces structured workout creation
- **UI Changes (v2.1):**
  - Removed "Options" section header
  - Removed "Generator Options" DisclosureGroup wrapper
  - Removed duration sliders (warmup/core/stretch)
  - Content always visible, no collapsing

#### BrowseWorkoutsViewNew.swift
- **Purpose:** Drill-down navigation for workout templates
- **Architecture:** Two-level hierarchy
- **Screen 1:** Program list
  - Push/Pull (3 days)
  - Push/Pull/Legs (PPL) (3 days)
  - Amariss Personal Trainer (4 days)
  - Bro Split (5 days)
  - StrongLifts 5×5 (2 workouts)
  - Madcow 5×5 (3 days)
  - Full Body (1 workout)
  - Calisthenics (1 workout)
  - Hotel Workouts (3 days)
  - **🆕 Tabata HIIT (8 workouts)** - Added January 17, 2026
- **Screen 2:** Program Detail (ProgramDetailView)
  - **Editable workout name field** - Auto-updates when day selected
  - **Collapsible days** using DisclosureGroup
  - **Exercise preview** shown inside expanded day
  - **Selection indicator** - Blue checkmark on selected day
  - **Done button** in toolbar (disabled until day selected)
- **User Flow (v2.1):**
  1. Select program
  2. Tap day → expands + shows exercises + shows checkmark
  3. Workout name auto-updates to "Mon, Jan 13 - [Day Name]"
  4. User can review exercises and edit name
  5. Tap "Done" → creates workout and dismisses
- **State Management:**
  - `selectedDay` - Tracks which day to create
  - `expandedDay` - Tracks which day is currently expanded
  - `workoutName` - Dynamically updates via `updateWorkoutName(for:)`
- **Visual Feedback:**
  - Blue checkmark (`checkmark.circle.fill`) on selected day
  - Exercises organized with "Main Exercises" and "Accessory" labels
  - Blue dots for main exercises, orange dots for accessory
- **Data Models:**
  - `WorkoutProgram` - Program metadata + days array
  - `ProgramDay` - Day name, description, exercises, durations
- **Special Handling:**
  - Full Body & Calisthenics use WorkoutGenerator dynamically
  - All others use pre-defined exercise lists
- **Custom Templates:**
  - CustomTemplateDetailView for user-created templates
  - Shows exercises, editable name, "Create Workout" button
- **Design Philosophy:** Visual exploration with confirmation step

#### QuickRepeatSheet Updates
- **Purpose:** Select from recent 10 workouts
- **Behavior:** Instant tap-to-clone (no Done button)
- **Shows:** Name, date, sets count, volume
- **UI:** Clean list with repeat icon
- **Creates:** New workout with same exercises, NO sets
- **Names:** "Mon, Jan 13 - [Original Name]"

#### Sheet Management Pattern
- **Old Problem:** Multiple booleans caused conflicts
- **New Solution:** Single enum
  ```swift
  enum WorkoutSheet: Identifiable {
      case create, quickRepeat, browse
  }
  ```
- **Benefits:**
  - Mutually exclusive by design
  - Type-safe
  - Single `.sheet(item:)` modifier
  - No race conditions

---

---

## VIEWS & UI COMPONENTS (CONTINUED - PART 2)

### WorkoutDetailView.swift (949 lines) ⭐ MAJOR VIEW
- **Purpose:** Detailed workout view with plan editing, set logging, and sharing
- **State Management:**
  - `@Bindable var workout: Workout` - Main workout binding
  - `@Query(sort: \SetEntry.timestamp, order: .reverse) allSets` - All sets across all workouts
  - `showingRenameSheet`, `pdfToShare`, `showingSocialShare`, `shareSuccess`
  - `showingSaveAsTemplate`, `templateSaveSuccess`

#### FEATURES:
1. **Summary Card:**
   - Stat badges: Sets count, Volume, Exercise count
   - Completion status with checkmark seal (green gradient)
   - Rounded background with gray fill

2. **Plan Editors (NavigationLinks):**
   - **PrimaryPlanEditorView** - Edit `mainExercises`
   - **AccessoryEditorView** - Edit `coreExercises`
   - Both show exercise picker sheets
   - Gradient icons (blue/purple for primary, orange/pink for accessory)

3. **Log Sets & History Section:**
   - Lists all exercises for logging (ordered: main → accessory → extras)
   - NavigationLinks to `ExerciseHistoryView`
   - **EnhancedExerciseLogRow** component:
     - Gradient circle icon
     - Shows sets logged today (green checkmark)
     - Shows last set (from all workouts)
     - Shows best set (trophy icon, orange)
     - Empty state if no sets

4. **Toolbar Menu:**
   - Rename workout
   - Save as Template
   - Share as PDF (uses `PDFExporter`)
   - Share to Friends (social integration)

5. **Sheets:**
   - `RenameWorkoutSheet` - TextField for workout name
   - `SaveAsTemplateSheet` - Create `CustomWorkoutTemplate`
     - Name input
     - Optional day of week picker
     - Duplicate name validation
     - Saves to SwiftData
   - PDF share sheet (UIActivityViewController)
   - Social share confirmation dialog

#### COMPONENTS DEFINED:
- **StatBadge** - Icon + value + label with gradient
- **EnhancedExerciseLogRow** - Exercise row with last/best/today stats
- **ExerciseLogRow** - Simpler alternative version
- **PrimaryPlanEditorView** - Form to edit main exercises
- **AccessoryEditorView** - Form to edit accessory exercises
- **ExercisePickerSheet** - Searchable exercise picker with:
  - Muscle group filter chips (horizontal scroll)
  - Search bar
  - Filtered exercise list from `ExerciseLibrary.all`
  - Shows muscle group + equipment
- **FilterChip** - Capsule button for muscle filters
- **RenameWorkoutSheet** - Navigation form with TextField
- **SaveAsTemplateSheet** - Form with name + day picker
- **PDFShareItem** - Helper for PDF file URL
- **ShareSheet** - UIActivityViewController wrapper

#### METHODS:
- `exercisesForLog` - Computed property ordering exercises (main → accessory → extras)
- `shareWorkout()` - Creates PDF via `PDFExporter`
- `shareToFriends()` - Calls `SocialService.shareWorkout()`
- `formatVolume()` - K notation for 1000+
- `onDisappear` - Saves context

---

## EXERCISE LIBRARY SYSTEM

### ExerciseLibrary.swift (224 lines)

#### Enums:
1. **`WorkoutMode`** (CaseIterable, Identifiable)
   - Cases: `.push`, `.pull`, `.legs`, `.full`, `.calisthenics`, `.muscleGroups`
   - Display names for each mode

2. **`Goal`** (CaseIterable, Identifiable)
   - Cases: `.strength`, `.hypertrophy`, `.endurance`
   - Display names: "Strength", "Muscle / Size", "Endurance"

3. **`Equipment`** (CaseIterable)
   - Cases: `.barbell`, `.dumbbell`, `.machine`, `.cable`, `.bodyweight`

4. **`MuscleGroup`** (CaseIterable, Identifiable)
   - Cases: `.chest`, `.back`, `.shoulders`, `.arms`, `.legs`, `.glutes`, `.core`
   - Capitalized display names

#### Models:
1. **`ExerciseTemplate`** (struct)
   - Properties:
     - `name: String`
     - `muscleGroup: MuscleGroup`
     - `equipment: Equipment`
     - `isCalisthenic: Bool`
     - `lowBackSafe: Bool`
   - **🆕 Computed Properties:**
     - `usesBodyweight: Bool` - Returns `true` if `equipment == .bodyweight`
     - Used for auto-filling weight from HealthKit in ExerciseHistoryView

2. **`ExerciseDetail`** (struct) - For future use
   - `name: String`
   - `primaryMuscles: [String]`
   - `instructions: [String]`
   - `formTips: [String]`

#### Library:
- **`ExerciseLibrary.all`** - Static array of 70+ exercises:
  - **Push:** Chest press variations, shoulder press, lateral raises, flys, triceps
  - **Pull:** Lat pulldown, rows, face pulls, curls, pull-ups
  - **Legs:** Leg press, squats, extensions, curls, Bulgarian split squat
  - **Bodyweight:** Push-ups, squats, dips, inverted rows
  - **Core:** Planks, dead bug, bird dog, pallof press, mountain climbers
  - **Glutes:** Bridges, hip thrusts, Nordic curls
  - **Additional:** Calf raises, farmer carry, burpees, etc.

#### Methods:
1. **`forMode(_:selectedMuscles:calisthenicsOnly:machinesOnly:freeWeightsOnly:)`**
   - Filters exercises by:
     - `lowBackSafe` (always true)
     - Equipment type (calisthenics/machines/free weights)
     - Workout mode (push/pull/legs/full/calisthenics/custom)
   - Returns filtered `[ExerciseTemplate]`

2. **`coreExercises`** - Returns exercises where `muscleGroup == .core`

3. **`stretchSuggestionsBase`** - Static array of 7 stretch names:
   - "Supine hamstring stretch", "Hip flexor stretch", "Figure-4 stretch", etc.

---

---

## WORKOUT GENERATION SYSTEM

### NewWorkoutView.swift (1191 lines) ⭐ MAJOR VIEW
- **Purpose:** Comprehensive workout creation with templates and generator
- **State Management:**
  - `@Query` for existing workouts and custom templates
  - Equipment filters: `bodyweightOnly`, `machinesOnly`, `freeWeightsOnly`
  - Duration sliders: `warmupMinutes`, `coreMinutes`, `stretchMinutes`
  - `selectedMuscles: Set<MuscleGroup>` for custom mode
  - `generatedPlan: GeneratedWorkoutPlan?`
  - `workoutName: String`, `workoutNotes: String`
  - Collapsible state for sections

#### TEMPLATE SYSTEM (Cascading Dropdowns):
1. **Push/Pull** - 3 days (Pull, Push, Legs)
   - Smart exercises for specific user needs
   - 7 exercises per day + core + stretches

2. **Push/Pull/Legs (PPL)** - 3 days
   - Standard PPL split with 5-6 exercises per day

3. **Amariss Personal Trainer** - 4 days
   - Day 1: Core & Pull
   - Day 2: Lower & Glutes
   - Day 3: Row & Core
   - Day 4: Push & Posture

4. **Bro Split** - 5 days
   - Chest, Back, Shoulders, Legs, Arms
   - Classic bodybuilding split

5. **StrongLifts 5×5** - 2 workouts (A/B)
   - Workout A: Squat, Bench, Row
   - Workout B: Squat, OHP, Deadlift
   - Auto-fills notes with 5×5 protocol

6. **Madcow 5×5** - 3 days
   - Monday (Volume), Wednesday (Light), Friday (Intensity)
   - Auto-fills notes with ramping sets protocol

7. **Full Body** - Uses WorkoutGenerator
8. **Calisthenics** - Bodyweight-only exercises
9. **Hotel Workouts** - 3 days
   - Day 1: Upper Push + Core (push-ups, dips, pike push-up)
   - Day 2: Upper Pull + Core (inverted rows, bicep work)
   - Day 3: Lower Body + Conditioning (squats, lunges, glute bridges)
   - Equipment: Floor, bed/chair only
10. **Tabata HIIT** - 8 workouts (🆕 Added January 17, 2026)
   - **Core Crusher** - 4 min abs (Mountain Climbers, Russian Twists, Bicycle Crunches, Plank Shoulder Taps)
   - **Full Body Burn** - 4 min total body (Burpees, Jump Squats, Push-Ups, High Knees)
   - **Leg Destroyer** - 4 min lower body (Jump Squats, Lunge Jumps, Bodyweight Squats, Glute Bridges)
   - **Upper Body Blast** - 4 min push (Push-Ups, Pike Push-Ups, Plank to Push-Up, Bench Dips)
   - **Cardio Crusher** - 4 min cardio (High Knees, Butt Kicks, Jumping Jacks, Mountain Climbers)
   - **Total Body Tabata** - 4 min everything (Burpees, Mountain Climbers, Jump Squats, Push-Ups)
   - **Ab Ripper** - 4 min core (Bicycle Crunches, Front Plank, Russian Twists, Dead Bug)
   - **Power Builder** - 4 min explosive (Jump Squats, Burpees, Lunge Jumps, Plank to Push-Up)
   - Protocol: 8 rounds of 20 seconds work / 10 seconds rest
   - Total session: ~10 minutes (3 min warmup + 4 min tabata + 3 min stretch)
   - Icon: Timer (⏱️)
11. **Custom Templates** - User-saved templates from workouts
12. **Custom** - Muscle group selector + generator

#### FEATURES:
- **Recent Workouts:** Repeat last Push/Pull workout
- **Generator Options:** (Collapsible)
  - Goal picker: Strength/Hypertrophy/Endurance
  - Equipment toggles (mutually exclusive)
  - Duration sliders (0-15/20 min)
  - Muscle group multi-selector (custom mode)
  - Generate suggestion button
- **Exercises Display:** (Collapsible)
  - Shows main exercises with blue gradient dots
  - Shows accessory/core with orange dots
  - Shows stretches with green dots
  - Exercise count in header
- **Notes Section:** TextEditor with hint text
- **Auto-apply:** Templates auto-apply on selection change
- **Save Button:** Gradient (blue→purple) when plan ready

#### METHODS:
- `applySelectedTemplate()` - Routes to specific template applier
- `applyVinayTemplate(_:)`, `applyPPLTemplate(_:)`, etc. - Template appliers
- `generateWorkoutSuggestion()` - Calls WorkoutGenerator
- `defaultName(for:)` - "Day, Mon d - Name" format
- `saveWorkout()` - Creates Workout, inserts to context
- `lastWorkout(containing:)` - Finds workout by keyword
- `applyLastWorkout(containing:)` - Repeats workout structure
- `applyCustomTemplate(_:)` - Loads user template

#### COMPONENTS:
- **MuscleGroupMultiSelector** - Toggle list for muscle selection

---

### WorkoutGenerator.swift (50 lines)

#### `GeneratedWorkoutPlan` (struct)
- **Properties:**
  - `name: String`
  - `mainExercises: [ExerciseTemplate]`
  - `coreExercises: [ExerciseTemplate]`
  - `stretches: [String]`
  - `warmupMinutes: Int`
  - `coreMinutes: Int`
  - `stretchMinutes: Int`

#### `WorkoutGenerator` (struct)
- **Method:** `generate(mode:goal:selectedMuscles:calisthenicsOnly:machinesOnly:freeWeightsOnly:warmupMinutes:coreMinutes:stretchMinutes:)`
- **Algorithm:**
  1. Filters exercises via `ExerciseLibrary.forMode()`
  2. Shuffles and picks 4 main exercises
  3. Shuffles and picks 3 core exercises
  4. Shuffles and picks 4 stretches
  5. Creates plan with title: "{Mode} – {Goal}"

---

## HEALTHKIT INTEGRATION

### HealthKitManager.swift (455 lines) @Observable
- **Purpose:** Comprehensive HealthKit data reading and workout writing

#### PROPERTIES (Read from HealthKit):
**Body Composition:**
- `weight`, `height`, `bodyMassIndex`, `bodyFatPercentage`, `leanBodyMass`
- `boneMass`, `muscleMass`, `visceralFat` (calculated/smart scale)

**Metabolic:**
- `basalEnergyBurned` (BMR), `activeEnergyBurned`

**Activity:**
- `stepCount`, `distanceWalkingRunning`, `exerciseTime`, `standHours`

**Heart & Fitness:**
- `restingHeartRate`, `heartRateVariability`, `vo2Max`

**Sleep:**
- `sleepHours` (core + deep + REM)

**Nutrition:**
- `dietaryProtein`, `dietaryCarbs`, `dietaryFat`, `dietaryCalories`

**State:**
- `isAuthorized: Bool`, `lastUpdated: Date?`

#### METHODS:
1. **`isHealthDataAvailable`** (static) - Checks device support
2. **`checkAuthorizationStatus()`** - Checks if authorized for any types
3. **`requestAuthorization()`** (async) - Requests read/write permissions
   - Reads: 20+ quantity types + sleep + nutrition
   - Writes: Workouts + active energy
4. **`fetchAllHealthData()`** (async) - Fetches all metrics using async let
5. **`fetchMostRecent(_:unit:)`** (async) - Most recent sample for type
6. **`fetchToday(_:unit:)`** (async) - Today's cumulative value (HKStatisticsQuery)
7. **`fetchSleepHours()`** (async) - Sum of sleep stages from last 24h
8. **`calculateDerivedMetrics()`** - Computes BMI, muscle mass, bone mass from available data
9. **Formatted getters:** `formattedWeight()`, `formattedHeight()`, `formattedBMI()`, etc.
10. **`bmiCategory()`** - Returns "Underweight"/"Normal"/"Overweight"/"Obese"
11. **`saveWorkout(name:startDate:duration:totalVolume:)`** (async) - Writes workout to Health
    - Activity type: `.traditionalStrengthTraining`
    - Estimates calories: 0.04 kcal per kg of volume
    - Uses HKWorkoutBuilder
    - Adds energy burned sample
    - Adds metadata (indoor, workout name)

#### ERRORS:
- **`HealthKitError`:** `.notAvailable`, `.notAuthorized`, `.noData`

---

## ANALYTICS & CHARTS

### AnalyticsView.swift (1506 lines) ⭐ MAJOR VIEW
- **Purpose:** Comprehensive workout analytics with charts and insights
- **Data Queries:**
  - `@Query(sort: \Workout.date)` - All workouts
  - `@Query(sort: \SetEntry.timestamp)` - All sets
  
#### STATE:
- `selectedRange: TimeRange` - Time window for analysis
- `selectedMetric: MetricType` - Volume vs Sets vs Workouts
- `selectedMuscle: MuscleGroup?` - Muscle filter

#### SECTIONS (Collapsible):
1. **Workout Streak** - Motivation first!
2. **Muscle Distribution & Balance** (expanded by default)
   - Time range picker
   - Metric type segmented control
   - Radar chart (current vs previous period)
   - Muscle stats grid
   - Training insights (coach message)
   - Undertrained muscles alert (orange warning)
3. **Weekly Summary** - This week vs last week
4. **Consistency Calendar** (likely)
5. **Muscle Heatmap** (likely)

#### COMPONENTS (Visible from code):
- **CollapsibleSection** - Reusable collapsible card
- **RadarChartView** - Custom radar/spider chart for muscle balance
- Empty state with gradient chart icon

#### METHODS (Visible):
- `distributionValues()` - Current period muscle distribution
- `previousDistributionValues()` - Previous period for comparison
- `coachMessage()` - Generates training insights text
- `undertrainedMuscles()` - Returns muscles needing attention
- `severity(for:values:)` - Calculates undertrained severity

---

---

## SETTINGS & CONFIGURATION

### SettingsView.swift (1157 lines)
- **Purpose:** Master settings hub with searchable navigation
- **State:** `@State syncMonitor: CloudKitSyncMonitor`, `searchText: String`

#### NAVIGATION SECTIONS:
1. **Branding Section** - App logo, name, edition
2. **Account Settings** - NavigationLink to `AccountSettingsView`
3. **Data & Sync** - NavigationLink to `SyncSettingsView`
   - Shows sync status icon + color
   - Progress indicator when syncing
4. **Workouts** - NavigationLink to `WorkoutSettingsView`
5. **Appearance** - NavigationLink to `AppearanceSettingsView`
6. **Health & Fitness** - NavigationLink to `HealthSettingsView` (red heart icon)
7. **Data Export & Backup** - NavigationLink to `DataExportView`
8. **Help & Support** - NavigationLink to `HelpView`
9. **Legal Section:**
   - Privacy Policy → `PrivacyPolicyView`
   - Terms of Service → `TermsOfServiceView`
10. **App Info Section:**
    - Version number (CFBundleShortVersionString)
    - Build number (CFBundleVersion)
    - App description

#### FEATURES:
- **Searchable** - `.searchable(text: $searchText)` with keyword matching
- **Conditional display** - Sections hidden if search doesn't match
- **Search keywords** - Each section has associated keywords (e.g., "Account", "iCloud", "Export", etc.)
- **Done button** - Dismisses settings sheet

#### COMPONENTS:
- **CloudKitDebugView** - Comprehensive CloudKit diagnostics tool
  - Container identifier display
  - iCloud account status check
  - Full diagnostics run (account, public DB test, record type test)
  - Diagnostic log with color-coded messages (✅ ❌ ⚠️)
  - Error handling with helpful suggestions
  - Tests UserProfile record type query
  - Provides CloudKit Dashboard link

---

### AccountSettingsView
- **Purpose:** Account authentication status and management
- **State:**
  - `@Environment(AuthenticationManager.self)` - Auth state
  - `@AppStorage` for legacy settings
  - `showAppleSignIn`, `showDeleteAccountConfirmation`

#### SECTIONS:

1. **Account Status Section:**
   - **Guest Users** (detected by `userID.hasPrefix("guest-")`):
     - Blue person icon
     - "Guest User" headline
     - "Local account only" subheadline
   - **Apple ID Users:**
     - Green checkmark icon
     - "Signed in with Apple" headline
     - User name (if available)
     - Email address (if available)

2. **Actions Section:**
   - **For Guest Users:**
     - "Sign in with Apple" button (prominent blue)
     - Footer: "Sign in with Apple to sync your workouts across all your devices and back them up to iCloud."
   - **For Apple ID Users:**
     - "Sign Out" button (destructive)
     - Footer: "Signing out will keep your local data but stop syncing until you sign in again."
     - **Danger Zone Section:**
       - "Delete Account" button (destructive)
       - Warning about permanent deletion

#### SIGN-IN SHEET:
- NavigationStack with custom UI
- App icon (gradient circle)
- "Sign in with Apple" title
- `SignInWithAppleButton` with `.black` style
- Integrates with `AuthenticationManager.handleSignInWithApple()`
- Cancel button in toolbar
- Auto-dismisses on successful sign-in

#### KEY LOGIC:
- Uses `userID.hasPrefix("guest-")` to detect guest users (not `userEmail.isEmpty`)
- Prevents showing "Sign Out" to guest users
- Allows guest → Apple ID upgrade path
- Properly dismisses sheet after sign-in

---

## USER PROFILE & SOCIAL

### ProfileView.swift (661 lines)
- **Purpose:** User profile with stats, analytics, and health integration
- **Data Queries:**
  - `@Query` for workouts and all sets
  - `@AppStorage` for displayName, bio, link, followers, following
  - `@Environment(AuthenticationManager.self)` for Apple ID data

#### STATE:
- `showEditProfile`, `showSettings`, `showHealthStats`
- Collapsible states: `isVolumeCardExpanded`, `isTopExercisesExpanded`, `isStreakCardExpanded`, `isWeeklySummaryExpanded`

#### HEADER SECTION:
- **Avatar:** Circle with initial letter from display name
- **Display Name:** (lowercased) - Cascading fallback:
  1. Stored display name (AppStorage)
  2. Auth manager's userName (from Apple ID)
  3. Email-derived name
  4. Device name (strips "'s iPhone")
- **Stats Row:** Workouts count, Followers, Following

#### BIO/LINK SECTION:
- Optional bio text
- Optional clickable link (URL)

#### ANALYTICS CARDS:
1. **Apple Health Button** - Links to `HealthStatsView`
   - Red/pink gradient heart icon
   - "View body composition & activity"
2. **Volume Trend Card** (collapsible)
   - Last 30 days chart using Swift Charts
   - ChartPoint data structure
3. **Top Exercises** (collapsible)
   - All-time top 3 by volume
4. **Workout Streak** (collapsible)
5. **Weekly Summary** (collapsible)

#### METHODS:
- `displayName` - Computed property with fallback logic
- `avatarInitial` - First letter uppercase
- `last30DaysCutoff` - Date helper
- `recentSets`, `recentVolumePoints` - Chart data
- `topExercisesAllTime` - Top 3 exercises by volume

---

### FriendsView.swift (399 lines)
- **Purpose:** Social features with friends, feed, and discovery
- **State:**
  - `@State socialService: SocialService`
  - `searchText`, `selectedTab` (0=Friends, 1=Feed, 2=Discover)
  - `searchResults: [UserProfile]`, `showingProfileSetup`

#### TABS:
1. **Friends Tab:**
   - Friend requests section (with accept/reject)
   - Friends list (NavigationLinks to UserProfileView)
   - Pull to refresh
   - Empty state: "No friends yet"

2. **Feed Tab:**
   - `friendWorkouts` list
   - `WorkoutFeedRow` component
   - Empty state: ContentUnavailableView
   - Pull to refresh

3. **Discover Tab:**
   - Suggested users section
   - NavigationLinks to UserProfileView
   - `DiscoverUserRow` component
   - Pull to refresh

#### PROFILE SETUP:
- **Profile Setup Prompt** (if no profile exists)
  - Person icon
  - "Connect with Friends" title
  - "Create Profile" button → `ProfileSetupView`

#### SEARCH:
- Searchable with live search results overlay
- `performSearch(query:)` async method
- Search results list with NavigationLinks

#### COMPONENTS USED:
- `FriendRequestRow` - Request with accept/reject
- `FriendRowView` - Friend list item
- `WorkoutFeedRow` - Workout in feed
- `DiscoverUserRow` - Suggested user item

---

### SocialModels.swift (233 lines)
- **Purpose:** Data models for CloudKit social features
- **Location:** /SocialModels.swift
- **Models:**
  
  1. **UserProfile** (struct, Identifiable, Codable)
     - **Purpose:** Public user profile stored in CloudKit
     - **Properties:**
       - `id: String` - UUID as string
       - `appleUserID: String` - 🔑 CRITICAL - Links to iCloud user via CloudKit userRecordID
       - `username: String` - Unique username for discovery
       - `displayName: String` - Display name shown to friends
       - `bio: String` - Optional bio text
       - `avatarURL: String?` - Optional avatar image URL
       - `createdDate: Date` - Profile creation timestamp
       - `isPublic: Bool` - Public visibility flag
       - `totalWorkouts: Int` - Workout count stat
       - `totalVolume: Double` - All-time volume stat
     - **Methods:**
       - `init(appleUserID:username:displayName:bio:...)` - Creates new profile
       - `init?(from: CKRecord)` - Parses from CloudKit record
       - `toCKRecord() -> CKRecord` - Converts to CloudKit record
     - **CloudKit Record Type:** `"UserProfile"`
     - **Key Change (Jan 14):** Now requires `appleUserID` to link profile to authenticated iCloud user
     - **Why it matters:** Ensures one profile per iCloud account, enables proper profile lookup
  
  2. **FollowRelationship** (struct, Identifiable) - 🆕 PRIMARY SOCIAL MODEL
     - **Purpose:** Simplified one-way following (like Instagram/Twitter)
     - **Properties:**
       - `id: String` - UUID as string
       - `followerID: String` - User who is following
       - `followingID: String` - User being followed
       - `followedAt: Date` - Timestamp of follow action
     - **Methods:**
       - `init(followerID:followingID:)` - Creates new follow relationship
       - `init?(from: CKRecord)` - Parses from CloudKit record
       - `toCKRecord() -> CKRecord` - Converts to CloudKit record
     - **CloudKit Record Type:** `"FollowRelationship"`
     - **Design Philosophy:**
       - Instant following (no approval needed)
       - One-way relationship (A can follow B without B following back)
       - No status field (simpler than FriendRelationship)
     - **Used by:** SocialService follow/unfollow methods
  
  3. **FriendRelationship** (struct, Identifiable) - 📦 LEGACY (Kept for Compatibility)
     - **Purpose:** Original two-way friend system with approval
     - **Properties:**
       - `id: String` - UUID as string
       - `followerID: String` - User who sent request
       - `followingID: String` - User who received request
       - `createdDate: Date` - Request creation timestamp
       - `status: FriendStatus` - Request status (pending/accepted/blocked)
     - **Enum: FriendStatus**
       - `.pending` - Request sent, awaiting approval
       - `.accepted` - Request approved, friends
       - `.blocked` - User blocked
     - **Methods:**
       - `init(followerID:followingID:status:)` - Creates relationship
       - `init?(from: CKRecord)` - Parses from CloudKit record
       - `toCKRecord() -> CKRecord` - Converts to CloudKit record
     - **CloudKit Record Type:** `"FriendRelationship"`
     - **Status:** Legacy - Used by UI but mapped to FollowRelationship in service
     - **Why kept:** Existing UI components reference this model
  
  4. **PublicWorkout** (struct, Identifiable, Codable)
     - **Purpose:** Shared workout summaries for social feed
     - **Properties:**
       - `id: String` - UUID as string
       - `userID: String` - User who created workout
       - `workoutName: String` - Workout name
       - `date: Date` - Workout date
       - `totalVolume: Double` - Total volume (weight × reps)
       - `exerciseCount: Int` - Number of exercises
       - `isCompleted: Bool` - Completion status
     - **Methods:**
       - `init(userID:workoutName:date:totalVolume:exerciseCount:isCompleted:)`
       - `init?(from: CKRecord)` - Parses from CloudKit record
       - `toCKRecord() -> CKRecord` - Converts to CloudKit record
     - **CloudKit Record Type:** `"PublicWorkout"`
     - **Used by:** SocialService workout sharing and feed fetching
  
  5. **SocialError** (enum, LocalizedError)
     - **Purpose:** Social feature error types with user-friendly messages
     - **Cases:**
       - `.notAuthenticated` - "You must be signed in to iCloud..."
       - `.usernameTaken` / `.usernameAlreadyTaken` - "This username is already taken..."
       - `.alreadyFollowing` - "You're already following this user."
       - `.userNotFound` / `.profileNotFound` - "User not found."
       - `.networkError` - "Network connection error..."
       - `.serverError` - "CloudKit server is temporarily unavailable..."
       - `.containerNotConfigured` - "iCloud container is not properly configured..."
     - **Property:** `errorDescription: String?` - User-facing error messages
     - **Used by:** SocialService throws these errors with descriptive messages

---

### SocialService.swift (570+ lines) @Observable
- **Purpose:** CloudKit-based social networking service with Apple ID integration
- **Location:** /SocialService.swift
- **Container:** `iCloud.com.vinay.VinProWorkoutTracker`
- **Database:** Public CloudKit database

#### PROPERTIES:
**Observable State:**
- `currentUserProfile: UserProfile?` - Current user's profile
- `friends: [UserProfile]` - Users you're following (reusing "friends" property name)
- `friendRequests: [FriendRelationship]` - Legacy, always empty with instant follow
- `suggestedUsers: [UserProfile]` - Recommended users to follow
- `friendWorkouts: [PublicWorkout]` - Feed of workouts from followed users
- `isLoading: Bool` - Loading state for UI
- `errorMessage: String?` - Last error message
- `privacySettings: SocialPrivacySettings` - User's privacy settings

**Private State:**
- `container: CKContainer` - CloudKit container reference
- `publicDatabase: CKDatabase` - Public database reference
- `cachedAppleUserID: String?` - 🔑 Cached iCloud user ID for performance

**Constants:**
- `profileCacheKey` - UserDefaults key for cached profile
- `appleUserIDCacheKey` - UserDefaults key for cached Apple ID

#### LOCAL CACHING SYSTEM (🆕 Performance Enhancement):
**Methods:**
- `loadCachedProfile()` - Loads UserProfile from UserDefaults on init
  - Decodes JSON from UserDefaults
  - Sets `currentUserProfile` if available
  - Enables offline profile viewing
- `cacheProfile(_: UserProfile)` - Saves profile to UserDefaults
  - Encodes UserProfile to JSON
  - Stores in UserDefaults for persistence
  - Called after create/update operations
- `clearCachedProfile()` - Removes cached data
  - Clears both profile and Apple ID from UserDefaults
  - Resets `cachedAppleUserID` to nil

**Benefits:**
- Profiles persist across app restarts
- Works offline (shows last known profile)
- Reduces CloudKit queries
- Faster app startup

#### APPLE ID INTEGRATION (🔑 Critical for Profile Persistence):
**Method: `getAppleUserID() async throws -> String`**
- **Purpose:** Gets unique CloudKit user record ID to link profile
- **Algorithm:**
  1. Returns cached ID if available (fast path)
  2. In simulator: Generates fake but consistent ID for testing
  3. On device: Fetches from `container.userRecordID()`
  4. Caches result in both property and UserDefaults
- **Return Value:** CloudKit record name (e.g., `_abc123def456`)
- **Throws:** CloudKit errors if not authenticated
- **Why it matters:** This is the **key fix** that ties profiles to iCloud accounts
- **Before fix:** Profiles were orphaned, user could create multiple profiles
- **After fix:** One profile per iCloud account, proper lookup by Apple ID

#### AUTHENTICATION METHODS:
1. **`checkAuthentication() async throws -> Bool`**
   - Checks CloudKit account status
   - Returns true if `CKAccountStatus == .available`
   - Simulator bypass: Returns true with debug message
   - Used before all CloudKit operations

#### USER PROFILE MANAGEMENT:
1. **`createUserProfile(username:displayName:bio:) async throws`**
   - **Flow:**
     1. Checks authentication via `checkAuthentication()`
     2. Gets Apple User ID via `getAppleUserID()` 🔑
     3. Checks username uniqueness with CloudKit query
     4. Creates `UserProfile` with `appleUserID` link
     5. Saves to CloudKit public database
     6. Caches profile locally
   - **Throws:**
     - `SocialError.notAuthenticated` - Not signed in to iCloud
     - `SocialError.usernameAlreadyTaken` - Username conflict
     - `SocialError.networkError` - Network issues
     - `SocialError.serverError` - CloudKit server issues
     - `SocialError.containerNotConfigured` - Setup issues
   - **Debug Logging:** Extensive emoji-based logging (🔍 ✅ ❌ ⚠️)

2. **`fetchCurrentUserProfile() async throws`**
   - **Flow:**
     1. Returns cached profile if available (fast path) 🆕
     2. Checks authentication
     3. Gets Apple User ID
     4. Queries CloudKit: `appleUserID == <user's ID>` 🔑 **KEY FIX**
     5. Parses first matching record
     6. Caches fetched profile
   - **Before fix:** Queried with `TRUEPREDICATE` and grabbed first record (WRONG!)
   - **After fix:** Queries by `appleUserID` to find user's specific profile
   - **Throws:**
     - `SocialError.notAuthenticated`
     - `SocialError.profileNotFound` - No profile exists for this Apple ID

3. **`updateUserProfile(displayName:bio:totalWorkouts:totalVolume:) async throws`**
   - Updates profile properties (all parameters optional)
   - Saves to CloudKit
   - Caches updated profile locally 🆕
   - Requires existing `currentUserProfile`

#### FOLLOWING MANAGEMENT (Simplified, One-Way):
**Design:** Instant follow (no approval needed), one-way relationships

1. **`followUser(userID: String) async throws`**
   - Checks if already following
   - Creates `FollowRelationship` record
   - Saves to CloudKit (`"FollowRelationship"` record type)
   - Refreshes following list
   - **Throws:** `SocialError.alreadyFollowing`

2. **`unfollowUser(userID: String) async throws`**
   - Queries for existing follow relationship
   - Deletes CloudKit record
   - Refreshes following list

3. **`isFollowing(userID: String) -> Bool`**
   - Checks if user in `friends` array
   - Synchronous check against local state

4. **`fetchFollowing() async`**
   - Queries `FollowRelationship` where `followerID == currentUser.id`
   - Collects all `followingID`s
   - Fetches `UserProfile` for each following ID
   - Updates `friends` array (reusing property name)
   - Updates `isLoading` state

#### LEGACY FRIEND REQUEST COMPATIBILITY:
**Note:** These map to instant follow for backward compatibility with UI
- `sendFriendRequest(to:)` → Calls `followUser()`
- `acceptFriendRequest(relationshipID:)` → No-op (prints deprecation warning)
- `removeFriend(userID:)` → Calls `unfollowUser()`
- `fetchFriends()` → Calls `fetchFollowing()`
- `fetchFriendRequests()` → Sets `friendRequests = []` (always empty)

#### USER DISCOVERY:
1. **`searchUsers(query: String) async throws -> [UserProfile]`**
   - Searches by username OR displayName (case-insensitive)
   - CloudKit predicate: `username CONTAINS[cd] %@ OR displayName CONTAINS[cd] %@`
   - Excludes current user from results
   - Limit: 20 results
   - Simulator: Returns empty array with warning

2. **`fetchSuggestedUsers() async`**
   - Queries public profiles (`isPublic == 1`)
   - Sorts by `totalWorkouts` (descending)
   - Excludes current user
   - Excludes already-following users
   - Limit: 20 results
   - Updates `suggestedUsers` array

#### WORKOUT SHARING:
1. **`shareWorkout(_ workout: Workout) async throws`**
   - Creates `PublicWorkout` from Workout
   - Includes: name, date, volume, exercise count, completion status
   - Saves to CloudKit public database
   - Updates user's `totalWorkouts` and `totalVolume` stats
   - Simulator: Logs would-share message

2. **`fetchFriendWorkouts() async`**
   - Queries `PublicWorkout` where `userID IN <followingIDs>`
   - Sorts by date (descending)
   - Limit: 50 workouts
   - Updates `friendWorkouts` array
   - Returns empty if not following anyone

#### DEBUG METHODS (DEBUG builds only):
1. **`deleteCurrentUserProfile() async throws`** (#if DEBUG)
   - Deletes current user's profile from CloudKit
   - Clears local cache
   - Used for testing/cleanup

2. **`cleanupOrphanedProfiles() async throws`** (#if DEBUG)
   - Finds profiles without `appleUserID` field
   - Deletes orphaned profiles
   - Returns count of deleted profiles
   - Useful for cleaning up old test data

#### ERROR HANDLING STRATEGY:
- **CloudKit Error Mapping:**
  - `.notAuthenticated` → `SocialError.notAuthenticated`
  - `.networkUnavailable`, `.networkFailure` → `SocialError.networkError`
  - `.serverResponseLost`, `.serviceUnavailable` → `SocialError.serverError`
  - `.badContainer`, `.missingEntitlement`, `.unknownItem` → `SocialError.containerNotConfigured`
- **Comprehensive Logging:**
  - 🔍 Debug - Informational messages
  - ✅ Success - Operations completed
  - ❌ Error - Failures with details
  - ⚠️ Warning - Non-critical issues
- **Container Validation:**
  - Logs container identifier on init
  - Logs cached Apple User ID status
  - Provides CloudKit Dashboard suggestions on errors

#### SIMULATOR SUPPORT:
- Generates fake Apple User ID for testing
- Bypasses CloudKit queries (returns empty arrays)
- Logs "would do X" messages for operations
- Allows UI testing without CloudKit setup

#### CLOUDKIT SCHEMA REQUIREMENTS:
**Record Types Needed:**
1. **UserProfile** - User profiles
   - Fields: `appleUserID` (String), `username` (String), `displayName` (String), `bio` (String), `isPublic` (Int), `totalWorkouts` (Int), `totalVolume` (Double), `createdDate` (Date)
   - Indexes: `appleUserID`, `username`

2. **FollowRelationship** - Following relationships
   - Fields: `followerID` (String), `followingID` (String), `followedAt` (Date)
   - Indexes: `followerID`, `followingID`

3. **PublicWorkout** - Shared workouts
   - Fields: `userID` (String), `workoutName` (String), `date` (Date), `totalVolume` (Double), `exerciseCount` (Int), `isCompleted` (Int)
   - Indexes: `userID`, `date`

#### INTEGRATION POINTS:
- **Used by:** FriendsView, ProfileView, UserProfileView
- **Depends on:** SocialModels.swift, AuthenticationManager
- **CloudKit Container:** Must match Xcode entitlements

---

## EXERCISE LEARNING & HISTORY

### LearnView.swift (418 lines)
- **Purpose:** Exercise library with search, filters, and favorites
- **State:**
  - `searchText`, `selectedMuscle`, `selectedEquipment`, `bodyweightOnly`
  - `@AppStorage("favoriteExercises")` - Persisted favorites
  - `favoriteExercises: Set<String>` - Runtime favorites
  - Collapsible states: `isRecentlyUsedExpanded`, `expandedMuscleGroups`
  - `showHelp`

#### DATA SOURCES:
- `allExercises` - From `ExerciseLibrary.all`
- `@Query` for recent sets (last 7 days)

#### SECTIONS:
1. **⭐ Favorites** (Always expanded, non-collapsible)
   - Shows favorite exercises
   - Persisted in AppStorage

2. **🕐 Recently Used** (Collapsible)
   - Last 7 days' exercises
   - Limited to 5 items
   - Shows count badge

3. **All Exercises** (Grouped by muscle, collapsible)
   - Grouped by `MuscleGroup`
   - Each muscle group is a DisclosureGroup
   - Shows exercise count per group
   - Alphabetically sorted within groups

#### FILTERS:
- **Header Controls:**
  - Muscle group pills (horizontal scroll)
  - Equipment filter buttons
  - "Bodyweight Only" toggle
  - "Low Back Safe" toggle

#### EXERCISE ROW:
- Exercise name
- Muscle group badge
- Equipment badge
- Favorite star button (toggle)

#### FEATURES:
- Searchable with live filtering
- Smooth animations on filter changes
- Help button → `HelpView` sheet
- Favorites persist across sessions

#### METHODS:
- `filteredExercises` - Applies all filters
- `recentlyUsedExercises` - Last 7 days unique exercises
- `favoriteExercisesList` - Exercises in favorites set
- `groupedByMuscle` - Groups and sorts by muscle
- `loadFavorites()` / `saveFavorites()` - AppStorage serialization

---

### ExerciseHistoryView.swift (424 lines)
- **Purpose:** Set logging and exercise history with PR detection
- **Props:** `@Bindable var workout: Workout`, `exerciseName: String`
- **Data:** `@Query` for all sets across all workouts
- **🆕 HealthKit Integration:** `@State healthKitManager: HealthKitManager` for bodyweight pre-fill

#### STATE:
- `weightText`, `repsText` - Input fields
- `prMessage: String?` - PR banner message
- `isExerciseInfoExpanded: Bool` - Exercise details section
- `healthKitManager` - 🆕 For fetching user's bodyweight

#### SECTIONS:
1. **Progressive Overload Indicator:**
   - Shows last workout's performance
   - Target to beat display
   - Color-coded icon (green=good, orange=maintain, red=below)
   - Best set from last workout

2. **PR Banner** (appears when PR achieved)
   - Trophy icon with bounce effect
   - "Personal Record!" text
   - PR message (weight PR, 1RM PR, etc.)
   - Yellow background

3. **Add Set Section:**
   - Exercise name (secondary text)
   - Weight input (decimal keyboard) - 🆕 **Auto-fills with bodyweight for bodyweight exercises**
   - Reps input (number keyboard)
   - "Add set" button (disabled if empty)

4. **This Workout Section:**
   - Today's sets for this exercise
   - Sorted by timestamp (newest first)
   - Shows time and weight × reps

5. **All Sets Section:**
   - All-time history for this exercise
   - Shows date, time, weight × reps

6. **Exercise Information** (Collapsible)
   - Primary muscles card
   - How-to instructions
   - Form tips
   - Uses `ExerciseDatabase` (external service)

#### 🆕 BODYWEIGHT AUTO-FILL FEATURE:
- **Trigger:** `.onAppear` calls `preFillBodyweightIfNeeded()`
- **Logic:**
  1. Checks if weight field is empty
  2. Looks up exercise in `ExerciseLibrary.all`
  3. Checks if `exercise.usesBodyweight == true`
  4. Pre-fills weight from `healthKitManager.weight`
- **User Experience:**
  - Saves time for bodyweight exercises
  - User can still edit/override the value
  - Works for ALL exercises with `equipment == .bodyweight`
- **Examples:** Push-Ups, Squats, Burpees, Planks, Dead Bug, Bird Dog, etc.

#### PR DETECTION:
- Tracks `bestWeightSoFar` - Max weight ever
- Tracks `best1RMSoFar` - Max estimated 1RM
- Compares new set to historical bests
- Shows banner if new PR achieved

#### METHODS:
- `addSet()` - Creates SetEntry, detects PR, clears inputs
- `getLastWorkoutComparison()` - Compares to previous workout
- `estimated1RM(weight:reps:)` - Calculates 1RM estimate
- `formatWeight(_:)` - Formats weight display
- **🆕 `preFillBodyweightIfNeeded()`** - Smart bodyweight pre-fill from HealthKit
- Exercise info cards with gradient icons

---

## 🎉 COMPLETE MANIFEST - FINAL VERSION

**Total Files Analyzed:** 20+ files  
**Manifest Size:** 1000+ lines  
**Coverage:** Complete project structure documented

### ✅ CORE DATA MODELS
- Workout, SetEntry, CustomWorkoutTemplate (SwiftData @Model)
- ExportedWorkout, ExportedSet, WorkoutExportFile
- ExerciseTemplate, GeneratedWorkoutPlan
- UserProfile, FriendRelationship, PublicWorkout

### ✅ MAJOR VIEWS
- ContentView (workout list with bulk operations)
- WorkoutDetailView (plan editing, set logging, sharing)
- NewWorkoutView (10 template systems + generator)
- AnalyticsView (charts, muscle balance, insights)
- ProfileView (stats, charts, health integration)
- FriendsView (social networking, feed, discovery)
- LearnView (exercise library with filters)
- ExerciseHistoryView (set logging with PR tracking)
- SettingsView (searchable settings hub)

### ✅ BUSINESS LOGIC
- WorkoutGenerator (AI-free random generation)
- HealthKitManager (20+ metrics, workout writing)
- SocialService (CloudKit social features)
- ExerciseLibrary (70+ exercises with filters)
- AuthenticationManager (Sign in with Apple)
- CSVExporter, PDFExporter, ExportManager

### ✅ APP ARCHITECTURE
- SwiftData with CloudKit sync (3-tier fallback)
- Sign in with Apple authentication
- Onboarding flow with sample workout
- Tab-based navigation (5 tabs)
- Theme support (System/Light/Dark)

### ✅ KEY FEATURES
- **Workout Management:** Create, edit, archive, bulk operations, quick repeat
- **Exercise Logging:** Set tracking, PR detection, progressive overload indicators
- **Templates:** 11 built-in programs (including Tabata HIIT) + custom user templates
- **Analytics:** Muscle balance radar, undertrained detection, streaks, trends
- **Social:** Friends, feed, discovery, workout sharing
- **Health Integration:** Read 20+ metrics, write workouts
- **Export:** JSON, CSV (detailed/summary), PDF
- **Import:** File picker, JSON string paste (with validation)
- **Search:** Settings search, exercise search, user search
- **HIIT Training:** 8 Tabata workouts with classic 20s/10s protocol

### ✅ CLOUDKIT INTEGRATION
- Container: `iCloud.com.vinay.VinProWorkoutTracker`
- UserProfile, FriendRelationship, PublicWorkout records
- Public database for social features
- Diagnostic tools with detailed error handling

---

## 📂 COMPLETE FILE DIRECTORY

**Data Models:**
- Models.swift - Workout, SetEntry, CustomWorkoutTemplate
- ExerciseLibrary.swift - Exercise templates, muscle groups
- WorkoutGenerator.swift - Workout plan generation

**Core Views:**
- VinProWorkoutTrackerApp.swift - App entry point
- RootView.swift - Onboarding orchestration
- RootTabView.swift - Tab navigation
- ContentView.swift - Workout list (PRIMARY)
- WorkoutDetailView.swift - Workout detail & editing
- NewWorkoutView.swift - Workout creation
- ExerciseHistoryView.swift - Set logging

**Tab Views:**
- ProfileView.swift - User profile & stats
- AnalyticsView.swift - Charts & analytics
- FriendsView.swift - Social features
- LearnView.swift - Exercise library

**Authentication & Onboarding:**
- SignInView.swift - Apple sign-in
- AuthenticationManager.swift - Auth state
- OnboardingView.swift - 4-page onboarding

**Settings:**
- SettingsView.swift - Settings hub
- AccountSettingsView, SyncSettingsView, etc. (referenced)

**Health & Social:**
- HealthKitManager.swift - HealthKit integration
- SocialService.swift - CloudKit social
- HealthStatsView.swift - Health metrics display
- UserProfileView.swift - Other user profiles

**Export & Support:**
- WorkoutExportSupport.swift - Export functionality
- HelpView.swift - Help & documentation

**Supporting Files:**
- README.md, LAUNCH_CHECKLIST.md, SOCIAL_INTEGRATION.md
- RELEASE_TONIGHT_CHECKLIST.md - Social features release guide
- TABATA_WORKOUTS_ADDED.md - Tabata HIIT documentation
- JSON_IMPORT_FIXES.md, JSON_IMPORT_FINAL_FIX.md - Import enhancements
- Various markdown documentation files

---

## 🔗 CROSS-REFERENCE MAP

### Workout → SetEntry (1:Many)
- Workout has `sets: [SetEntry]` with cascade delete
- SetEntry belongs to parent Workout

### Workout → CustomWorkoutTemplate (Conversion)
- Template converts to Workout via `toWorkout()`
- Workout saves as template via SaveAsTemplateSheet

### ExerciseLibrary → ExerciseTemplate
- Library provides static exercises
- Templates used in workout generation
- Templates shown in exercise pickers

### HealthKitManager ← ContentView
- ContentView saves workouts to Health on completion
- Estimates calories from volume (0.04 kcal/kg)

### SocialService ← FriendsView/ProfileView
- FriendsView uses for social operations
- ProfileView uses for profile display

### AuthenticationManager ← App/RootView/ProfileView
- App uses for authentication gate
- RootView uses for name prompt
- ProfileView uses for display name fallback

### ExportManager ← ContentView
- ContentView exports via ExportManager
- Supports JSON, CSV, PDF formats

---

**🎊 MANIFEST COMPLETE!**  
**Last Updated:** January 10, 2026  
**Version:** 1.0 Final  
**File:** PROJECT_MANIFEST.md


