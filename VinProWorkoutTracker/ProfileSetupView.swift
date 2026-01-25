import SwiftUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss
    let socialService: SocialService
    
    @State private var username = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Display Name", text: $displayName)
                        .textContentType(.name)
                    
                    TextField("Bio (optional)", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Profile Information")
                } footer: {
                    Text("Your username must be unique and can only contain letters, numbers, and underscores.")
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createProfile()
                        }
                    }
                    .disabled(!isValid || isCreating)
                }
            }
            .disabled(isCreating)
        }
    }
    
    private var isValid: Bool {
        !username.isEmpty && 
        !displayName.isEmpty &&
        username.count >= 3 &&
        username.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" }
    }
    
    private func createProfile() async {
        isCreating = true
        errorMessage = nil
        
        do {
            try await socialService.createUserProfile(
                username: username.lowercased().trimmingCharacters(in: .whitespaces), // Normalize username
                displayName: displayName,
                bio: bio
            )
            dismiss()
        } catch let error as SocialError {
            // Handle specific social errors
            switch error {
            case .usernameAlreadyTaken, .usernameTaken:
                errorMessage = "Username '\(username)' is already taken. Please choose another."
            case .notAuthenticated:
                errorMessage = "Please sign in to iCloud to create a social profile."
            default:
                errorMessage = error.localizedDescription
            }
            isCreating = false
        } catch {
            errorMessage = "Failed to create profile: \(error.localizedDescription)"
            isCreating = false
        }
    }
}

#Preview {
    ProfileSetupView(socialService: SocialService())
}
