import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Group {
                        Text("Terms of Service")
                            .font(.largeTitle.bold())
                            .padding(.bottom, 8)
                        
                        Text("Last updated: December 20, 2024")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Divider()
                        
                        section(
                            title: "Acceptance of Terms",
                            content: "By downloading and using LiftSphere Workout, you agree to these Terms of Service. If you do not agree, please do not use the app."
                        )
                        
                        section(
                            title: "Use of the App",
                            content: """
                            LiftSphere Workout is a fitness tracking tool designed to help you log workouts and monitor progress. The app is provided "as is" for personal, non-commercial use.
                            
                            You agree to:
                            • Use the app in compliance with all applicable laws
                            • Not attempt to reverse engineer or modify the app
                            • Not use the app for any harmful or illegal purposes
                            """
                        )
                        
                        section(
                            title: "Health and Fitness Disclaimer",
                            content: """
                            IMPORTANT: LiftSphere Workout is a tracking tool only, not medical advice.
                            
                            • Always consult with a healthcare provider before starting any exercise program
                            • The app does not provide medical advice, diagnosis, or treatment
                            • Exercise information is for educational purposes only
                            • Use proper form and technique to avoid injury
                            • Listen to your body and stop if you experience pain or discomfort
                            
                            We are not responsible for any injuries or health issues that may occur from using this app or following any exercise programs.
                            """
                        )
                        
                        section(
                            title: "Accuracy of Information",
                            content: "While we strive to provide accurate exercise information, we make no warranties about the completeness, reliability, or accuracy of this information. You use all information at your own risk."
                        )
                        
                        section(
                            title: "Your Data",
                            content: "All workout data you create belongs to you. We store data locally on your device and do not claim ownership of your content. You can export or delete your data at any time."
                        )
                        
                        section(
                            title: "Limitation of Liability",
                            content: """
                            To the maximum extent permitted by law:
                            
                            • We provide this app "as is" without warranties of any kind
                            • We are not liable for any direct, indirect, or consequential damages
                            • We are not responsible for any injuries, losses, or damages from using the app
                            • Your sole remedy is to stop using the app
                            """
                        )
                        
                        section(
                            title: "App Updates and Changes",
                            content: "We may update, modify, or discontinue features of the app at any time without notice. We are not obligated to provide updates or support."
                        )
                        
                        section(
                            title: "Third-Party Services",
                            content: "The app may integrate with Apple services (HealthKit, Sign in with Apple, etc.). Your use of these services is governed by Apple's terms and policies."
                        )
                        
                        section(
                            title: "Termination",
                            content: "You may stop using the app at any time by deleting it from your device. We reserve the right to terminate or restrict access to the app for any reason."
                        )
                        
                        section(
                            title: "Changes to Terms",
                            content: "We may update these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms."
                        )
                        
                        section(
                            title: "Governing Law",
                            content: "These terms are governed by the laws of your jurisdiction. Any disputes will be resolved in accordance with local laws."
                        )
                        
                        section(
                            title: "Contact",
                            content: "Questions about these terms? Contact us through the App Store."
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
    TermsOfServiceView()
}
