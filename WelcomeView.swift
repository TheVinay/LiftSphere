import SwiftUI
import AuthenticationServices
import Contacts

struct WelcomeView: View {
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("displayName") private var displayName: String = ""

    @State private var showNameSheet = false
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

            // Primary login button – TikTok style
            Button(action: handleFakeAppleLogin) {
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

            // Secondary option – subtle “skip”
            Button("Continue without signing in") {
                tempName = ""
                showNameSheet = true    // ask for name instead of falling back to device name
                didChooseLogin = true
                isSignedIn = false
            }
            .font(.subheadline)
            .foregroundStyle(.blue)


            Spacer()
        }
        .sheet(isPresented: $showNameSheet) {
            nameCaptureSheet
        }
    }

    // MARK: - Fake login logic for now (real Apple login replaced later)

    private func handleFakeAppleLogin() {
        didChooseLogin = true

        // Try to fetch the Apple ID name from CNContactStore
        requestAppleName { name in
            if let realName = name, !realName.isEmpty {
                displayName = realName
                isSignedIn = true
            } else {
                // Fall back to asking the user
                tempName = ""
                showNameSheet = true
            }
        }
    }

    // MARK: - Request Apple name (local device)
    private func requestAppleName(completion: @escaping (String?) -> Void) {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else {
                completion(nil)
                return
            }

            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

            var foundName: String?

            try? store.enumerateContacts(with: request) { contact, stop in
                if !contact.givenName.isEmpty {
                    foundName = "\(contact.givenName) \(contact.familyName)"
                    stop.initialize(to: true)
                }
            }

            DispatchQueue.main.async {
                completion(foundName)
            }
        }
    }

    // MARK: - Fallback name sheet
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
                        if tempName.trimmingCharacters(in: .whitespaces).isEmpty {
                            displayName = fallbackFromDevice()
                        } else {
                            displayName = tempName.trimmingCharacters(in: .whitespaces)
                        }
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
