import SwiftUI

/// Comprehensive help view explaining all app features
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Quick Start Guide
                Section {
                    NavigationLink {
                        QuickStartGuideView()
                    } label: {
                        HelpCategoryRow(
                            icon: "flag.checkered",
                            title: "Quick Start Guide",
                            description: "Get started with your first workout"
                        )
                    }
                }
                
                // Core Features
                Section("Core Features") {
                    NavigationLink {
                        WorkoutsHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "list.bullet.rectangle",
                            title: "Workouts",
                            description: "Create, track, and manage your workouts"
                        )
                    }
                    
                    NavigationLink {
                        AnalyticsHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "chart.bar.xaxis",
                            title: "Analytics",
                            description: "Track your progress with charts and stats"
                        )
                    }
                    
                    NavigationLink {
                        ExerciseLibraryHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "book.closed",
                            title: "Exercise Library",
                            description: "Browse exercises and learn proper form"
                        )
                    }
                    
                    NavigationLink {
                        SocialHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "person.2.fill",
                            title: "Friends & Social",
                            description: "Connect with friends and share progress"
                        )
                    }
                }
                
                // Advanced Features
                Section("Advanced Features") {
                    NavigationLink {
                        CloudSyncHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "icloud",
                            title: "iCloud Sync",
                            description: "Sync data across your devices"
                        )
                    }
                    
                    NavigationLink {
                        DataExportHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "square.and.arrow.up",
                            title: "Data Export & Backup",
                            description: "Export your workout data"
                        )
                    }
                    
                    NavigationLink {
                        CustomizationHelpView()
                    } label: {
                        HelpCategoryRow(
                            icon: "slider.horizontal.3",
                            title: "Customization",
                            description: "Personalize your experience"
                        )
                    }
                }
                
                // Tips & Tricks
                Section("Tips & Tricks") {
                    NavigationLink {
                        TipsAndTricksView()
                    } label: {
                        HelpCategoryRow(
                            icon: "lightbulb.fill",
                            title: "Pro Tips",
                            description: "Get the most out of the app"
                        )
                    }
                }
                
                // FAQ
                Section {
                    NavigationLink {
                        FAQView()
                    } label: {
                        HelpCategoryRow(
                            icon: "questionmark.circle",
                            title: "FAQ",
                            description: "Frequently asked questions"
                        )
                    }
                }
            }
            .navigationTitle("Help & Guide")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search help topics")
        }
    }
}

// MARK: - Help Category Row

private struct HelpCategoryRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Quick Start Guide

private struct QuickStartGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Welcome to LiftSphere Workout!", icon: "hand.wave.fill") {
                    Text("This quick guide will help you create your first workout and start tracking your fitness journey.")
                }
                
                HelpSection(title: "Step 1: Create a Workout", icon: "1.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Go to the **Workouts** tab")
                        Text("2. Tap the **+** button in the top right")
                        Text("3. Enter a workout name (e.g., 'Push Day' or 'Leg Day')")
                        Text("4. Add exercises from the library or type custom names")
                        Text("5. Tap **Create** when done")
                    }
                }
                
                HelpSection(title: "Step 2: Log Your Sets", icon: "2.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Tap on your workout from the list")
                        Text("2. Tap **+** next to any exercise")
                        Text("3. Enter the weight and reps you performed")
                        Text("4. Tap **Save Set**")
                        Text("5. Repeat for all your sets")
                    }
                }
                
                HelpSection(title: "Step 3: Complete Your Workout", icon: "3.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Once you're done:")
                        Text("• Swipe the workout right and tap **Complete**")
                        Text("• A green checkmark will appear")
                        Text("• Your stats will update in the Analytics tab")
                    }
                }
                
                HelpSection(title: "What's Next?", icon: "arrow.right.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("• Check out the **Analytics** tab to see your progress")
                        Text("• Browse the **Learn** tab to discover new exercises")
                        Text("• Connect with friends in the **Friends** tab")
                        Text("• Customize settings to your liking")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Quick Start")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Workouts Help

private struct WorkoutsHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Creating Workouts", icon: "plus.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Create custom workouts with your favorite exercises:")
                        Text("• Tap the **+** button")
                        Text("• Name your workout")
                        Text("• Add main exercises, core exercises, and stretches")
                        Text("• Set warmup, core, and stretch durations")
                    }
                }
                
                HelpSection(title: "Quick Repeat", icon: "arrow.counterclockwise") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quickly repeat a recent workout:")
                        Text("• Tap **Quick Repeat** at the top of the workout list")
                        Text("• Select a workout from the last 10")
                        Text("• A new copy is created with today's date")
                    }
                }
                
                HelpSection(title: "Swipe Actions", icon: "hand.draw") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("**Swipe right** on a workout for:")
                        Text("✓ Mark as complete/incomplete")
                        Text("📋 Duplicate the workout")
                        Text("🗑️ Delete the workout")
                        
                        Text("\n**Swipe left** for:")
                        Text("📦 Archive/unarchive")
                    }
                }
                
                HelpSection(title: "Bulk Actions", icon: "checkmark.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Manage multiple workouts at once:")
                        Text("1. Tap **Select** in the top right")
                        Text("2. Tap workouts to select them")
                        Text("3. Use toolbar buttons to:")
                        Text("   • Archive selected workouts")
                        Text("   • Unarchive selected workouts")
                        Text("   • Delete selected workouts")
                    }
                }
                
                HelpSection(title: "Import & Export", icon: "arrow.up.arrow.down") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("• Tap the **•••** menu to import or export workouts")
                        Text("• Export all workouts to JSON")
                        Text("• Import workouts from JSON files")
                        Text("• Great for backing up or transferring data")
                    }
                }
                
                HelpSection(title: "Archive Feature", icon: "archivebox") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Keep your workout list clean:")
                        Text("• Archive old or unused workouts")
                        Text("• Toggle **Show Archived** in Settings")
                        Text("• Archived workouts won't clutter your main view")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Workouts Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Analytics Help

private struct AnalyticsHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Overview Stats", icon: "chart.bar.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("See your fitness journey at a glance:")
                        Text("📊 Total workouts completed")
                        Text("💪 Total volume lifted")
                        Text("🔥 Current workout streak")
                        Text("📅 Average weekly workouts")
                    }
                }
                
                HelpSection(title: "Volume Over Time", icon: "chart.line.uptrend.xyaxis") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Track your weekly training volume:")
                        Text("• See trends over the last 12 weeks")
                        Text("• Identify your peak training weeks")
                        Text("• Monitor progressive overload")
                    }
                }
                
                HelpSection(title: "Top Exercises", icon: "trophy.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("View your most-trained movements:")
                        Text("• Ranked by total volume")
                        Text("• See exercise frequency")
                        Text("• Tap to view detailed history")
                    }
                }
                
                HelpSection(title: "Recent PRs", icon: "star.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Celebrate your personal records:")
                        Text("• Shows your latest achievements")
                        Text("• Weight × reps PRs")
                        Text("• Filter by recent activities")
                    }
                }
                
                HelpSection(title: "Muscle Group Distribution", icon: "figure.strengthtraining.traditional") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Balance your training:")
                        Text("• See which muscle groups you train most")
                        Text("• Identify potential imbalances")
                        Text("• Plan future workouts accordingly")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Analytics Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Exercise Library Help

private struct ExerciseLibraryHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Browse Exercises", icon: "book.closed.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explore our comprehensive exercise database:")
                        Text("• 150+ exercises covering all muscle groups")
                        Text("• Organized by muscle group")
                        Text("• Each exercise shows proper form and tips")
                    }
                }
                
                HelpSection(title: "Filtering Options", icon: "slider.horizontal.3") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Find exercises quickly:")
                        Text("🔍 **Search** by exercise name")
                        Text("💪 **Filter by muscle group** (chest, back, legs, etc.)")
                        Text("🏋️ **Filter by equipment** (barbell, dumbbell, bodyweight, etc.)")
                    }
                }
                
                HelpSection(title: "Favorites", icon: "star.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Save your go-to exercises:")
                        Text("• Tap the ⭐ icon to favorite an exercise")
                        Text("• Favorites appear at the top of the list")
                        Text("• Quick access to exercises you use most")
                    }
                }
                
                HelpSection(title: "Recently Used", icon: "clock.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("See your recent activity:")
                        Text("• Shows exercises from the last 7 days")
                        Text("• Displays your last set and PR")
                        Text("• Quick reference for progressive overload")
                    }
                }
                
                HelpSection(title: "Exercise Details", icon: "info.circle.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tap any exercise to see:")
                        Text("• Equipment needed")
                        Text("• Primary muscle groups worked")
                        Text("• Step-by-step instructions")
                        Text("• Form tips and safety notes")
                        Text("• Your personal history with that exercise")
                    }
                }
                
                HelpSection(title: "Low-Back Friendly", icon: "figure.walk") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Many exercises are marked as low-back friendly:")
                        Text("• Reduces stress on lower back")
                        Text("• Great for injury prevention")
                        Text("• Perfect for those with back concerns")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Exercise Library")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Social Help

private struct SocialHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Connect with Friends", icon: "person.2.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stay motivated together:")
                        Text("• Sign in with Apple to enable social features")
                        Text("• Add friends by username")
                        Text("• See each other's workout activity")
                    }
                }
                
                HelpSection(title: "Activity Feed", icon: "list.bullet") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stay up to date with your network:")
                        Text("• See when friends complete workouts")
                        Text("• View workout summaries")
                        Text("• React and comment on activities")
                        Text("• Get inspired by others' progress")
                    }
                }
                
                HelpSection(title: "Privacy", icon: "lock.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You're in control:")
                        Text("• Choose what to share")
                        Text("• Remove friends anytime")
                        Text("• Sign out to disable social features")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Friends & Social")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Cloud Sync Help

private struct CloudSyncHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "What is iCloud Sync?", icon: "icloud.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Keep your workout data synchronized:")
                        Text("• Automatic backup to iCloud")
                        Text("• Works across all your Apple devices")
                        Text("• No manual syncing required")
                    }
                }
                
                HelpSection(title: "Setup", icon: "gear") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("To enable iCloud sync:")
                        Text("1. Go to **Settings** on your device")
                        Text("2. Tap your name at the top")
                        Text("3. Select **iCloud**")
                        Text("4. Make sure iCloud Drive is enabled")
                        Text("5. Open LiftSphere Workout")
                    }
                }
                
                HelpSection(title: "Sync Status", icon: "checkmark.icloud") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Check sync status in Settings:")
                        Text("✓ **Synced** - All data backed up")
                        Text("⏳ **Syncing...** - Upload in progress")
                        Text("⚠️ **Not signed in** - Sign in to iCloud")
                    }
                }
                
                HelpSection(title: "Troubleshooting", icon: "exclamationmark.triangle") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("If sync isn't working:")
                        Text("• Check your internet connection")
                        Text("• Verify iCloud is enabled in device Settings")
                        Text("• Tap 'Check Sync Status' in app Settings")
                        Text("• Make sure you have iCloud storage space")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("iCloud Sync")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Export Help

private struct DataExportHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Why Export?", icon: "square.and.arrow.up") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export your data for:")
                        Text("📊 Custom analysis in Excel/Numbers")
                        Text("💾 Additional backups")
                        Text("📤 Sharing with coaches or trainers")
                        Text("🔄 Migrating to another app")
                    }
                }
                
                HelpSection(title: "Export Formats", icon: "doc.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("**Detailed CSV** - Every set with full details")
                        Text("Best for: Spreadsheet analysis")
                        
                        Text("\n**Summary CSV** - Workout overview")
                        Text("Best for: Quick reports")
                        
                        Text("\n**JSON** - Complete backup")
                        Text("Best for: Re-importing, complete backup")
                    }
                }
                
                HelpSection(title: "How to Export", icon: "arrow.up.doc") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("1. Open **Settings**")
                        Text("2. Go to **Data Export & Backup**")
                        Text("3. Tap **Export Workout Data**")
                        Text("4. Choose your format")
                        Text("5. Share via AirDrop, Files, email, etc.")
                    }
                }
                
                HelpSection(title: "Importing Data", icon: "arrow.down.doc") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Re-import your JSON backup:")
                        Text("1. Go to **Workouts** tab")
                        Text("2. Tap **•••** menu")
                        Text("3. Select **Import Workouts**")
                        Text("4. Choose your JSON file")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Data Export")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Customization Help

private struct CustomizationHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Appearance", icon: "paintbrush.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Customize the app's look:")
                        Text("• Choose between Light, Dark, or System theme")
                        Text("• Find in Settings → Appearance")
                    }
                }
                
                HelpSection(title: "Workout Display", icon: "list.bullet") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Control what you see:")
                        Text("• Toggle **Show Archived Workouts**")
                        Text("• Enable/disable **Confirm Before Delete**")
                        Text("• Find in Settings → Workouts")
                    }
                }
                
                HelpSection(title: "Exercise Filters", icon: "slider.horizontal.3") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personalize your exercise library:")
                        Text("• Filter by muscle group")
                        Text("• Filter by equipment type")
                        Text("• Save favorites for quick access")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Customization")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tips & Tricks

private struct TipsAndTricksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HelpSection(title: "Pro Tips", icon: "lightbulb.fill") {
                    VStack(alignment: .leading, spacing: 16) {
                        TipItem(
                            number: 1,
                            title: "Use Quick Repeat",
                            description: "Save time by duplicating recent workouts instead of creating new ones from scratch."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 2,
                            title: "Archive Old Workouts",
                            description: "Keep your main list clean by archiving workouts you no longer use regularly."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 3,
                            title: "Favorite Exercises",
                            description: "Star your go-to exercises for instant access at the top of the exercise library."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 4,
                            title: "Check Analytics Weekly",
                            description: "Review your stats every week to identify trends and adjust your training."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 5,
                            title: "Export Regularly",
                            description: "Create monthly backups by exporting to JSON. Store them in Files or iCloud Drive."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 6,
                            title: "Use Swipe Actions",
                            description: "Swipe on workouts for quick access to complete, duplicate, archive, or delete."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 7,
                            title: "Track Progressive Overload",
                            description: "View your last set and PR in the exercise library to know what to beat next time."
                        )
                        
                        Divider()
                        
                        TipItem(
                            number: 8,
                            title: "Balance Muscle Groups",
                            description: "Check the muscle group distribution in Analytics to ensure balanced training."
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Tips & Tricks")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TipItem: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - FAQ

private struct FAQView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                FAQItem(
                    question: "How do I delete a workout?",
                    answer: "Swipe right on any workout and tap the red delete button, or use Select mode for bulk deletion."
                )
                
                FAQItem(
                    question: "Can I use the app offline?",
                    answer: "Yes! All features work offline. Your data syncs to iCloud when you're back online."
                )
                
                FAQItem(
                    question: "Will I lose my data if I delete the app?",
                    answer: "If iCloud sync is enabled, your data is backed up. You can also export to JSON for extra safety."
                )
                
                FAQItem(
                    question: "How do I track bodyweight exercises?",
                    answer: "Create a workout with bodyweight exercises from the library. Enter '0' for weight or use just the reps field."
                )
                
                FAQItem(
                    question: "Can I customize exercises?",
                    answer: "You can add any custom exercise name when creating a workout, and it will be tracked just like library exercises."
                )
                
                FAQItem(
                    question: "What's the difference between archive and delete?",
                    answer: "Archive hides workouts from your main list but keeps the data. Delete permanently removes them."
                )
                
                FAQItem(
                    question: "How is volume calculated?",
                    answer: "Volume = Weight × Reps for each set, summed across all sets in a workout."
                )
                
                FAQItem(
                    question: "Can I share workouts with friends?",
                    answer: "Yes! Sign in with Apple to enable social features and share your activity with friends."
                )
                
                FAQItem(
                    question: "What if I make a mistake logging a set?",
                    answer: "You can delete sets by swiping left on them in the workout detail view."
                )
                
                FAQItem(
                    question: "How do I contact support?",
                    answer: "For support, email support@liftsphere.com with any questions or issues."
                )
            }
            .padding()
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(answer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Help Section Component

private struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.title3.bold())
            }
            
            content
                .font(.body)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    HelpView()
}
