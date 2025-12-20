import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    
    var body: some View {
        RootTabView()
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
                    .interactiveDismissDisabled()
            }
            .onAppear {
                if !hasCompletedOnboarding {
                    // Small delay for better UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showOnboarding = true
                    }
                }
            }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
