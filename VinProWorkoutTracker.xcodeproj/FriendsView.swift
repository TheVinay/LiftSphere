import SwiftUI

struct FriendsView: View {
    @State private var friendManager = CloudKitFriendManager()
    @State private var showUsernameSetup = false
    @State private var isCheckingSetup = true
    @State private var selectedTab: FriendTab = .activity
    
    enum FriendTab: String, CaseIterable {
        case activity = "Activity"
        case friends = "Friends"
    }
    
    var body: some View {
        Group {
            if isCheckingSetup {
                ProgressView("Loading...")
            } else if friendManager.currentUserProfile == nil {
                // Show setup screen
                UsernameSetupView(friendManager: friendManager) {
                    showUsernameSetup = false
                }
            } else {
                // Show main friends interface
                TabView(selection: $selectedTab) {
                    FriendsActivityFeedView(friendManager: friendManager)
                        .tabItem {
                            Label("Activity", systemImage: "flame.fill")
                        }
                        .tag(FriendTab.activity)
                    
                    FriendListView(friendManager: friendManager)
                        .tabItem {
                            Label("Friends", systemImage: "person.2.fill")
                        }
                        .tag(FriendTab.friends)
                }
            }
        }
        .onAppear {
            checkSetup()
        }
    }
    
    private func checkSetup() {
        isCheckingSetup = true
        
        Task {
            let isSetup = await friendManager.checkUserSetup()
            
            await MainActor.run {
                isCheckingSetup = false
                if !isSetup {
                    showUsernameSetup = true
                }
            }
        }
    }
}

#Preview {
    FriendsView()
}
