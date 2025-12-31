# Bulk Selection Feature

## Overview

The Workouts page now supports bulk selection and actions, just like the Mail app! You can now efficiently manage multiple workouts at once.

## How to Use

### Entering Selection Mode
1. Go to the Workouts tab
2. Tap **"Select"** in the top-right corner
3. The UI changes to selection mode with checkboxes

### Selecting Workouts
**Individual Selection:**
- Tap on any workout row to select/deselect it
- Tap the circle icon on the left to toggle selection
- Selected workouts show a blue checkmark ✓

**Select All:**
1. In selection mode, tap **"Edit"** in the top-left
2. Choose **"Select All"** to select all visible workouts
3. Choose **"Deselect All"** to clear selection

### Bulk Actions

Once you've selected workouts, a toolbar appears at the bottom with these actions:

#### Archive (📦)
- Archives all selected workouts
- They'll be hidden from your main list
- Can be viewed by enabling "Show Archived Workouts"

#### Unarchive (📤)
- Restores archived workouts to your main list
- Useful when viewing archived workouts

#### Delete (🗑️)
- Permanently deletes all selected workouts
- Shows confirmation dialog if enabled in settings
- This action cannot be undone!

### Exiting Selection Mode
- Tap **"Done"** in the top-right corner
- Or tap **"Cancel"** from the Edit menu
- Selection is cleared automatically

## Features

### Selection Count
The bottom toolbar shows: **"X Selected"**
- Real-time count of selected items
- Helps you track how many workouts you've selected

### Visual Feedback
- ✓ Blue checkmarks for selected workouts
- Circle outlines for unselected workouts
- Haptic feedback when performing actions
- Smooth animations

### Safety Features
- Swipe actions are disabled in selection mode
- Navigation is disabled when selecting
- Confirmation dialogs for bulk delete (if enabled)
- Can't accidentally open a workout while selecting

### Smart Behavior
- Selection state is cleared when exiting
- Actions affect only selected workouts
- Respects "Show Archived Workouts" filter
- Works with grouped sections (This Week, Last Week, etc.)

## UI/UX Details

### Toolbar Layout
```
┌─────────────────────────────────────┐
│  Edit          Workouts       Select │ ← Normal mode
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Edit          Workouts         Done │ ← Selection mode
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│              3 Selected               │
│  [📦 Archive] [📤 Unarchive] [🗑️ Delete] │
└─────────────────────────────────────┘
```

### Selection Indicators
- **Selected**: Blue circle with checkmark
- **Unselected**: Gray circle outline
- **In selection mode**: Circles visible on all rows
- **Normal mode**: No circles shown

## Comparison with Individual Actions

### Before (Individual)
- Swipe left/right on each workout
- Archive/Delete one at a time
- Tedious for bulk operations

### After (Bulk Selection)
- Select multiple workouts at once
- Perform actions on all selected items
- Much faster for managing many workouts

## Implementation Details

### State Management
```swift
@State private var isSelecting = false
@State private var selectedWorkouts: Set<Workout.ID> = []
```

### Key Methods
- `toggleSelection(for:)` - Select/deselect individual workout
- `selectAll()` - Select all visible workouts
- `deselectAll()` - Clear all selections
- `bulkArchiveSelected()` - Archive selected workouts
- `bulkUnarchiveSelected()` - Unarchive selected workouts
- `bulkDeleteSelected()` - Delete selected workouts

### Conditional UI
The UI adapts based on selection mode:
- Toolbar buttons change (Select ↔ Done)
- Edit menu appears in selection mode
- Swipe actions disabled during selection
- Bottom toolbar appears when items selected

## Tips & Tricks

1. **Quick Archive Multiple**: 
   - Tap Select
   - Tap workouts you want to archive
   - Tap Archive
   - Done!

2. **Bulk Delete Old Workouts**:
   - Scroll to older sections
   - Tap Select → Select All
   - Tap Delete
   - Confirm

3. **Clean Up Your List**:
   - Use archive for workouts you might reference later
   - Use delete for workouts you no longer need
   - Keep your active list focused

4. **Review Before Action**:
   - Check the "X Selected" count
   - Make sure you've selected the right workouts
   - Use Deselect All if you made a mistake

## Accessibility

- Selection buttons have proper labels
- VoiceOver announces selection state
- Haptic feedback for actions
- Large tap targets for selection circles

## Future Enhancements

Possible additions:
- Bulk complete/uncomplete workouts
- Bulk export selected workouts
- Share multiple workouts at once
- Quick filter (select all completed, etc.)
- Keyboard shortcuts on iPad
- Drag to select multiple items

## Troubleshooting

**Can't swipe on workouts:**
- You're in selection mode
- Tap "Done" to exit selection mode

**Selection cleared:**
- This happens when exiting selection mode
- Intentional to prevent accidental actions

**Bottom toolbar not showing:**
- You need to select at least one workout
- Make sure you're in selection mode

**Actions affect wrong workouts:**
- Double-check your selection before acting
- Look at the "X Selected" count
- Use Deselect All to start over

---

**Status**: ✅ Implemented and ready to use!
**Inspired by**: iOS Mail app bulk selection
**Platform**: iOS, iPadOS
