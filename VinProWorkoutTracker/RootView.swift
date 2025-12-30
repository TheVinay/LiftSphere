import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AuthenticationManager.self) private var authManager
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("displayName") private var displayName: String = ""
    
    @State private var showOnboarding = false
    @State private var showNamePrompt = false
    @State private var tempName: String = ""
    
    var body: some View {
        RootTabView()
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
                    .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showNamePrompt) {
                namePromptSheet
                    .interactiveDismissDisabled()
            }
            .onAppear {
                // Check if we need to prompt for name
                if authManager.needsNamePrompt {
                    // Pre-fill with suggested name if available
                    tempName = authManager.userName.isEmpty ? "" : authManager.userName
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNamePrompt = true
                    }
                } else if !hasCompletedOnboarding {
                    // Show regular onboarding
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showOnboarding = true
                    }
                } else {
                    // Sync auth name to display name if needed
                    syncDisplayName()
                }
            }
    }
    
    // MARK: - Name Prompt Sheet
    
    private var namePromptSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 12) {
                    Text("What should we call you?")
                        .font(.title2.bold())
                    
                    Text("This will be displayed on your profile")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Your name", text: $tempName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .padding(.horizontal, 32)
                        .autocorrectionDisabled()
                    
                    Text("You can change this later in your profile")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Continue Button
                Button {
                    saveName()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .disabled(tempName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Helpers
    
    private func saveName() {
        let finalName = tempName.trimmingCharacters(in: .whitespaces)
        
        if !finalName.isEmpty {
            // Save to both auth manager and display name
            authManager.setDisplayName(finalName)
            displayName = finalName
        }
        
        showNamePrompt = false
        
        // Show onboarding if not completed
        if !hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showOnboarding = true
            }
        }
    }
    
    private func syncDisplayName() {
        // If displayName is empty but auth has a name, sync it
        if displayName.isEmpty && !authManager.userName.isEmpty {
            displayName = authManager.userName
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
        .environment(AuthenticationManager())
}
