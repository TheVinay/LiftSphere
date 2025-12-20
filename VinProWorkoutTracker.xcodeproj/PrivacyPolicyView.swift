import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Group {
                        Text("Privacy Policy")
                            .font(.largeTitle.bold())
                            .padding(.bottom, 8)
                        
                        Text("Last updated: December 20, 2024")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        section(
                            title: "Data Collection",
                            content: "LiftSphere Workout stores all your workout data locally on your device. We do not collect, transmit, or store any personal information on external servers."
                        )
                        
                        section(
                            title: "What Data We Store Locally",
                            content: """
                            • Workout logs (exercises, sets, reps, weight)
                            • Your profile information (name, bio)
                            • App preferences and settings
                            • Exercise history and analytics
                            
                            All data remains on your device and is never transmitted to external servers.
                            """
                        )
                        
                        section(
                            title: "Data Security",
                            content: "Your workout data is stored securely on your device using Apple's SwiftData framework. Data is protected by your device's security measures, including encryption and passcode protection."
                        )
                        
                        section(
                            title: "Data Sharing",
                            content: "We do not share, sell, or transmit your personal data to third parties. When you use the export feature, you have full control over where you share your workout data."
                        )
                        
                        section(
                            title: "HealthKit (If Applicable)",
                            content: "If you choose to integrate with Apple Health, workout data may be synced to the Health app according to your permissions. This data is managed by Apple's HealthKit and follows Apple's privacy policies."
                        )
                        
                        section(
                            title: "Sign In with Apple",
                            content: "If you use Sign in with Apple, we only receive your name (if you choose to share it). Apple does not share your email or other personal information without your explicit consent."
                        )
                        
                        section(
                            title: "Children's Privacy",
                            content: "LiftSphere Workout is not intended for children under 13. We do not knowingly collect data from children."
                        )
                        
                        section(
                            title: "Your Rights",
                            content: """
                            You have complete control over your data:
                            • Export your data at any time from Settings
                            • Delete all data by deleting the app
                            • No account required to use the app
                            """
                        )
                        
                        section(
                            title: "Changes to This Policy",
                            content: "We may update this privacy policy from time to time. Any changes will be reflected in the app with an updated \"Last updated\" date."
                        )
                        
                        section(
                            title: "Contact",
                            content: "If you have questions about this privacy policy or your data, please contact us through the App Store."
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func section(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
