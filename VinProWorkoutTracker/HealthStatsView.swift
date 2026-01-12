import SwiftUI
import HealthKit

struct HealthStatsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var healthManager = HealthKitManager()
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init() {
        // Check authorization immediately on init
        let manager = HealthKitManager()
        manager.checkAuthorizationStatus()
        _healthManager = State(initialValue: manager)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !HealthKitManager.isHealthDataAvailable {
                        unavailableView
                    } else if !healthManager.isAuthorized {
                        unauthorizedView
                    } else if isLoading {
                        loadingView
                    } else {
                        healthDataView
                    }
                }
                .padding()
            }
            .navigationTitle("Apple Health")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
                if healthManager.isAuthorized {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                await refreshData()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(isLoading)
                    }
                }
            }
            .task {
                // Check authorization status when view appears
                healthManager.checkAuthorizationStatus()
                
                // If authorized, automatically load data
                if healthManager.isAuthorized {
                    await refreshData()
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Unavailable View
    
    private var unavailableView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("HealthKit Not Available")
                .font(.title2.bold())
            
            Text("HealthKit is not available on this device.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Unauthorized View
    
    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Apple Health Integration")
                .font(.title2.bold())
            
            Text("Allow access to your health data to see body composition, activity, and fitness metrics.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await requestAuthorization()
                }
            } label: {
                Label("Connect to Apple Health", systemImage: "heart.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading health data...")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    // MARK: - Health Data View
    
    private var healthDataView: some View {
        VStack(spacing: 20) {
            // Last Updated
            if let lastUpdated = healthManager.lastUpdated {
                Text("Last updated: \(lastUpdated, style: .relative) ago")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Body Composition
            sectionCard(title: "Body Composition", icon: "figure.stand", color: .blue) {
                VStack(spacing: 12) {
                    if let weight = healthManager.formattedWeight() {
                        statRow(label: "Weight", value: weight, icon: "scalemass")
                    }
                    
                    if let height = healthManager.formattedHeight() {
                        statRow(label: "Height", value: height, icon: "ruler")
                    }
                    
                    if let bmi = healthManager.formattedBMI() {
                        HStack {
                            statRow(label: "BMI", value: bmi, icon: "person")
                            if let category = healthManager.bmiCategory() {
                                Text("(\(category))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    if let bodyFat = healthManager.formattedBodyFat() {
                        statRow(label: "Body Fat", value: bodyFat, icon: "percent")
                    }
                    
                    if let leanMass = healthManager.formattedLeanBodyMass() {
                        statRow(label: "Lean Body Mass", value: leanMass, icon: "figure.strengthtraining.traditional")
                    }
                    
                    if let muscleMass = healthManager.formattedMuscleMass() {
                        statRow(label: "Muscle Mass", value: muscleMass, icon: "figure.strengthtraining.functional")
                    }
                    
                    if let boneMass = healthManager.formattedBoneMass() {
                        statRow(label: "Bone Mass", value: boneMass, icon: "figure.walk")
                    }
                }
            }
            
            // Metabolic
            if healthManager.basalEnergyBurned != nil {
                sectionCard(title: "Metabolic", icon: "flame.fill", color: .orange) {
                    VStack(spacing: 12) {
                        if let bmr = healthManager.formattedBMR() {
                            statRow(label: "BMR (Today)", value: bmr, icon: "flame")
                        }
                        
                        if let active = healthManager.activeEnergyBurned {
                            statRow(label: "Active Energy", value: String(format: "%.0f kcal", active), icon: "bolt.fill")
                        }
                    }
                }
            }
            
            // Activity (Today)
            if healthManager.stepCount != nil || healthManager.exerciseTime != nil {
                sectionCard(title: "Activity (Today)", icon: "figure.walk", color: .green) {
                    VStack(spacing: 12) {
                        if let steps = healthManager.formattedSteps() {
                            statRow(label: "Steps", value: steps, icon: "shoeprints.fill")
                        }
                        
                        if let distance = healthManager.distanceWalkingRunning {
                            statRow(label: "Distance", value: String(format: "%.2f mi", distance), icon: "map")
                        }
                        
                        if let exercise = healthManager.exerciseTime {
                            statRow(label: "Exercise Time", value: String(format: "%.0f min", exercise), icon: "timer")
                        }
                    }
                }
            }
            
            // Heart & Fitness
            if healthManager.restingHeartRate != nil || healthManager.vo2Max != nil {
                sectionCard(title: "Apple Health Integration", icon: "heart.fill", color: .red) {
                    VStack(spacing: 12) {
                        if let rhr = healthManager.restingHeartRate {
                            statRow(label: "Resting Heart Rate", value: String(format: "%.0f bpm", rhr), icon: "heart")
                        }
                        
                        if let hrv = healthManager.heartRateVariability {
                            statRow(label: "HRV", value: String(format: "%.0f ms", hrv), icon: "waveform.path.ecg")
                        }
                        
                        if let vo2 = healthManager.vo2Max {
                            statRow(label: "VO2 Max", value: String(format: "%.1f", vo2), icon: "lungs.fill")
                        }
                    }
                }
            }
            
            // Sleep
            if let sleep = healthManager.sleepHours {
                sectionCard(title: "Sleep", icon: "bed.double.fill", color: .indigo) {
                    statRow(label: "Last Night", value: String(format: "%.1f hrs", sleep), icon: "moon.stars.fill")
                }
            }
            
            // Nutrition (Today)
            if healthManager.dietaryProtein != nil || healthManager.dietaryCalories != nil {
                sectionCard(title: "Nutrition (Today)", icon: "fork.knife", color: .purple) {
                    VStack(spacing: 12) {
                        if let calories = healthManager.dietaryCalories {
                            statRow(label: "Calories", value: String(format: "%.0f kcal", calories), icon: "flame.fill")
                        }
                        
                        if let protein = healthManager.formattedProtein() {
                            statRow(label: "Protein", value: protein, icon: "p.circle.fill")
                        }
                        
                        if let carbs = healthManager.dietaryCarbs {
                            statRow(label: "Carbs", value: String(format: "%.1f g", carbs), icon: "c.circle.fill")
                        }
                        
                        if let fat = healthManager.dietaryFat {
                            statRow(label: "Fat", value: String(format: "%.1f g", fat), icon: "f.circle.fill")
                        }
                    }
                }
            }
            
            // No data message
            if healthManager.lastUpdated == nil {
                Text("No health data available. Make sure you have data in the Health app.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionCard<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func statRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
        }
    }
    
    // MARK: - Actions
    
    private func requestAuthorization() async {
        isLoading = true
        
        do {
            try await healthManager.requestAuthorization()
            await refreshData()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func refreshData() async {
        isLoading = true
        await healthManager.fetchAllHealthData()
        isLoading = false
    }
}

#Preview {
    HealthStatsView()
}
