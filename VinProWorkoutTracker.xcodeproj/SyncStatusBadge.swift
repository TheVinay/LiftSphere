import SwiftUI

/// Small sync status badge that can be added to any view
struct SyncStatusBadge: View {
    let syncMonitor: CloudKitSyncMonitor
    let showLabel: Bool
    
    init(syncMonitor: CloudKitSyncMonitor, showLabel: Bool = false) {
        self.syncMonitor = syncMonitor
        self.showLabel = showLabel
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: syncMonitor.statusIcon)
                .font(.caption)
                .foregroundStyle(syncMonitor.statusColor)
            
            if showLabel {
                Text(shortStatusText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(syncMonitor.statusColor.opacity(0.1))
        )
    }
    
    private var shortStatusText: String {
        switch syncMonitor.syncStatus {
        case .syncing:
            return "Syncing..."
        case .synced:
            return "Synced"
        case .error:
            return "Error"
        case .notSignedIn:
            return "Not signed in"
        case .noNetwork:
            return "Offline"
        case .unknown:
            return "Checking..."
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        let monitor = CloudKitSyncMonitor()
        
        SyncStatusBadge(syncMonitor: monitor, showLabel: false)
        SyncStatusBadge(syncMonitor: monitor, showLabel: true)
    }
    .padding()
}
