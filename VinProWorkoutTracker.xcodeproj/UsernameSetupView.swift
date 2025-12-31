import SwiftUI

/// First-time setup: Choose a username
struct UsernameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    let friendManager: CloudKitFriendManager
    let onComplete: () -> Void
    
    @State private var username = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 40)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Set Up Your Profile")
                            .font(.title.bold())
                        
                        Text("Choose a username to connect with friends")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Form
                    VStack(alignment: .leading, spacing: 20) {
                        // Username
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                            
                            TextField("username", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .font(.body)
                            
                            Text("Lowercase, no spaces. This is how friends will find you.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Display Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                            
                            TextField("Your Name", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                            
                            Text("This is what appears on your profile.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Bio (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio (Optional)")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                            
                            TextEditor(text: $bio)
                                .frame(height: 80)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Text("Tell friends about your fitness journey.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    // Create Button
                    Button {
                        Task {
                            await createProfile()
                        }
                    } label: {
                        Group {
                            if isCreating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Profile")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: isFormValid ? [.blue, .purple] : [.gray, .gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(!isFormValid || isCreating)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        username.count >= 3 &&
        username.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" } &&
        !displayName.isEmpty
    }
    
    // MARK: - Actions
    
    private func createProfile() async {
        isCreating = true
        
        do {
            _ = try await friendManager.createUserProfile(
                username: username.lowercased(),
                displayName: displayName,
                bio: bio
            )
            
            await MainActor.run {
                isCreating = false
                onComplete()
                dismiss()
            }
            
        } catch {
            await MainActor.run {
                isCreating = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    UsernameSetupView(
        friendManager: CloudKitFriendManager(),
        onComplete: {}
    )
}
