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
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
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
