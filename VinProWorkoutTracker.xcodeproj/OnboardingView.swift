import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var currentPage = 0
    @State private var showCreateSample = false
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to LiftSphere",
            subtitle: "Your back-friendly workout companion",
            systemImage: "figure.strengthtraining.traditional",
            description: "Track workouts, analyze progress, and build strength safely with exercises designed to protect your lower back."
        ),
        OnboardingPage(
            title: "Smart Analytics",
            subtitle: "Know your body better",
            systemImage: "chart.bar.xaxis",
            description: "Get detailed insights into muscle balance, training volume, and consistency with beautiful charts and recommendations."
        ),
        OnboardingPage(
            title: "Exercise Library",
            subtitle: "Learn proper form",
            systemImage: "book.closed",
            description: "Browse hundreds of exercises with detailed instructions, muscle targeting, and equipment options."
        ),
        OnboardingPage(
            title: "Track Your Progress",
            subtitle: "Every rep counts",
            systemImage: "list.bullet.clipboard",
            description: "Log sets, track volume, and see your strength gains over time. Swipe to complete, duplicate, or archive workouts."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: currentPage == index ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Bottom buttons
            VStack(spacing: 16) {
                if currentPage == pages.count - 1 {
                    // Last page - Get Started
                    Button {
                        showCreateSample = true
                    } label: {
                        Text("Create Sample Workout")
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
                    
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip - I'll Create My Own")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Next button
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(16)
                    }
                    
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .alert("Create Sample Workout?", isPresented: $showCreateSample) {
            Button("Create") {
                createSampleWorkout()
                completeOnboarding()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll create a sample Push Day workout so you can explore the app's features.")
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
    
    private func createSampleWorkout() {
        let sampleWorkout = Workout(
            date: Date(),
            name: "Sample Push Day",
            warmupMinutes: 5,
            coreMinutes: 5,
            stretchMinutes: 5,
            mainExercises: [
                "Incline Dumbbell Press",
                "Seated Shoulder Press",
                "Cable Tricep Pushdown",
                "Lateral Raise"
            ],
            coreExercises: [
                "Plank",
                "Dead Bug"
            ],
            stretches: [
                "Chest Stretch",
                "Shoulder Stretch"
            ],
            sets: []
        )
        
        // Add some sample sets
        let sampleSets = [
            SetEntry(exerciseName: "Incline Dumbbell Press", weight: 30, reps: 10, timestamp: Date()),
            SetEntry(exerciseName: "Incline Dumbbell Press", weight: 30, reps: 10, timestamp: Date().addingTimeInterval(120)),
            SetEntry(exerciseName: "Incline Dumbbell Press", weight: 30, reps: 8, timestamp: Date().addingTimeInterval(240)),
            SetEntry(exerciseName: "Seated Shoulder Press", weight: 25, reps: 12, timestamp: Date().addingTimeInterval(360)),
            SetEntry(exerciseName: "Seated Shoulder Press", weight: 25, reps: 10, timestamp: Date().addingTimeInterval(480)),
        ]
        
        sampleWorkout.sets = sampleSets
        
        context.insert(sampleWorkout)
        try? context.save()
    }
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
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
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.systemImage)
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Models

struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let description: String
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
