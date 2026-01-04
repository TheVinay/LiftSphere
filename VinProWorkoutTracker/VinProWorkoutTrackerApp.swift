import SwiftUI
import SwiftData

@main
struct VinProWorkoutTrackerApp: App {

    // Theme: 0 = System, 1 = Light, 2 = Dark
    @AppStorage("appTheme") private var theme: Int = 0
    
    // Authentication
    @State private var authManager = AuthenticationManager()

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Workout.self, SetEntry.self, CustomWorkoutTemplate.self])
        
        // Try with CloudKit first
        let cloudConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            print("⚠️ Failed to initialize ModelContainer with CloudKit: \(error)")
            
            // Fallback to local-only storage
            do {
                let localConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
                print("✅ Using local-only storage as fallback")
                return try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                // Last resort: in-memory storage
                print("❌ Critical: Falling back to in-memory storage: \(error)")
                do {
                    let memoryConfig = ModelConfiguration(
                        schema: schema,
                        isStoredInMemoryOnly: true
                    )
                    return try ModelContainer(for: schema, configurations: [memoryConfig])
                } catch {
                    fatalError("Could not create ModelContainer even with in-memory storage: \(error)")
                }
            }
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
