import SwiftUI
import AuthenticationServices

struct AppleSignInView: View {
    @AppStorage("appleUserId") private var appleUserId: String = ""
    @AppStorage("appleFullName") private var appleFullName: String = ""
    @AppStorage("appleEmail") private var appleEmail: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("LiftSphere Workout")
                    .font(.largeTitle.bold())
                Text("Vin Edition")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text("Sign in with Apple to keep your workouts backed up and tied to your account across devices.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: handleSignInResult
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 32)

            Text("You can edit your profile name later in the Profile tab.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Spacer()
        }
    }

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                // Unique Apple user ID for your app
                let userId = credential.user
                appleUserId = userId

                // Full name (only guaranteed on first sign-in)
                if let fullName = credential.fullName {
                    let given = fullName.givenName ?? ""
                    let family = fullName.familyName ?? ""
                    let combined = "\(given) \(family)".trimmingCharacters(in: .whitespaces)
                    if !combined.isEmpty {
                        appleFullName = combined
                    }
                }

                // Email (if Apple shares it)
                if let email = credential.email {
                    appleEmail = email
                }
            }

        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
}
