import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthenticationManager.self) private var authManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("VinPro Workout Tracker")
                    .font(.title.bold())
                
                Text("Track your workouts, build muscle, and achieve your fitness goals")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                // Sign in with Apple Button
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    authManager.handleSignInWithApple(result: result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(10)
                
                #if targetEnvironment(simulator)
                // DEBUG: Skip sign-in for simulator
                Button {
                    authManager.debugSkipSignIn()
                } label: {
                    Text("Skip Sign In (Simulator Only)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.top, 8)
                #endif
                
                VStack(spacing: 4) {
                    Text("Your data stays on your device")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("We don't collect or share your personal information")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationManager())
}
