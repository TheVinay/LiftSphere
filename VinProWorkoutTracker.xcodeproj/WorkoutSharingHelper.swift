import SwiftUI

// MARK: - Workout Sharing Extension

extension Workout {
    /// Share this workout with friends on CloudKit
    func shareWithFriends(using friendManager: CloudKitFriendManager) async throws {
        try await friendManager.shareWorkout(
            name: self.name,
            date: self.date,
            volume: self.totalVolume,
            exerciseCount: self.mainExercises.count + self.coreExercises.count,
            isCompleted: self.isCompleted
        )
    }
}

// MARK: - Share Button View

struct ShareWorkoutButton: View {
    let workout: Workout
    let friendManager: CloudKitFriendManager
    
    @State private var isSharing = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        Button {
            shareWorkout()
        } label: {
            HStack {
                if isSharing {
                    ProgressView()
                        .tint(.white)
                } else if showSuccess {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Shared!")
                } else {
                    Image(systemName: "person.2.fill")
                    Text("Share with Friends")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                showSuccess ? Color.green :
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(isSharing || showSuccess)
        .alert("Share Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    private func shareWorkout() {
        isSharing = true
        errorMessage = nil
        
        Task {
            do {
                try await workout.shareWithFriends(using: friendManager)
                
                await MainActor.run {
                    isSharing = false
                    showSuccess = true
                    
                    // Reset success state after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccess = false
                    }
                }
            } catch {
                await MainActor.run {
                    isSharing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Auto-Share Setting

/// Add this to your @AppStorage settings
/// @AppStorage("autoShareWorkouts") private var autoShareWorkouts: Bool = false

/// Then in your workout completion code:
///
/// if autoShareWorkouts {
///     Task {
///         let friendManager = CloudKitFriendManager()
///         _ = try? await friendManager.checkUserSetup()
///         try? await workout.shareWithFriends(using: friendManager)
///     }
/// }

// MARK: - Example Usage in WorkoutDetailView

/*
 Add this to WorkoutDetailView after the Complete/Uncomplete button:
 
 if workout.isCompleted {
     let friendManager = CloudKitFriendManager()
     ShareWorkoutButton(workout: workout, friendManager: friendManager)
         .padding(.horizontal)
 }
 */

#Preview {
    let workout = Workout(
        name: "Sample Push Day",
        warmupMinutes: 5,
        coreMinutes: 5,
        stretchMinutes: 5,
        mainExercises: ["Bench Press", "Shoulder Press"],
        coreExercises: ["Plank"],
        stretches: ["Chest Stretch"]
    )
    
    return ShareWorkoutButton(
        workout: workout,
        friendManager: CloudKitFriendManager()
    )
    .padding()
}
