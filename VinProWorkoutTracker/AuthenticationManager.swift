import SwiftUI
import AuthenticationServices

@Observable
class AuthenticationManager {
    var isAuthenticated = false
    var userID: String = ""
    var userName: String = ""
    var userEmail: String = ""
    var needsNamePrompt = false
    
    init() {
        loadAuthState()
    }
    
    func signOut() {
        isAuthenticated = false
        userID = ""
        userName = ""
        userEmail = ""
        needsNamePrompt = false
        saveAuthState()
    }
    
    func handleSignInWithApple(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                userID = credential.user
                
                // Get name if available (only provided on first sign in)
                if let givenName = credential.fullName?.givenName,
                   let familyName = credential.fullName?.familyName {
                    userName = "\(givenName) \(familyName)".trimmingCharacters(in: .whitespaces)
                }
                
                // Get email if available
                if let email = credential.email {
                    userEmail = email
                }
                
                // Check if we got a name from Apple, if not, prompt user
                if userName.isEmpty {
                    // Try to extract name from email
                    if !userEmail.isEmpty {
                        let emailName = userEmail.components(separatedBy: "@").first ?? ""
                        userName = emailName.replacingOccurrences(of: ".", with: " ")
                            .replacingOccurrences(of: "_", with: " ")
                            .capitalized
                    }
                    
                    // If still empty, we'll need to prompt
                    if userName.isEmpty {
                        needsNamePrompt = true
                    }
                }
                
                isAuthenticated = true
                saveAuthState()
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    func setDisplayName(_ name: String) {
        userName = name
        needsNamePrompt = false
        saveAuthState()
    }
    
    // MARK: - Guest Mode
    
    func continueAsGuest() {
        userID = "guest-\(UUID().uuidString)"
        userName = "" // Will trigger name prompt
        userEmail = ""
        isAuthenticated = true
        needsNamePrompt = true // User will be asked for their name
        saveAuthState()
        print("✅ User continued as guest")
    }
    
    // MARK: - Debug Helper (Simulator Only)
    
    #if targetEnvironment(simulator)
    func debugSkipSignIn() {
        userID = "simulator-user-\(UUID().uuidString.prefix(8))"
        userName = "" // Empty so we can test the name prompt
        userEmail = "simulator@test.com"
        isAuthenticated = true
        needsNamePrompt = true // Trigger name prompt
        saveAuthState()
        print("✅ DEBUG: Skipped sign-in for simulator")
    }
    #endif
    
    // MARK: - Persistence
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        needsNamePrompt = UserDefaults.standard.bool(forKey: "needsNamePrompt")
    }
    
    private func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(userID, forKey: "userID")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
        UserDefaults.standard.set(needsNamePrompt, forKey: "needsNamePrompt")
    }
}
