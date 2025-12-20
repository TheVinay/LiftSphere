import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("displayName") private var displayName: String = ""

    @State private var showNameSheet = false
    @State private var showAppleSignIn = false
    @State private var tempName: String = ""

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("LiftSphere Workout")
                    .font(.largeTitle.bold())
                Text("Vin Edition")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // REAL APPLE SIGN-IN
            Button {
                showAppleSignIn = true
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Continue with Apple")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 32)

            // SKIP (LOCAL MODE)
            Button("Continue without signing in") {
                tempName = ""
                showNameSheet = true
                didChooseLogin = true
                isSignedIn = false
            }
            .font(.subheadline)
            .foregroundStyle(.blue)

            Spacer()
        }
        // Apple Sign-In sheet
        .sheet(isPresented: $showAppleSignIn) {
            AppleSignInView { name in
                displayName = name
                isSignedIn = true
                didChooseLogin = true
                showAppleSignIn = false
            }
        }
        // Manual name capture sheet
        .sheet(isPresented: $showNameSheet) {
            nameCaptureSheet
        }
    }

    // MARK: - Name sheet (unchanged behavior)

    private var nameCaptureSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Enter your name")
                    .font(.title2.weight(.semibold))

                TextField("Your name", text: $tempName)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        displayName = tempName.trimmingCharacters(in: .whitespaces).isEmpty
                            ? fallbackFromDevice()
                            : tempName.trimmingCharacters(in: .whitespaces)

                        isSignedIn = true
                        showNameSheet = false
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        displayName = fallbackFromDevice()
                        isSignedIn = true
                        showNameSheet = false
                    }
                }
            }
        }
    }

    private func fallbackFromDevice() -> String {
        let device = UIDevice.current.name
        if let range = device.range(of: "'s ") {
            return String(device[..<range.lowerBound])
        }
        return device
    }
}
