import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AuthenticationManager.self) private var authManager
    
    @Query(sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]
    
    @State private var syncMonitor = CloudKitSyncMonitor()

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

    // MARK: - AppStorage

    @AppStorage("appTheme") private var theme: Int = Appearance.system.rawValue
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("displayName") private var storedDisplayName: String = ""
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false

    @State private var showAppleSignIn = false
    @State private var showExportOptions = false
    @State private var exportError: String?
    @State private var shareItem: ShareItem?
    @State private var isExporting = false
    
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showHelp = false

    var body: some View {
        NavigationStack {
            Form {
                brandingSection
                accountSection
                syncSection
                appearanceSection
                workoutsSection
                dataExportSection
                helpSection
                legalSection
                appInfoSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAppleSignIn) {
                AppleSignInView { name in
                    storedDisplayName = name
                    isSignedIn = true
                    didChooseLogin = true
                    showAppleSignIn = false
                }
            }
            .sheet(isPresented: $showHelp) {
                HelpView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                Text("Privacy Policy - Coming Soon")
                // PrivacyPolicyView()
            }
            .sheet(isPresented: $showTerms) {
                Text("Terms of Service - Coming Soon")
                // TermsOfServiceView()
            }
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
                    exportingOverlay
                }
            }
        }
    }
    
    // MARK: - Sections
    
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
                    Text("LiftSphere Workout")
                        .font(.headline)
                    Text("Vin Edition • Designed by Vin")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
    
    private var accountSection: some View {
        Section("Account") {
            if authManager.isAuthenticated {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Signed in with Apple")
                        .font(.subheadline)
                    if !authManager.userName.isEmpty {
                        Text(authManager.userName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !authManager.userEmail.isEmpty {
                        Text(authManager.userEmail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } else {
                Text("Not signed in")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var syncSection: some View {
        Section {
            HStack {
                Image(systemName: syncMonitor.statusIcon)
                    .foregroundStyle(syncMonitor.statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud Sync")
                        .font(.subheadline)
                    Text(syncMonitor.statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if syncMonitor.syncStatus == .syncing {
                    ProgressView()
                }
            }
            
            if syncMonitor.syncStatus == .notSignedIn {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sign in to iCloud")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Go to Settings > [Your Name] > iCloud to sign in. Your workout data will automatically sync across all your devices.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Button {
                syncMonitor.checkAccountStatus()
            } label: {
                Label("Check Sync Status", systemImage: "arrow.clockwise")
            }
        } header: {
            Text("Data & Sync")
        } footer: {
            Text("Your workouts are automatically backed up to iCloud and synced across your devices.")
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $theme) {
                ForEach(Appearance.allCases) { style in
                    Text(style.title).tag(style.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var workoutsSection: some View {
        Section("Workouts") {
            Toggle("Show Archived Workouts", isOn: $showArchivedWorkouts)
            Toggle("Confirm Before Delete", isOn: $confirmBeforeDelete)
        }
    }
    
    private var dataExportSection: some View {
        Section("Data Export & Backup") {
            Button {
                showExportOptions = true
            } label: {
                Label("Export Workout Data", systemImage: "square.and.arrow.up")
            }
            
            Text("Export your workouts to CSV or JSON for backup or analysis")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var helpSection: some View {
        Section("Help & Support") {
            Button {
                showHelp = true
            } label: {
                Label("Help & User Guide", systemImage: "questionmark.circle")
            }
        }
    }
    
    private var legalSection: some View {
        Section("Legal") {
            Button {
                showPrivacyPolicy = true
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            Button {
                showTerms = true
            } label: {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }
    
    private var appInfoSection: some View {
        Section("App") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            Text("LiftSphere Workout – Vin Edition")
                .font(.headline)
            Text("Back-friendly workout tracking with analytics.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    private var exportingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView("Exporting...")
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Export Logic
    
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
