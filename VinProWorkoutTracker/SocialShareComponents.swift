import SwiftUI

/// A view modifier that adds social sharing capabilities to any view
struct SocialShareModifier: ViewModifier {
    let workout: Workout
    @State private var showingShareConfirmation = false
    @State private var shareSuccess = false
    @State private var shareError: String?
    
    func body(content: Content) -> some View {
        content
            .alert("Share Workout", isPresented: $showingShareConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Share") {
                    Task {
                        await shareWorkout()
                    }
                }
            } message: {
                Text("Share this workout with your friends?")
            }
            .alert("Workout Shared!", isPresented: $shareSuccess) {
                Button("OK") { }
            } message: {
                Text("Your workout has been shared with friends and will appear in their feed.")
            }
            .alert("Share Failed", isPresented: Binding(
                get: { shareError != nil },
                set: { if !$0 { shareError = nil } }
            )) {
                Button("OK") { shareError = nil }
            } message: {
                if let error = shareError {
                    Text(error)
                }
            }
    }
    
    private func shareWorkout() async {
        let socialService = SocialService()
        do {
            try await socialService.shareWorkout(workout)
            shareSuccess = true
        } catch {
            shareError = error.localizedDescription
        }
    }
}

extension View {
    /// Adds social sharing functionality to a view for a specific workout
    func socialShare(for workout: Workout) -> some View {
        modifier(SocialShareModifier(workout: workout))
    }
}

// MARK: - Share Button Component

struct ShareToFriendsButton: View {
    let workout: Workout
    @State private var isSharing = false
    @State private var shareComplete = false
    @State private var error: String?
    
    var body: some View {
        Button {
            Task {
                await share()
            }
        } label: {
            if isSharing {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Sharing...")
                }
            } else if shareComplete {
                Label("Shared", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Label("Share to Friends", systemImage: "person.2.fill")
            }
        }
        .disabled(isSharing || shareComplete)
        .alert("Share Failed", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: {
            if let error = error {
                Text(error)
            }
        }
    }
    
    private func share() async {
        isSharing = true
        
        let socialService = SocialService()
        do {
            try await socialService.shareWorkout(workout)
            shareComplete = true
            
            // Reset after 3 seconds
            try? await Task.sleep(for: .seconds(3))
            shareComplete = false
        } catch {
            self.error = error.localizedDescription
        }
        
        isSharing = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VStack {
            ShareToFriendsButton(workout: Workout(
                name: "Push Day",
                mainExercises: ["Bench Press", "Overhead Press"]
            ))
            .buttonStyle(.borderedProminent)
        }
    }
}
