import SwiftUI

struct UsernameSetupView: View {
    @Environment(\.dismiss) private var dismiss
    let friendManager: CloudKitFriendManager
    let onComplete: () -> Void
    
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var isCreating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 20)
                    
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
                            .frame(width: 120, height: 120)
                        
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
                    
                    VStack(spacing: 12) {
                        Text("Create Your Profile")
                            .font(.title.bold())
                        
                        Text("Set up your profile to connect with friends and share workouts")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Form
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline.weight(.semibold))
                            
                            TextField("username", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .textContentType(.username)
                            
                            Text("Lowercase, no spaces. Others can find you by this.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.subheadline.weight(.semibold))
                            
                            TextField("Your Name", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                            
                            Text("This is how your name appears to others")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio (Optional)")
                                .font(.subheadline.weight(.semibold))
                            
                            TextField("Tell us about yourself", text: $bio, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...5)
                            
                            Text("Share your fitness goals or interests")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 32)
                    }
                    
                    Button {
                        createProfile()
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
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(isCreating || !isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled()
    }
    
    private var isValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty &&
        username.range(of: "^[a-z0-9_]+$", options: .regularExpression) != nil
    }
    
    private func createProfile() {
        isCreating = true
        errorMessage = nil
        
        Task {
            do {
                try await friendManager.createUserProfile(
                    username: username.lowercased().trimmingCharacters(in: .whitespaces),
                    displayName: displayName.trimmingCharacters(in: .whitespaces),
                    bio: bio.trimmingCharacters(in: .whitespaces)
                )
                
                await MainActor.run {
                    isCreating = false
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    isCreating = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    UsernameSetupView(friendManager: CloudKitFriendManager()) {
        print("Profile created!")
    }
}
