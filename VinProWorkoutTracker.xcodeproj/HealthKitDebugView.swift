import SwiftUI
import HealthKit

/// A simple debug view to test HealthKit write permissions
/// Add this to your app temporarily to test if writing works
struct HealthKitDebugView: View {
    @State private var healthManager = HealthKitManager()
    @State private var testResults: [String] = []
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        testWriteWorkout()
                    } label: {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .foregroundColor(.red)
                            Text("Test Write Workout")
                            Spacer()
                            if isProcessing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing)
                } header: {
                    Text("Quick Tests")
                } footer: {
                    Text("This will attempt to write a test workout to Apple Health. Check the results below.")
                }
                
                if !testResults.isEmpty {
                    Section {
                        ForEach(testResults.indices, id: \.self) { index in
                            Text(testResults[index])
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(testResults[index].contains("✅") ? .green : 
                                               testResults[index].contains("❌") ? .red :
                                               testResults[index].contains("⚠️") ? .orange : .primary)
                        }
                    } header: {
                        HStack {
                            Text("Test Results")
                            Spacer()
                            Button("Clear") {
                                testResults.removeAll()
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("HealthKit Debug")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func testWriteWorkout() {
        isProcessing = true
        testResults.removeAll()
        
        Task {
            addLog("🧪 Starting HealthKit Write Test")
            addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            // Check availability
            if !HKHealthStore.isHealthDataAvailable() {
                addLog("❌ HealthKit not available")
                isProcessing = false
                return
            }
            addLog("✅ HealthKit is available")
            
            // Test workout data
            let testName = "Debug Test Workout"
            let testDate = Date()
            let testDuration: TimeInterval = 30 * 60 // 30 minutes
            let testVolume: Double = 5000 // 5000 lbs
            
            addLog("📝 Test workout details:")
            addLog("   Name: \(testName)")
            addLog("   Date: \(testDate)")
            addLog("   Duration: 30 minutes")
            addLog("   Volume: 5000 lbs")
            addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            
            // Attempt to save
            do {
                addLog("🔄 Calling saveWorkout()...")
                
                try await healthManager.saveWorkout(
                    name: testName,
                    startDate: testDate,
                    duration: testDuration,
                    totalVolume: testVolume
                )
                
                addLog("✅ SUCCESS!")
                addLog("✅ Workout saved to Apple Health")
                addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
                addLog("📱 Check Health app:")
                addLog("   Browse → Activity → Workouts")
                addLog("   or")
                addLog("   Apps → LiftSphere → Data")
                
            } catch let error as HKError {
                addLog("❌ HealthKit Error:")
                addLog("   Code: \(error.code.rawValue)")
                addLog("   \(error.localizedDescription)")
                
                switch error.code {
                case .errorAuthorizationDenied:
                    addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    addLog("⚠️ PERMISSION DENIED")
                    addLog("📱 Fix in Health app:")
                    addLog("   1. Open Health app")
                    addLog("   2. Tap profile icon (top right)")
                    addLog("   3. Tap Apps")
                    addLog("   4. Tap LiftSphere")
                    addLog("   5. Enable 'Workouts' under")
                    addLog("      'Allow LiftSphere to Write'")
                    
                case .errorAuthorizationNotDetermined:
                    addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    addLog("⚠️ AUTHORIZATION NOT REQUESTED")
                    addLog("   Go to Health Stats view")
                    addLog("   and tap 'Connect to Health'")
                    
                default:
                    addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    addLog("⚠️ Unknown HealthKit error")
                }
                
            } catch {
                addLog("❌ Unexpected error:")
                addLog("   \(error)")
                addLog("   \(error.localizedDescription)")
            }
            
            addLog("━━━━━━━━━━━━━━━━━━━━━━━━━━")
            addLog("✅ Test completed")
            isProcessing = false
        }
    }
    
    private func addLog(_ message: String) {
        testResults.append(message)
    }
}

#Preview {
    HealthKitDebugView()
}
