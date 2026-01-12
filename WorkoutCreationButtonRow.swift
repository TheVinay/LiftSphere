import SwiftUI

/// A horizontal row of three action buttons for creating workouts.
/// This component appears at the top of the workouts list screen.
struct WorkoutCreationButtonRow: View {
    // Action callbacks (will be wired up in later chunks)
    var onCreateWorkout: () -> Void = {}
    var onRepeatRecent: () -> Void = {}
    var onBrowseWorkouts: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 12) {
            // Primary action: Create Workout
            Button(action: onCreateWorkout) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    
                    Text("Create Workout")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            // Secondary actions row
            HStack(spacing: 12) {
                // Repeat Recent
                Button(action: onRepeatRecent) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline)
                        
                        Text("Repeat Recent")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                // Browse Workouts
                Button(action: onBrowseWorkouts) {
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                            .font(.subheadline)
                        
                        Text("Browse Workouts")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack(spacing: 0) {
        WorkoutCreationButtonRow()
        
        // Show what it looks like above a list
        List {
            Section("This Week") {
                Text("Push Day")
                Text("Pull Day")
            }
            
            Section("Last Week") {
                Text("Leg Day")
                Text("Upper Body")
            }
        }
    }
}
