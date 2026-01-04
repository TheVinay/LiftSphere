import SwiftUI
import CloudKit

/// Debug view to test and verify CloudKit configuration
struct CloudKitDebugView: View {
    @State private var logs: [LogEntry] = []
    @State private var isTesting = false
    @State private var containerName = ""
    @State private var accountStatus = ""
    
    struct LogEntry: Identifiable {
        let id = UUID()
        let message: String
        let type: LogType
        let timestamp: Date = Date()
        
        enum LogType {
            case info, success, warning, error
            
            var color: Color {
                switch self {
                case .info: return .blue
                case .success: return .green
                case .warning: return .orange
                case .error: return .red
                }
            }
            
            var icon: String {
                switch self {
                case .info: return "info.circle.fill"
                case .success: return "checkmark.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .error: return "xmark.circle.fill"
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Cards
                    VStack(spacing: 12) {
                        StatusCard(
                            title: "Container",
                            value: containerName.isEmpty ? "Unknown" : containerName,
                            icon: "externaldrive.fill.badge.icloud"
                        )
                        
                        StatusCard(
                            title: "iCloud Status",
                            value: accountStatus.isEmpty ? "Checking..." : accountStatus,
                            icon: "person.crop.circle"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Test Buttons
                    VStack(spacing: 12) {
                        Button {
                            runDiagnostics()
                        } label: {
                            Label("Run Full Diagnostics", systemImage: "stethoscope")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isTesting)
                        
                        Button {
                            testContainerAccess()
                        } label: {
                            Label("Test Container Access", systemImage: "externaldrive.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isTesting)
                        
                        Button {
                            testRecordTypes()
                        } label: {
                            Label("Test Record Types", systemImage: "list.bullet.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isTesting)
                    }
                    .padding(.horizontal)
                    
                    // Logs
                    if !logs.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Diagnostic Log")
                                    .font(.headline)
                                Spacer()
                                Button("Clear") {
                                    logs.removeAll()
                                }
                                .font(.caption)
                            }
                            .padding()
                            
                            Divider()
                            
                            ForEach(logs) { log in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: log.type.icon)
                                        .foregroundColor(log.type.color)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.message)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.primary)
                                        
                                        Text(log.timestamp, style: .time)
                                            .font(.system(.caption2, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                
                                if log.id != logs.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("CloudKit Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isTesting {
                        ProgressView()
                    }
                }
            }
            .onAppear {
                getBasicInfo()
            }
        }
    }
    
    private func log(_ message: String, type: LogEntry.LogType = .info) {
        logs.append(LogEntry(message: message, type: type))
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
                        accountStatus = "❓ Unknown Status"
                    }
                }
            } catch {
                await MainActor.run {
                    accountStatus = "❌ Error"
                }
            }
        }
    }
    
    private func runDiagnostics() {
        logs.removeAll()
        isTesting = true
        
        Task {
            log("🔍 Starting CloudKit Diagnostics", type: .info)
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", type: .info)
            
            // Test 1: Container Info
            let container = CKContainer.default()
            log("📦 Container ID: \(container.containerIdentifier ?? "Unknown")", type: .info)
            
            // Test 2: Account Status
            log("🔐 Checking iCloud account status...", type: .info)
            do {
                let status = try await container.accountStatus()
                switch status {
                case .available:
                    log("✅ iCloud account is available", type: .success)
                case .noAccount:
                    log("❌ No iCloud account - Sign in to iCloud in Settings", type: .error)
                    await MainActor.run { isTesting = false }
                    return
                case .restricted:
                    log("❌ iCloud is restricted on this device", type: .error)
                    await MainActor.run { isTesting = false }
                    return
                case .couldNotDetermine:
                    log("⚠️ Could not determine iCloud status", type: .warning)
                case .temporarilyUnavailable:
                    log("⚠️ iCloud temporarily unavailable", type: .warning)
                @unknown default:
                    log("❓ Unknown iCloud status", type: .warning)
                }
            } catch {
                log("❌ Error checking account: \(error.localizedDescription)", type: .error)
                await MainActor.run { isTesting = false }
                return
            }
            
            // Test 3: Public Database Access
            log("🌐 Testing public database access...", type: .info)
            let publicDB = container.publicCloudDatabase
            
            // Test 4: Query for UserProfile records
            log("🔍 Querying UserProfile records...", type: .info)
            let query = CKQuery(recordType: "UserProfile", predicate: NSPredicate(value: true))
            
            do {
                let results = try await publicDB.records(matching: query, desiredKeys: nil, resultsLimit: 1)
                log("✅ Successfully queried UserProfile records", type: .success)
                log("   Found \(results.matchResults.count) record(s)", type: .info)
            } catch let error as CKError {
                log("❌ CloudKit Error: \(error.code.rawValue)", type: .error)
                log("   \(error.localizedDescription)", type: .error)
                
                switch error.code {
                case .notAuthenticated:
                    log("💡 Not signed in to iCloud", type: .warning)
                case .networkUnavailable, .networkFailure:
                    log("💡 Check internet connection", type: .warning)
                case .serverRejectedRequest:
                    log("💡 Container might not be configured", type: .warning)
                    log("💡 Go to CloudKit Dashboard and verify setup", type: .warning)
                case .unknownItem:
                    log("💡 UserProfile record type doesn't exist", type: .warning)
                    log("💡 Create it in CloudKit Dashboard", type: .warning)
                default:
                    log("💡 Error code: \(error.code)", type: .warning)
                }
            } catch {
                log("❌ Unexpected error: \(error.localizedDescription)", type: .error)
            }
            
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", type: .info)
            log("✅ Diagnostics complete", type: .success)
            
            await MainActor.run { isTesting = false }
        }
    }
    
    private func testContainerAccess() {
        logs.removeAll()
        isTesting = true
        
        Task {
            log("🧪 Testing container access...", type: .info)
            
            let container = CKContainer.default()
            log("Container: \(container.containerIdentifier ?? "Unknown")", type: .info)
            
            do {
                let status = try await container.accountStatus()
                log("✅ Container accessible", type: .success)
                log("Account status: \(status)", type: .info)
            } catch {
                log("❌ Cannot access container", type: .error)
                log("\(error.localizedDescription)", type: .error)
            }
            
            await MainActor.run { isTesting = false }
        }
    }
    
    private func testRecordTypes() {
        logs.removeAll()
        isTesting = true
        
        Task {
            log("🧪 Testing record types...", type: .info)
            
            let container = CKContainer.default()
            let publicDB = container.publicCloudDatabase
            
            let recordTypes = ["UserProfile", "FriendRelationship", "PublicWorkout"]
            
            for recordType in recordTypes {
                log("Testing \(recordType)...", type: .info)
                
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                
                do {
                    _ = try await publicDB.records(matching: query, desiredKeys: nil, resultsLimit: 1)
                    log("✅ \(recordType) exists", type: .success)
                } catch let error as CKError {
                    if error.code == .unknownItem {
                        log("❌ \(recordType) NOT found", type: .error)
                        log("   Create it in CloudKit Dashboard", type: .warning)
                    } else {
                        log("⚠️ \(recordType) error: \(error.localizedDescription)", type: .warning)
                    }
                } catch {
                    log("⚠️ \(recordType) error: \(error.localizedDescription)", type: .warning)
                }
            }
            
            log("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", type: .info)
            log("✅ Record type test complete", type: .success)
            
            await MainActor.run { isTesting = false }
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    CloudKitDebugView()
}
