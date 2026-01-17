import SwiftUI

struct SocialPrivacySettingsView: View {
    @State private var settings = SocialPrivacySettings.load()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPresetSheet = false
    @State private var socialService = SocialService() // 🆕 For CloudKit sync
    
    var body: some View {
        Form {
            // Quick Presets
            Section {
                Button {
                    showPresetSheet = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(.blue)
                        Text("Privacy Presets")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Quick Setup")
            }
            
            // Profile Visibility
            Section {
                Picker("Profile Visibility", selection: $settings.profileVisibility) {
                    ForEach(SocialPrivacySettings.Visibility.allCases, id: \.self) { visibility in
                        Label(visibility.rawValue, systemImage: visibility.icon)
                            .tag(visibility)
                    }
                }
                
                Toggle("Show Profile Photo", isOn: $settings.showProfilePhoto)
                Toggle("Show Bio", isOn: $settings.showBio)
            } header: {
                Text("Profile")
            } footer: {
                Text(settings.profileVisibility.description)
            }
            
            // Stats Visibility
            Section {
                Toggle("Show Workout Count", isOn: $settings.showWorkoutCount)
                Toggle("Show Total Volume", isOn: $settings.showTotalVolume)
                Toggle("Show Workout Streak", isOn: $settings.showStreak)
                Toggle("Show Personal Records", isOn: $settings.showPersonalRecords)
            } header: {
                Text("Stats")
            } footer: {
                Text("Control which statistics are visible to others")
            }
            
            // Workout Sharing
            Section {
                Toggle("Auto-share Completed Workouts", isOn: $settings.autoShareWorkouts)
                    .tint(.blue)
                
                Toggle("Show Exercise Names", isOn: $settings.showExerciseNames)
                    .disabled(!canShareWorkouts)
                
                Toggle("Show Set Details (Weight/Reps)", isOn: $settings.showSetDetails)
                    .disabled(!canShareWorkouts)
                
                Toggle("Show Workout Notes", isOn: $settings.showWorkoutNotes)
                    .disabled(!canShareWorkouts)
            } header: {
                Text("Workout Sharing")
            } footer: {
                if settings.autoShareWorkouts {
                    Text("Workouts will automatically appear in your friends' feeds when completed")
                } else {
                    Text("You can manually share workouts from the workout detail screen")
                }
            }
            
            // Social Interactions
            Section {
                Picker("Who Can Follow You", selection: $settings.whoCanFollow) {
                    ForEach(SocialPrivacySettings.FollowPermission.allCases, id: \.self) { permission in
                        Text(permission.rawValue)
                            .tag(permission)
                    }
                }
                
                Toggle("Allow Workout Reactions", isOn: $settings.allowWorkoutReactions)
                Toggle("Allow Comments", isOn: $settings.allowComments)
            } header: {
                Text("Interactions")
            } footer: {
                Text(settings.whoCanFollow.description)
            }
            
            // Privacy Summary
            Section {
                privacySummary
            } header: {
                Text("Privacy Summary")
            }
        }
        .navigationTitle("Social Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    settings.save()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showPresetSheet) {
            presetSelectionSheet
        }
        .onChange(of: settings) { oldValue, newValue in
            newValue.save() // Save to UserDefaults
            
            // 🆕 Sync to CloudKit
            Task {
                do {
                    try await socialService.updatePrivacySettings(newValue)
                    print("✅ Privacy settings synced to CloudKit")
                } catch {
                    print("⚠️ Failed to sync privacy settings: \(error.localizedDescription)")
                    // Fail silently - settings are still saved locally
                }
            }
        }
    }
    
    private var canShareWorkouts: Bool {
        settings.profileVisibility != .nobody
    }
    
    private var privacySummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: settings.profileVisibility.icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(privacyLevel)
                        .font(.headline)
                    Text(privacyDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if settings.profileVisibility != .nobody {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Others can see:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ForEach(visibleItems, id: \.self) { item in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text(item)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var privacyLevel: String {
        switch settings.profileVisibility {
        case .everyone:
            return "Public Profile"
        case .friendsOnly:
            return "Friends Only Profile"
        case .nobody:
            return "Private Profile"
        }
    }
    
    private var privacyDescription: String {
        switch settings.profileVisibility {
        case .everyone:
            return "Your profile and activity are visible to all users"
        case .friendsOnly:
            return "Only people you follow can see your activity"
        case .nobody:
            return "Your profile is completely hidden from others"
        }
    }
    
    private var visibleItems: [String] {
        var items: [String] = []
        
        if settings.showBio { items.append("Bio") }
        if settings.showWorkoutCount { items.append("Workout count") }
        if settings.showTotalVolume { items.append("Total volume") }
        if settings.showStreak { items.append("Workout streak") }
        if settings.showPersonalRecords { items.append("Personal records") }
        if settings.autoShareWorkouts { items.append("Shared workouts") }
        
        return items.isEmpty ? ["Nothing - Profile is private"] : items
    }
    
    private var presetSelectionSheet: some View {
        NavigationStack {
            List {
                PresetRow(
                    title: "Public",
                    icon: "globe",
                    description: "Share everything with everyone",
                    color: .blue
                ) {
                    settings = .publicPreset
                    showPresetSheet = false
                }
                
                PresetRow(
                    title: "Friends Only",
                    icon: "person.2",
                    description: "Share with people you follow",
                    color: .green
                ) {
                    settings = .friendsOnlyPreset
                    showPresetSheet = false
                }
                
                PresetRow(
                    title: "Private",
                    icon: "lock",
                    description: "Keep everything private",
                    color: .orange
                ) {
                    settings = .privatePreset
                    showPresetSheet = false
                }
            }
            .navigationTitle("Choose Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showPresetSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct PresetRow: View {
    let title: String
    let icon: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.blue)
                    .opacity(0)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SocialPrivacySettingsView()
    }
}
