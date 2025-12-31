# Import & Export Features

## Overview

Your workout tracker now supports importing and exporting workouts, making it easy to backup your data, transfer between devices, or share with others.

## How to Access

### Import/Export Menu
Located in the **top-left corner** of the Workouts page:
- Tap the **⋯** (ellipsis) button
- Choose either "Import Workouts" or "Export All"

## Export Workouts

### What Gets Exported
When you export, **ALL** workouts are included:
- ✅ Workout name and date
- ✅ Exercise lists (main, accessory, stretches)
- ✅ All logged sets (exercise name, weight, reps, timestamp)
- ✅ Durations (warmup, core, stretch minutes)
- ✅ Notes
- ✅ Completion and archive status

### Export Format
Workouts are exported as **JSON** files:
- Human-readable format
- ISO 8601 date encoding
- Pretty-printed for easy viewing
- File name: `liftsphere_workouts_[timestamp].json`

### How to Export
1. Tap **⋯** menu in top-left
2. Select **"Export All"**
3. Share sheet appears with options:
   - Save to Files
   - AirDrop to another device
   - Share via Messages/Mail
   - Save to iCloud Drive
   - Copy to other apps

### Example Export File Structure
```json
{
  "exportedAt": "2025-12-30T12:00:00Z",
  "workouts": [
    {
      "date": "2025-12-29T10:00:00Z",
      "name": "Push Day",
      "warmupMinutes": 10,
      "coreMinutes": 45,
      "stretchMinutes": 10,
      "mainExercises": ["Bench Press", "Overhead Press"],
      "coreExercises": ["Tricep Extensions"],
      "stretches": ["Shoulder Stretch"],
      "sets": [
        {
          "exerciseName": "Bench Press",
          "weight": 135.0,
          "reps": 10,
          "timestamp": "2025-12-29T10:15:00Z"
        }
      ]
    }
  ]
}
```

## Import Workouts

### What Can Be Imported
- JSON files exported from this app
- Files must match the export format
- Compatible with exports from other devices

### How to Import
1. Tap **⋯** menu in top-left
2. Select **"Import Workouts"**
3. File picker appears
4. Navigate to your workout file
5. Select the JSON file
6. Workouts are imported automatically

### Import Behavior
- **Adds** workouts to your existing collection
- **Does not** delete or replace existing workouts
- **Preserves** all workout details
- **Shows** success alert with count

### Success Alert
After import, you'll see:
```
Import Successful
Successfully imported X workouts
```

### Error Handling
If import fails, you'll see specific error messages:
- "Failed to read file" - File couldn't be opened
- "Failed to import" - JSON format incorrect
- Detailed error description included

## Use Cases

### 1. Backup Your Data
**Regular backups:**
1. Export all workouts monthly
2. Save to iCloud Drive or local storage
3. Keep multiple backup copies

### 2. Transfer Between Devices
**Moving to new phone:**
1. Export from old device
2. Save to iCloud or AirDrop
3. Import on new device

### 3. Share with Others
**Share workout history:**
1. Export workouts
2. Send via AirDrop/Messages/Email
3. Recipient can import to their app

### 4. Restore After Reinstall
**App reinstallation:**
1. Export before deleting app
2. Reinstall app
3. Import your saved workouts

### 5. Sync Across Multiple Devices
**Manual sync:**
1. Export from Device A
2. Transfer file (AirDrop, iCloud, etc.)
3. Import on Device B

## File Management

### Storage Location
Exported files are stored temporarily:
- System temp directory during export
- You choose final location via share sheet

### File Naming
Format: `liftsphere_workouts_[timestamp].json`
- Example: `liftsphere_workouts_1735560000.json`
- Timestamp ensures unique names
- Easy to identify by date

### File Size
Typical file sizes:
- 10 workouts: ~10-20 KB
- 100 workouts: ~100-200 KB
- 1000 workouts: ~1-2 MB

Very efficient storage!

## Data Privacy

### Export Privacy
- Files contain your workout data
- Store securely (encrypted cloud storage recommended)
- Be cautious when sharing

### Import Privacy
- Only import files you trust
- Files from unknown sources could contain anything
- Review file contents if unsure

## Advanced Usage

### Manual Editing
You can manually edit exported JSON files:
1. Export workouts
2. Open in text editor
3. Modify as needed (follow format)
4. Import modified file

**Use cases:**
- Bulk rename workouts
- Adjust dates
- Fix typos
- Remove specific workouts

### Selective Import
To import only specific workouts:
1. Export all workouts
2. Edit JSON file to keep only desired workouts
3. Import edited file

### Merge Data
To merge workouts from multiple sources:
1. Export from Device A
2. Export from Device B
3. Manually combine JSON files
4. Import combined file

## Troubleshooting

### Export Issues

**"Export failed" error:**
- Check available storage space
- Restart app and try again
- Make sure workouts exist

**Share sheet doesn't appear:**
- Wait a moment (large exports take time)
- Check for app permissions
- Try exporting again

### Import Issues

**"Failed to read file" error:**
- Verify file is JSON format
- Check file isn't corrupted
- Try re-downloading/re-exporting

**"Failed to import" error:**
- File format doesn't match expected structure
- JSON syntax errors
- Required fields missing

**No workouts appear after import:**
- Check if import was successful (alert shown)
- Verify workouts aren't filtered (archived view)
- Try exporting again from source

**Duplicate workouts after import:**
- Import adds workouts, doesn't check for duplicates
- Manually delete duplicates using bulk selection
- Use unique names to identify duplicates

## Best Practices

### Regular Backups
✅ Export weekly or monthly
✅ Store in multiple locations
✅ Label files clearly (add notes to filename)
✅ Test restore process occasionally

### File Organization
✅ Create dedicated backup folder
✅ Use descriptive names
✅ Keep recent backups only (delete old ones)
✅ Consider automated cloud backup

### Security
✅ Encrypt sensitive backup files
✅ Use secure cloud storage (iCloud with encryption)
✅ Don't share personal workout data publicly
✅ Delete temp files after transfer

### Data Integrity
✅ Verify export completed successfully
✅ Test import before deleting source
✅ Keep original files until import confirmed
✅ Check imported workout count matches

## Technical Details

### JSON Schema
The export uses this structure:
- Top level: `WorkoutExportFile`
  - `exportedAt`: Date (ISO 8601)
  - `workouts`: Array of `ExportedWorkout`

- Each `ExportedWorkout`:
  - `date`, `name`, durations, exercises, notes
  - `sets`: Array of `ExportedSet`

- Each `ExportedSet`:
  - `exerciseName`, `weight`, `reps`, `timestamp`

### Date Encoding
- Uses ISO 8601 format
- UTC timezone
- Example: `2025-12-30T15:30:00Z`
- Compatible across devices/timezones

### Compatibility
- Works with SwiftData models
- Future-proof format
- Extensible for new features
- Backward compatible

## Future Enhancements

Potential additions:
- CSV export for spreadsheet analysis
- PDF export for printing
- Selective export (choose specific workouts)
- Cloud sync (automatic backup)
- Scheduled exports
- Export filtering (date range, workout type)
- Import conflict resolution
- Duplicate detection

## Comparison with Other Features

### vs. Share to Friends
- **Export/Import**: Full backup of all data
- **Share to Friends**: Shares summary only

### vs. PDF Export
- **JSON Export**: Complete data, re-importable
- **PDF Export**: Human-readable, print-friendly

### vs. Bulk Selection
- **Export**: Save all workouts to file
- **Bulk Selection**: Manage workouts in-app

## FAQ

**Q: Can I import workouts from other fitness apps?**
A: Only if they export in the same JSON format. Manual conversion may be possible.

**Q: Will importing overwrite my existing workouts?**
A: No, import adds workouts. Your existing data is safe.

**Q: Can I export just one workout?**
A: Currently exports all workouts. Use manual editing to extract specific ones.

**Q: Is there a limit on file size?**
A: No practical limit. Even thousands of workouts = small file size.

**Q: Can I automate backups?**
A: Not currently, but you can export regularly. Consider Shortcuts app integration.

**Q: What if I need help with JSON editing?**
A: Use a JSON validator (jsonlint.com) or text editor with JSON support.

---

**Status**: ✅ Fully implemented and ready to use!
**Location**: Workouts tab → ⋯ menu → Import/Export
**Formats**: JSON (import & export)
