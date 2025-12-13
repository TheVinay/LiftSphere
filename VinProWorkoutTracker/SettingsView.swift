import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Appearance stored using the same key the App reads ("appTheme")
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

    // Theme
    @AppStorage("appTheme") private var theme: Int = Appearance.system.rawValue

    // Archive visibility
    @AppStorage("showArchivedWorkouts") private var showArchivedWorkouts: Bool = false

    // Account-related storage
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @AppStorage("displayName") private var storedDisplayName: String = ""
    @AppStorage("didChooseLogin") private var didChooseLogin: Bool = false

    var body: some View {
        NavigationStack {
            Form {

                // ---------------------------------------------------
                // BRANDING HEADER
                // ---------------------------------------------------
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)

                            Text("LS")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("LiftSphere Workout")
                                .font(.headline)
                            Text("Vin Edition • Designed by Vin")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                // ---------------------------------------------------
                // ACCOUNT
                // ---------------------------------------------------
                Section("Account") {
                    if isSignedIn {
                        Text("Signed in as \(storedDisplayName)")
                            .font(.subheadline)

                        Button("Sign out") {
                            isSignedIn = false
                            storedDisplayName = ""
                            didChooseLogin = true
                        }
                        .foregroundColor(.red)

                    } else {
                        Button("Sign in with Apple") {
                            didChooseLogin = false
                        }
                        .foregroundColor(.blue)
                    }
                }

                // ---------------------------------------------------
                // APPEARANCE
                // ---------------------------------------------------
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        ForEach(Appearance.allCases) { style in
                            Text(style.title).tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // ---------------------------------------------------
                // WORKOUT LIST
                // ---------------------------------------------------
                Section("Workouts") {
                    Toggle("Show Archived Workouts", isOn: $showArchivedWorkouts)
                }

                // ---------------------------------------------------
                // APP INFO
                // ---------------------------------------------------
                Section("App") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("LiftSphere Workout – Vin Edition")
                            .font(.headline)
                        Text("Designed by Vin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text(
                        "A back-friendly, customizable workout tracker for push, pull, legs, Amariss templates, and more, with simple logging and charts."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
