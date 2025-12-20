import SwiftUI
import AuthenticationServices

struct AppleSignInView: View {

    // MARK: - Persistent Apple account info
    @AppStorage("appleUserId") private var appleUserId: String = ""
    @AppStorage("appleFullName") private var appleFullName: String = ""
    @AppStorage("appleEmail") private var appleEmail: String = ""

    // MARK: - Callback to parent (WelcomeView / SettingsView)
    let onSuccess: (String) -> Void

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

    // MARK: - Apple Sign-In handler

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {

        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else {
                print("⚠️ Sign in with Apple: Unexpected credential type")
                return
            }

            // Unique Apple user ID (stable per app)
            let userId = credential.user
            appleUserId = userId
            print("✅ Apple Sign-In success. User ID: \(userId)")

            // Full name (only provided on first authorization)
            if let fullName = credential.fullName {
                let given = fullName.givenName ?? ""
                let family = fullName.familyName ?? ""
                let combined = "\(given) \(family)".trimmingCharacters(in: .whitespaces)

                if !combined.isEmpty {
                    appleFullName = combined
                    print("✅ Got name: \(combined)")
                }
            }

            // Email (may be nil on subsequent sign-ins)
            if let email = credential.email {
                appleEmail = email
                print("✅ Got email: \(email)")
            }

            // Decide display name fallback order
            let finalDisplayName: String = {
                if !appleFullName.isEmpty {
                    return appleFullName
                }
                if !appleEmail.isEmpty {
                    return appleEmail.components(separatedBy: "@").first ?? "User"
                }
                return "User"
            }()

            // Notify parent view (Welcome / Settings)
            onSuccess(finalDisplayName)

        case .failure(let error):
            let nsError = error as NSError
            print("❌ Sign in with Apple failed")
            print("   Domain: \(nsError.domain)")
            print("   Code: \(nsError.code)")
            print("   Description: \(error.localizedDescription)")

            if nsError.domain == ASAuthorizationError.errorDomain {
                switch nsError.code {
                case ASAuthorizationError.canceled.rawValue:
                    print("   → User canceled")
                case ASAuthorizationError.failed.rawValue:
                    print("   → Authorization failed")
                case ASAuthorizationError.invalidResponse.rawValue:
                    print("   → Invalid response")
                case ASAuthorizationError.notHandled.rawValue:
                    print("   → Not handled")
                case ASAuthorizationError.unknown.rawValue:
                    print("   → Unknown error")
                default:
                    print("   → Other error code: \(nsError.code)")
                }
            }
        }
    }
}
