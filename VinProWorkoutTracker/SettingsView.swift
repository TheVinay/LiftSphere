import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var syncMonitor = CloudKitSyncMonitor()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                // Branding at top (always show)
                if searchText.isEmpty {
                    brandingSection
                }
                
                // Main navigation menu
                if searchText.isEmpty || matchesSearch("Account") {
                    Section {
                        NavigationLink {
                            AccountSettingsView()
                        } label: {
                            Label("Account", systemImage: "person.circle")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                if searchText.isEmpty || matchesSearch("Data Sync iCloud") {
                    Section {
                        NavigationLink {
                            SyncSettingsView()
                        } label: {
                            HStack {
                                Label("Data & Sync", systemImage: syncMonitor.statusIcon)
                                    .foregroundStyle(syncMonitor.statusColor)
                                Spacer()
                                if syncMonitor.syncStatus == .syncing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        }
                    }
                }
                
                if searchText.isEmpty || matchesSearch("Workouts Archive Delete") {
                    Section {
                        NavigationLink {
                            WorkoutSettingsView()
                        } label: {
                            Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                if searchText.isEmpty || matchesSearch("Appearance Theme Dark Light") {
                    Section {
                        NavigationLink {
                            AppearanceSettingsView()
                        } label: {
                            Label("Appearance", systemImage: "paintbrush")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                if searchText.isEmpty || matchesSearch("Health Fitness") {
                    Section {
                        NavigationLink {
                            HealthSettingsView()
                        } label: {
                            Label("Apple Health", systemImage: "heart.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                if searchText.isEmpty || matchesSearch("Export Backup Data CSV JSON") {
                    Section {
                        NavigationLink {
                            DataExportView()
                        } label: {
                            Label("Data Export & Backup", systemImage: "square.and.arrow.up")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                // Support section
                if searchText.isEmpty || matchesSearch("Help Support Guide") {
                    Section {
                        NavigationLink {
                            HelpView()
                        } label: {
                            Label("Help & Support", systemImage: "questionmark.circle")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                // Legal section
                if searchText.isEmpty || matchesSearch("Privacy Policy Terms Legal") {
                    Section {
                        if searchText.isEmpty || matchesSearch("Privacy Policy") {
                            NavigationLink {
                                PrivacyPolicyView()
                            } label: {
                                Label("Privacy Policy", systemImage: "hand.raised")
                                    .foregroundStyle(.primary)
                            }
                        }
                        
                        if searchText.isEmpty || matchesSearch("Terms Service") {
                            NavigationLink {
                                TermsOfServiceView()
                            } label: {
                                Label("Terms of Service", systemImage: "doc.text")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                
                // About section at bottom (always show when not searching)
                if searchText.isEmpty {
                    appInfoSection
                }
            }
            .searchable(text: $searchText, prompt: "Search settings")
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Branding Section
    
    private var brandingSection: some View {
        Section {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text("LS")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading) {
                    Text("LiftSphere")
                        .font(.headline)
                    Text("Train smarter, track better.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
    
    private var appInfoSection: some View {
        Section("App") {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(buildNumber)
                    .foregroundStyle(.secondary)
            }
            
            Text("LiftSphere")
                .font(.headline)
            Text("Train smarter, track better.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Version Info
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    // MARK: - Search Helper
    
    private func matchesSearch(_ keywords: String) -> Bool {
        keywords.localizedCaseInsensitiveContains(searchText)
    }
}

// MARK: - CloudKit Debug View

struct CloudKitDebugView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logs: [String] = []
    @State private var isTesting = false
    @State private var containerName = ""
    @State private var accountStatus = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Status Section
                Section("Status") {
                    HStack {
                        Text("Container")
                        Spacer()
                        Text(containerName.isEmpty ? "Loading..." : containerName)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("iCloud Account")
                        Spacer()
                        Text(accountStatus.isEmpty ? "Checking..." : accountStatus)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Test Buttons
                Section("Diagnostics") {
                    Button {
                        runFullDiagnostics()
                    } label: {
                        Label("Run Full Diagnostics", systemImage: "stethoscope")
                    }
                    .disabled(isTesting)
                    
                    Button {
                        testRecordTypes()
                    } label: {
                        Label("Test Record Types", systemImage: "list.bullet.rectangle")
                    }
                    .disabled(isTesting)
                }
                
                // Logs
                if !logs.isEmpty {
                    Section {
                        ForEach(logs.indices, id: \.self) { index in
                            Text(logs[index])
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(
                                    logs[index].contains("✅") ? .green :
                                    logs[index].contains("❌") ? .red :
                                    logs[index].contains("⚠️") ? .orange : .primary
                                )
                        }
                    } header: {
                        HStack {
                            Text("Diagnostic Log")
                            Spacer()
                            Button("Clear") {
                                logs.removeAll()
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("CloudKit Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isTesting {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                getBasicInfo()
            }
        }
    }
    
    private func log(_ message: String) {
        logs.append(message)
    }
    
    private func getBasicInfo() {
        let container = CKContainer.default()
        containerName = container.containerIdentifier ?? "Unknown"
        
        Task {
            do {
                let status = try await container.accountStatus()
                await MainActor.run {
                    switch status {
                    case .available:
                        accountStatus = "✅ Available"
                    case .noAccount:
                        accountStatus = "❌ No Account"
                    case .restricted:
                        accountStatus = "❌ Restricted"
                    case .couldNotDetermine:
                        accountStatus = "⚠️ Unknown"
                    case .temporarilyUnavailable:
                        accountStatus = "⚠️ Temporarily Unavailable"
                    @unknown default:
                        accountStatus = "❓ Unknown"
                    }
                }
            } catch {
                await MainActor.run {
                    accountStatus = "❌ Error"
                }
            }
        }
    }
    
    private func runFullDiagnostics() {
        logs.removeAll()
        isTesting = true
        
        Task {
            log("🔍 Starting CloudKit Diagnostics")
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            let container = CKContainer.default()
            log("📦 Container: \(container.containerIdentifier ?? "Unknown")")
            
            // Check account
            log("🔐 Checking iCloud account...")
            do {
                let status = try await container.accountStatus()
                switch status {
                case .available:
                    log("✅ iCloud account available")
                case .noAccount:
                    log("❌ No iCloud account")
                    log("💡 Go to Settings > [Your Name] > Sign In")
                    await MainActor.run { isTesting = false }
                    return
                case .restricted:
                    log("❌ iCloud is restricted")
                    await MainActor.run { isTesting = false }
                    return
                case .couldNotDetermine:
                    log("⚠️ Could not determine status")
                case .temporarilyUnavailable:
                    log("⚠️ Temporarily unavailable")
                @unknown default:
                    log("❓ Unknown status")
                }
            } catch {
                log("❌ Error: \(error.localizedDescription)")
                await MainActor.run { isTesting = false }
                return
            }
            
            // Test public database
            log("🌐 Testing public database...")
            let publicDB = container.publicCloudDatabase
            let query = CKQuery(recordType: "UserProfile", predicate: NSPredicate(value: true))
            
            do {
                let results = try await publicDB.records(matching: query, desiredKeys: nil, resultsLimit: 1)
                log("✅ Successfully queried UserProfile")
                log("   Found \(results.matchResults.count) records")
            } catch let error as CKError {
                log("❌ CloudKit Error Code: \(error.code.rawValue)")
                log("   \(error.localizedDescription)")
                
                switch error.code {
                case .notAuthenticated:
                    log("💡 Not signed in to iCloud")
                case .networkUnavailable, .networkFailure:
                    log("💡 Check internet connection")
                case .serverRejectedRequest:
                    log("💡 Container not configured")
                    log("💡 Go to CloudKit Dashboard:")
                    log("   https://icloud.developer.apple.com/dashboard")
                case .unknownItem:
                    log("💡 UserProfile record type missing")
                    log("💡 Create it in CloudKit Dashboard")
                default:
                    log("💡 Error code: \(error.code.rawValue)")
                }
            } catch {
                log("❌ Error: \(error.localizedDescription)")
            }
            
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            log("✅ Diagnostics complete")
            log("")
            log("📱 Next Steps:")
            log("1. Go to CloudKit Dashboard")
            log("2. Create UserProfile record type")
            log("3. Create FriendRelationship record type")
            log("4. Create PublicWorkout record type")
            log("5. Set permissions on all three")
            
            await MainActor.run { isTesting = false }
        }
    }
    
    private func testRecordTypes() {
        logs.removeAll()
        isTesting = true
        
        Task {
            log("🧪 Testing record types...")
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            let container = CKContainer.default()
            let publicDB = container.publicCloudDatabase
            let recordTypes = ["UserProfile", "FriendRelationship", "PublicWorkout"]
            
            for recordType in recordTypes {
                log("Testing \(recordType)...")
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                
                do {
                    _ = try await publicDB.records(matching: query, desiredKeys: nil, resultsLimit: 1)
                    log("✅ \(recordType) exists")
                } catch let error as CKError {
                    if error.code == .unknownItem {
                        log("❌ \(recordType) NOT found")
                        log("   Create in CloudKit Dashboard")
                    } else {
                        log("⚠️ \(recordType): \(error.localizedDescription)")
                    }
                } catch {
                    log("⚠️ \(recordType): \(error.localizedDescription)")
                }
            }
            
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            log("✅ Test complete")
            
            await MainActor.run { isTesting = false }
        }
    }
}

// MARK: - Account Settings View
struct AccountSettingsView: View {
    @Environment(AuthenticationManager.self) private var authManager
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("displayName") private var storedDisplayName: String = ""
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false
    
    @State private var showAppleSignIn = false
    @State private var showDeleteAccountConfirmation = false
    
    var body: some View {
        Form {
            // Account Status Section
            Section {
                if authManager.isAuthenticated {
                    // Signed in state
                    HStack(spacing: 12) {
                        Image(systemName: authManager.userEmail.isEmpty ? "person.circle.fill" : "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(authManager.userEmail.isEmpty ? .blue : .green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if authManager.userEmail.isEmpty {
                                Text("Guest User")
                                    .font(.headline)
                                Text("Local account only")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Signed in with Apple")
                                    .font(.headline)
                                
                                if !authManager.userName.isEmpty {
                                    Text(authManager.userName)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                if !authManager.userEmail.isEmpty {
                                    Text(authManager.userEmail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    // Not signed in state
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Not signed in")
                                    .font(.headline)
                                Text("Sign in to sync across devices")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Button {
                            showAppleSignIn = true
                        } label: {
                            Label("Sign in with Apple", systemImage: "applelogo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Account Status")
            } footer: {
                if authManager.isAuthenticated {
                    Text("Your account is connected and your data syncs across all your devices.")
                } else {
                    Text("Sign in to backup your workouts and access them on all your devices.")
                }
            }
            
            // Actions Section (only show when signed in)
            if authManager.isAuthenticated {
                Section {
                    Button(role: .destructive) {
                        authManager.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } footer: {
                    Text("Signing out will keep your local data but stop syncing until you sign in again.")
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showDeleteAccountConfirmation = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This will permanently delete your account and all associated data from our servers. This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAppleSignIn) {
            AppleSignInView { name in
                storedDisplayName = name
                isSignedIn = true
                didChooseLogin = true
                showAppleSignIn = false
            }
        }
        .confirmationDialog(
            "Delete Account?",
            isPresented: $showDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                // TODO: Implement account deletion
                authManager.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all data. This cannot be undone.")
        }
    }
}

// MARK: - Sync Settings View

struct SyncSettingsView: View {
    @State private var syncMonitor = CloudKitSyncMonitor()
    @State private var showCloudKitDebug = false
    
    var body: some View {
        Form {
            // Sync Status Section
            Section {
                HStack(spacing: 12) {
                    Image(systemName: syncMonitor.statusIcon)
                        .font(.title)
                        .foregroundStyle(syncMonitor.statusColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iCloud Sync")
                            .font(.headline)
                        Text(syncMonitor.statusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if syncMonitor.syncStatus == .syncing {
                        ProgressView()
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Sync Status")
            } footer: {
                Text("Your workouts are automatically backed up to iCloud and synced across your devices.")
            }
            
            // Not Signed In Warning
            if syncMonitor.syncStatus == .notSignedIn {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("iCloud Not Available")
                                    .font(.headline)
                                Text("Sign in to enable sync")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("To enable iCloud sync:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Open Settings app", systemImage: "1.circle.fill")
                            Label("Tap your name at the top", systemImage: "2.circle.fill")
                            Label("Select iCloud", systemImage: "3.circle.fill")
                            Label("Sign in with your Apple ID", systemImage: "4.circle.fill")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Actions Section
            Section {
                Button {
                    syncMonitor.checkAccountStatus()
                } label: {
                    Label("Refresh Sync Status", systemImage: "arrow.clockwise")
                }
            } header: {
                Text("Actions")
            }
            
            // Advanced Section
            Section {
                Button {
                    showCloudKitDebug = true
                } label: {
                    Label("CloudKit Diagnostics", systemImage: "stethoscope")
                }
            } header: {
                Text("Advanced")
            } footer: {
                Text("Use diagnostics to troubleshoot sync issues and check CloudKit configuration.")
            }
            
            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How iCloud Sync Works")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Automatic Backup")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Your workouts are backed up automatically")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "icloud.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cross-Device Sync")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Access your data on all your devices")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Private & Secure")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Your data is encrypted and only accessible by you")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("About iCloud Sync")
            }
        }
        .navigationTitle("Data & Sync")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCloudKitDebug) {
            CloudKitDebugView()
        }
    }
}

// MARK: - Workout Settings View

struct WorkoutSettingsView: View {
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Show Archived Workouts", isOn: $showArchivedWorkouts)
                Toggle("Confirm Before Delete", isOn: $confirmBeforeDelete)
            } header: {
                Text("Display Options")
            } footer: {
                Text("Choose how workouts are displayed and deleted in the app.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "archivebox.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Archived Workouts")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Hide completed workouts from your main list to keep things organized")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "trash.fill")
                            .foregroundStyle(.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Delete Confirmation")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Prevent accidental deletions with a confirmation prompt")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("About These Settings")
            }
        }
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Appearance Settings View
struct AppearanceSettingsView: View {
    @AppStorage("appTheme") private var theme: Int = 0
    
    private enum Appearance: Int, CaseIterable, Identifiable {
        case system = 0
        case light  = 1
        case dark   = 2
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $theme) {
                    ForEach(Appearance.allCases) { style in
                        Text(style.title).tag(style.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("App Theme")
            } footer: {
                Text("Choose how the app looks. System follows your device settings.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "iphone")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("System")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Automatically match your device's appearance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Light")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Bright appearance for daytime use")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(.indigo)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dark")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Darker appearance easier on the eyes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Theme Options")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Health Settings View

struct HealthSettingsView: View {
    @AppStorage("syncWorkoutsToHealth") private var syncWorkoutsToHealth: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Sync Workouts to Apple Health", isOn: $syncWorkoutsToHealth)
            } header: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("Apple Health Integration")
                }
            } footer: {
                Text("When enabled, completed workouts will automatically appear in the Health app.")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Workout Data")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Exercise type, duration, and calories burned")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Activity Tracking")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Contribute to your daily activity rings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Private & Secure")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Your data stays on your device, encrypted")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("What Gets Synced")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("To manage Health permissions:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Open Settings app", systemImage: "1.circle.fill")
                        Label("Scroll to Health", systemImage: "2.circle.fill")
                        Label("Tap Data Access & Devices", systemImage: "3.circle.fill")
                        Label("Select LiftSphere Workout", systemImage: "4.circle.fill")
                        Label("Adjust permissions", systemImage: "5.circle.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Manage Permissions")
            }
        }
        .navigationTitle("Health & Fitness")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]
    
    @State private var showExportOptions = false
    @State private var exportError: String?
    @State private var shareItem: ShareItem?
    @State private var isExporting = false
    
    var body: some View {
        Form {
            Section {
                Button {
                    showExportOptions = true
                } label: {
                    HStack {
                        Label("Export Workout Data", systemImage: "square.and.arrow.up")
                        Spacer()
                        Text("\(workouts.count) workouts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(workouts.isEmpty)
            } header: {
                Text("Export Options")
            } footer: {
                if workouts.isEmpty {
                    Text("No workouts to export. Complete some workouts first!")
                } else {
                    Text("Export your workout data for backup or analysis in other apps.")
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "tablecells")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Detailed CSV")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Every set, rep, and weight — perfect for spreadsheets")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Summary CSV")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Workout overview with totals — quick analysis")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("JSON")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Complete backup with all data — full restore capability")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Export Formats")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Pro Tip")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Use JSON format for complete backups. Import this file later to restore all your workout data if needed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Data Export & Backup")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Export Format", isPresented: $showExportOptions) {
            Button("Detailed CSV (All Sets)") {
                exportData(format: .detailedCSV)
            }
            
            Button("Summary CSV (Workout Overview)") {
                exportData(format: .summaryCSV)
            }
            
            Button("JSON (Complete Backup)") {
                exportData(format: .json)
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose export format for your \(workouts.count) workouts")
        }
        .alert("Export Error", isPresented: .constant(exportError != nil)) {
            Button("OK") {
                exportError = nil
            }
        } message: {
            if let error = exportError {
                Text(error)
            }
        }
        .sheet(item: $shareItem) { item in
            ActivityView(activityItems: [item.url])
        }
        .overlay {
            if isExporting {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView("Exporting...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func exportData(format: ExportManager.ExportFormat) {
        guard !workouts.isEmpty else {
            exportError = "No workouts to export"
            return
        }
        
        isExporting = true
        
        Task {
            do {
                let fileURL = try ExportManager.createExportFile(
                    workouts: workouts,
                    format: format
                )
                
                await MainActor.run {
                    isExporting = false
                    shareItem = ShareItem(url: fileURL)
                }
            } catch {
                await MainActor.run {
                    isExporting = false
                    exportError = error.localizedDescription
                }
            }
        }
    }
}



