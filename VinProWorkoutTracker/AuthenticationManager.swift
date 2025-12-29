import SwiftUI
import AuthenticationServices

@Observable
class AuthenticationManager {
    var isAuthenticated = false
    var userID: String = ""
    var userName: String = ""
    var userEmail: String = ""
    
    init() {
        loadAuthState()
    }
    
    func signOut() {
        isAuthenticated = false
        userID = ""
        userName = ""
        userEmail = ""
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
                
                isAuthenticated = true
                saveAuthState()
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Persistence
    
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    }
    
    private func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(userID, forKey: "userID")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userEmail, forKey: "userEmail")
    }
}
