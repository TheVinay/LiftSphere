# Help & Documentation Guide

This document explains where and how help content is stored in the LiftSphere Workout app.

## Overview

All user-facing help content is built into the app itself using SwiftUI views. This approach provides several benefits:
- ✅ Works completely offline
- ✅ Native iOS experience with smooth navigation
- ✅ Consistent with app design and branding
- ✅ Easy to update with app updates
- ✅ No web dependencies or external hosting needed

## File Structure

### Main Help File
**`HelpView.swift`** - Contains all help and documentation content

This single file includes:
- Main help navigation hub
- Quick Start Guide
- Feature-specific help sections
- Tips & Tricks
- FAQ
- All supporting UI components

## How Users Access Help

### From Settings
1. Open the app
2. Go to **Profile** tab
3. Tap **Settings** (gear icon)
4. Tap **Help & User Guide** in the "Help & Support" section

### Direct Navigation
The `HelpView` can be presented from anywhere in the app by importing it:

```swift
.sheet(isPresented: $showHelp) {
    HelpView()
}
```

## Help Content Structure

### 1. Quick Start Guide
Location: `QuickStartGuideView` in `HelpView.swift`

**Content:**
- Welcome message
- Step-by-step first workout
- Logging sets
- Completing workouts
- What to do next

**When to update:** When core workout creation flow changes

---

### 2. Workouts Guide
Location: `WorkoutsHelpView` in `HelpView.swift`

**Content:**
- Creating workouts
- Quick Repeat feature
- Swipe actions (complete, duplicate, delete, archive)
- Bulk actions (select mode)
- Import/export
- Archive feature

**When to update:** When workout management features change

---

### 3. Analytics Guide
Location: `AnalyticsHelpView` in `HelpView.swift`

**Content:**
- Overview stats explanation
- Volume over time charts
- Top exercises ranking
- Recent PRs
- Muscle group distribution

**When to update:** When new analytics features are added

---

### 4. Exercise Library
Location: `ExerciseLibraryHelpView` in `HelpView.swift`

**Content:**
- Browsing exercises
- Filter options (muscle group, equipment)
- Favorites system
- Recently used section
- Exercise detail pages
- Low-back friendly marking

**When to update:** When exercise library features change

---

### 5. Friends & Social
Location: `SocialHelpView` in `HelpView.swift`

**Content:**
- Connecting with friends
- Activity feed
- Privacy controls
- Sign in with Apple

**When to update:** When social features change

---

### 6. iCloud Sync
Location: `CloudSyncHelpView` in `HelpView.swift`

**Content:**
- What iCloud Sync does
- Setup instructions
- Sync status meanings
- Troubleshooting steps

**When to update:** When sync behavior changes

---

### 7. Data Export & Backup
Location: `DataExportHelpView` in `HelpView.swift`

**Content:**
- Why export data
- Export format options (CSV detailed, CSV summary, JSON)
- How to export
- How to import
- Use cases

**When to update:** When export features change

---

### 8. Customization
Location: `CustomizationHelpView` in `HelpView.swift`

**Content:**
- Appearance settings
- Workout display options
- Exercise filters
- Other preferences

**When to update:** When new settings are added

---

### 9. Tips & Tricks
Location: `TipsAndTricksView` in `HelpView.swift`

**Content:**
- Pro tips for power users
- Hidden features
- Best practices
- Workflow optimizations

**When to update:** Regularly add new tips as users discover patterns

---

### 10. FAQ
Location: `FAQView` in `HelpView.swift`

**Content:**
- Common questions and answers
- Expandable/collapsible format
- Searchable

**When to update:** When users frequently ask the same questions

---

## Updating Help Content

### To Update Existing Content

1. Open `HelpView.swift`
2. Find the relevant view (e.g., `WorkoutsHelpView`)
3. Locate the `HelpSection` you want to modify
4. Update the text inside the `VStack` or `Text` views
5. Test in the simulator or on device

### To Add New Help Topics

1. Open `HelpView.swift`
2. Create a new private struct for your topic:
   ```swift
   private struct NewFeatureHelpView: View {
       var body: some View {
           ScrollView {
               VStack(alignment: .leading, spacing: 24) {
                   HelpSection(title: "Your Topic", icon: "icon.name") {
                       Text("Your help content here")
                   }
               }
               .padding()
           }
           .navigationTitle("Your Feature")
           .navigationBarTitleDisplayMode(.inline)
       }
   }
   ```
3. Add a navigation link in the main `HelpView` body:
   ```swift
   NavigationLink {
       NewFeatureHelpView()
   } label: {
       HelpCategoryRow(
           icon: "icon.name",
           title: "Your Feature",
           description: "Short description"
       )
   }
   ```

### To Add New FAQ Items

1. Open `HelpView.swift`
2. Find `FAQView`
3. Add a new `FAQItem` in the `VStack`:
   ```swift
   FAQItem(
       question: "Your question?",
       answer: "Your detailed answer here."
   )
   ```

### To Add New Tips

1. Open `HelpView.swift`
2. Find `TipsAndTricksView`
3. Add a new `TipItem`:
   ```swift
   TipItem(
       number: 9,
       title: "Your Tip Title",
       description: "Tip description and explanation."
   )
   ```

---

## Design Guidelines

When adding or updating help content:

### Writing Style
- ✅ Use clear, conversational language
- ✅ Use bullet points for scanability
- ✅ Include step-by-step instructions where appropriate
- ✅ Use emojis sparingly for visual interest
- ✅ Keep paragraphs short

### Structure
- ✅ Use `HelpSection` components for consistency
- ✅ Include icon with gradient styling
- ✅ Group related information
- ✅ Use proper headings hierarchy

### Visual Elements
- ✅ Icons: Use SF Symbols
- ✅ Colors: Use gradient (blue to purple) for accents
- ✅ Spacing: 24pt between sections, 12pt within sections
- ✅ Background: Use `.secondarySystemGroupedBackground`

---

## Alternative Storage Options

While the current implementation stores everything in `HelpView.swift`, here are alternatives if you need them in the future:

### Option 1: Separate Swift Files (Current Approach ✅)
**Location:** `HelpView.swift`
- ✅ Fast and native
- ✅ No network required
- ✅ Easy to maintain
- ❌ Requires app update to change content

### Option 2: JSON Files in Bundle
**Location:** `Resources/Help/*.json`
```swift
struct HelpContent: Codable {
    let title: String
    let sections: [HelpSection]
}
```
- ✅ Easier to edit content
- ✅ Still works offline
- ❌ More complex parsing
- ❌ Still requires app update

### Option 3: Markdown Files
**Location:** `Resources/Help/*.md`
- ✅ Easy to write and edit
- ✅ Can use Markdown renderer
- ❌ Requires markdown parser dependency
- ❌ Still requires app update

### Option 4: Remote Server (Not Recommended)
**Location:** Remote API
- ✅ Update content without app update
- ❌ Requires network connection
- ❌ Requires backend infrastructure
- ❌ Slower user experience
- ❌ Privacy concerns

### Option 5: Hybrid Approach
**Location:** Bundle + Remote with caching
- ✅ Works offline with bundled content
- ✅ Updates when online available
- ❌ Complex implementation
- ❌ Requires backend

---

## Current Recommendation

**Stick with the current approach** (SwiftUI views in `HelpView.swift`) because:

1. **It's simple** - Everything in one file
2. **It's fast** - Native SwiftUI, no parsing
3. **It's offline** - No network dependencies
4. **It's beautiful** - Matches app design perfectly
5. **It's maintainable** - Easy to find and update content
6. **It's testable** - Can preview all help screens in Xcode

---

## Testing Help Content

### Preview in Xcode
```swift
#Preview {
    HelpView()
}
```

### Check All Sections
- [ ] Quick Start Guide
- [ ] Workouts Guide
- [ ] Analytics Guide
- [ ] Exercise Library Guide
- [ ] Friends & Social
- [ ] iCloud Sync
- [ ] Data Export
- [ ] Customization
- [ ] Tips & Tricks
- [ ] FAQ

### Verify Navigation
- [ ] All links work
- [ ] Back navigation works
- [ ] Search is functional (future enhancement)
- [ ] Done button dismisses sheet

### Test on Different Devices
- [ ] iPhone SE (small screen)
- [ ] iPhone 14 Pro (standard)
- [ ] iPhone 14 Pro Max (large)
- [ ] iPad (if supporting)

### Accessibility Testing
- [ ] VoiceOver reads all content
- [ ] Dynamic Type scaling works
- [ ] High contrast mode is readable
- [ ] Color blind friendly (not relying solely on color)

---

## Future Enhancements

Consider these improvements:

1. **Search Functionality**
   - Add `.searchable()` to main HelpView
   - Filter help topics by keyword

2. **Contextual Help**
   - Add "?" buttons throughout app
   - Deep link to specific help sections

3. **Video Tutorials**
   - Embed short tutorial videos
   - Link to YouTube channel

4. **Interactive Tutorials**
   - Step-by-step walkthroughs with highlights
   - Tooltips and coach marks

5. **User Contributions**
   - Allow users to suggest improvements
   - Feedback form in help section

6. **Analytics**
   - Track which help topics are most viewed
   - Identify confusing features

---

## Questions?

If you need help updating the help content (meta!), refer to this guide or check the inline comments in `HelpView.swift`.

The code is heavily commented to make updates easy even for non-developers.

---

**Last Updated:** December 30, 2024  
**Version:** 1.0.0
