import SwiftUI
import SwiftData

@main
struct VinProWorkoutTrackerApp: App {

    // Theme: 0 = System, 1 = Light, 2 = Dark
    @AppStorage("appTheme") private var theme: Int = 0
    
    // Authentication
    @State private var authManager = AuthenticationManager()

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Workout.self, SetEntry.self])
        return try! ModelContainer(for: schema)
    }()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                RootView()
                    .preferredColorScheme(colorScheme(for: theme))
                    .environment(authManager)
            } else {
                SignInView()
                    .environment(authManager)
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func colorScheme(for theme: Int) -> ColorScheme? {
        switch theme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
}
