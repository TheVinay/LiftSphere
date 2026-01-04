import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

            ContentView()
                .tabItem {
                    Label("Workouts", systemImage: "list.bullet.rectangle")
                }

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.xaxis")
                }

            FriendsView()
                .tabItem {
                   Label("Friends", systemImage: "person.2.fill")
                }

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.closed")
                }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
