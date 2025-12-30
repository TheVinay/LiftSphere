import SwiftUI
import CloudKit

@Observable
class CloudKitSyncMonitor {
    var syncStatus: SyncStatus = .unknown
    var lastSyncDate: Date?
    var errorMessage: String?
    
    enum SyncStatus {
        case unknown
        case syncing
        case synced
        case error
        case notSignedIn
        case noNetwork
    }
    
    private let container = CKContainer.default()
    
    init() {
        checkAccountStatus()
    }
    
    // MARK: - Check Account Status
    
    func checkAccountStatus() {
        Task {
            do {
                let status = try await container.accountStatus()
                
                await MainActor.run {
                    switch status {
                    case .available:
                        self.syncStatus = .synced
                    case .noAccount:
                        self.syncStatus = .notSignedIn
                        self.errorMessage = "Please sign in to iCloud in Settings to enable sync"
                    case .restricted:
                        self.syncStatus = .error
                        self.errorMessage = "iCloud is restricted on this device"
                    case .couldNotDetermine:
                        self.syncStatus = .unknown
                    case .temporarilyUnavailable:
                        self.syncStatus = .noNetwork
                        self.errorMessage = "iCloud is temporarily unavailable"
                    @unknown default:
                        self.syncStatus = .unknown
                    }
                }
            } catch {
                await MainActor.run {
                    self.syncStatus = .error
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Sync Status Helpers
    
    var statusIcon: String {
        switch syncStatus {
        case .unknown:
            return "questionmark.circle"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .synced:
            return "checkmark.icloud"
        case .error:
            return "exclamationmark.icloud"
        case .notSignedIn:
            return "person.crop.circle.badge.exclamationmark"
        case .noNetwork:
            return "wifi.slash"
        }
    }
    
    var statusColor: Color {
        switch syncStatus {
        case .unknown:
            return .gray
        case .syncing:
            return .blue
        case .synced:
            return .green
        case .error, .notSignedIn:
            return .red
        case .noNetwork:
            return .orange
        }
    }
    
    var statusText: String {
        switch syncStatus {
        case .unknown:
            return "Checking sync status..."
        case .syncing:
            return "Syncing to iCloud..."
        case .synced:
            if let lastSync = lastSyncDate {
                return "Last synced \(lastSync.formatted(.relative(presentation: .named)))"
            }
            return "Synced to iCloud"
        case .error:
            return errorMessage ?? "Sync error"
        case .notSignedIn:
            return "Not signed in to iCloud"
        case .noNetwork:
            return "No internet connection"
        }
    }
}
