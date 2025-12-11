import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    // Shared with ProfileView
    @AppStorage("displayName") private var displayName: String = ""
    @AppStorage("profile.bio") private var bio: String = ""
    @AppStorage("profile.link") private var link: String = ""

    // For private stuff if you’re using it later
    @State private var sex: String = ""
    @State private var birthday: Date? = nil
    @State private var showBirthdayPicker = false

    private var avatarInitial: String {
        displayName.trimmingCharacters(in: .whitespaces).first.map { String($0).uppercased() } ?? "V"
    }

    var body: some View {
        NavigationStack {
            Form {
                // Avatar + change picture
                Section {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 90, height: 90)

                            Text(avatarInitial)
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Button("Change Picture") {
                            // Hook up later
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Public profile data
                Section(header: Text("Public profile data")) {
                    TextField("Your full name", text: $displayName)
                    TextField("Describe yourself", text: $bio, axis: .vertical)
                    TextField("https://example.com", text: $link)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                // Private data (preview)
                Section(header: HStack {
                    Text("Private data")
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }) {
                    HStack {
                        Text("Sex")
                        Spacer()
                        Text(sex.isEmpty ? "Select" : sex)
                            .foregroundStyle(sex.isEmpty ? .blue : .primary)
                    }

                    HStack {
                        Text("Birthday")
                        Spacer()
                        Button {
                            showBirthdayPicker = true
                        } label: {
                            Text(birthdayText)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showBirthdayPicker) {
                BirthdayPickerView(selectedDate: $birthday)
            }
        }
    }

    private var birthdayText: String {
        guard let date = birthday else { return "Select" }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
}

// Same helper as before
private struct BirthdayPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date?

    @State private var tempDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Birthday",
                    selection: $tempDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 300)

                Spacer()
            }
            .navigationTitle("Select birthday")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}
