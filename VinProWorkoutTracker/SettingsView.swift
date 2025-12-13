import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    private enum Appearance: Int, CaseIterable, Identifiable {
        case system = 0
        case light  = 1
        case dark   = 2

        var id: Int { rawValue }

        var title: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
    }

    // MARK: - AppStorage

    @AppStorage("appTheme") private var theme: Int = Appearance.system.rawValue
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true

    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("displayName") private var storedDisplayName: String = ""
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false

    var body: some View {
        NavigationStack {
            Form {

                // BRANDING
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)

                            Text("LS")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading) {
                            Text("LiftSphere Workout")
                                .font(.headline)
                            Text("Vin Edition • Designed by Vin")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }

                // ACCOUNT
                Section("Account") {
                    if isSignedIn {
                        Text("Signed in as \(storedDisplayName)")
                        Button("Sign out", role: .destructive) {
                            isSignedIn = false
                            storedDisplayName = ""
                            didChooseLogin = true
                        }
                    } else {
                        Button("Sign in with Apple") {
                            didChooseLogin = false
                        }
                    }
                }

                // APPEARANCE
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        ForEach(Appearance.allCases) { style in
                            Text(style.title).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // WORKOUTS
                Section("Workouts") {
                    Toggle("Show Archived Workouts", isOn: $showArchivedWorkouts)
                    Toggle("Confirm Before Delete", isOn: $confirmBeforeDelete)
                }

                // APP INFO
                Section("App") {
                    Text("LiftSphere Workout – Vin Edition")
                        .font(.headline)
                    Text("Back-friendly workout tracking with analytics.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
