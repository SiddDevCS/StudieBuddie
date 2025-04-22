//
//  AuthenticationManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 17/01/2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import CryptoKit

class AuthenticationManager: NSObject {
    static let shared = AuthenticationManager()
    public private(set) var currentNonce: String?
    
    private override init() {
        super.init()
        print("AuthenticationManager initialized")
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(presenting: UIViewController) async throws {
        print("Starting Google Sign In process...")
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let clientID = "676996401002-osavrvedvova4cuv3j206jlhd0torv7v.apps.googleusercontent.com"
                print("Using Client ID: \(clientID)")
                
                let config = GIDConfiguration(clientID: clientID)
                GIDSignIn.sharedInstance.configuration = config
                
                let scopes = [
                    "https://www.googleapis.com/auth/calendar",
                    "https://www.googleapis.com/auth/calendar.events"
                ]
                
                print("Initiating Google Sign In with scopes: \(scopes)")
                
                GIDSignIn.sharedInstance.signIn(
                    withPresenting: presenting,
                    hint: nil,
                    additionalScopes: scopes
                ) { [weak self] result, error in
                    if let error = error {
                        print("Google Sign In Error: \(error.localizedDescription)")
                        print("Detailed error: \(error)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let result = result else {
                        print("No result from Google Sign In")
                        continuation.resume(throwing: AuthError.tokenError)
                        return
                    }
                    
                    print("Google Sign In successful for user: \(result.user.profile?.email ?? "Unknown")")
                    
                    guard let idToken = result.user.idToken?.tokenString else {
                        print("Failed to get ID token")
                        continuation.resume(throwing: AuthError.tokenError)
                        return
                    }
                    
                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: result.user.accessToken.tokenString
                    )
                    
                    Task {
                        do {
                            let authResult = try await Auth.auth().signIn(with: credential)
                            print("Firebase Sign In successful for user: \(authResult.user.email ?? "Unknown")")
                            continuation.resume()
                        } catch {
                            print("Firebase Sign In Error: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        }
    }
    

    // MARK: - Apple Sign In
    func signInWithApple(presenting: UIViewController) async throws {
        let nonce = generateNonce()
        currentNonce = nonce
        
        // Create Apple ID request
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        // Create authorization controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        // Perform request and handle response
        let result = try await withCheckedThrowingContinuation { continuation in
            let delegate = AppleSignInCoordinator(continuation: continuation)
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            
            // Keep delegate alive
            objc_setAssociatedObject(authorizationController, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
            
            // Present sign in
            authorizationController.performRequests()
        }
        
        // Handle the authorization result
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.tokenError
        }
        
        // Create Firebase credential
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        // Sign in with Firebase
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Handle new user
            if let fullName = appleIDCredential.fullName,
               let givenName = fullName.givenName,
               let familyName = fullName.familyName {
                let changeRequest = authResult.user.createProfileChangeRequest()
                changeRequest.displayName = "\(givenName) \(familyName)"
                try await changeRequest.commitChanges()
            }
            
            // Mark as signed in
            UserDefaults.standard.set(true, forKey: "userSignedIn")
            UserDefaults.standard.synchronize()
            
            print("Successfully signed in with Apple: \(authResult.user.uid)")
        } catch {
            print("Error signing in with Apple: \(error.localizedDescription)")
            throw error
        }
    }

    // Updated Apple Sign In Coordinator
    class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let continuation: CheckedContinuation<ASAuthorization, Error>
        
        init(continuation: CheckedContinuation<ASAuthorization, Error>) {
            self.continuation = continuation
            super.init()
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                fatalError("No window found")
            }
            return window
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            continuation.resume(returning: authorization)
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            continuation.resume(throwing: error)
        }
    }
    
    // MARK: - Helper Methods
    private func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // MARK: - Sign Out
    // Add this to your AuthenticationManager class
    func configureAuthStateHandling() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                // User is signed out, clear all credentials
                UserDefaults.standard.removeObject(forKey: "userSignedIn")
                UserDefaults.standard.synchronize()
            }
        }
    }

    // Modify your signOut function
    func signOut() throws {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Sign out from Google if needed
            GIDSignIn.sharedInstance.signOut()
            
            // Clear all stored credentials
            UserDefaults.standard.removeObject(forKey: "userSignedIn")
            UserDefaults.standard.removeObject(forKey: "authToken")
            UserDefaults.standard.synchronize()
            
            // Clear any other auth states
            SessionManager.shared.endSession()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            throw error
        }
    }
    
    // When user signs in successfully
    func completeSignIn() {
        UserDefaults.standard.set(true, forKey: "userSignedIn")
        UserDefaults.standard.synchronize()
    }
    
    func isUserVerified() -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        return user.isEmailVerified
    }

    func checkAndRefreshEmailVerification() async throws -> Bool {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        
        try await user.reload()
        return user.isEmailVerified
    }

    // Add this to your AuthError enum
    enum AuthError: LocalizedError {
        case clientIDNotFound
        case tokenError
        case noCurrentUser
        case cancelled
        case emailNotVerified
        
        var errorDescription: String? {
            switch self {
            case .clientIDNotFound:
                return "Authentication configuration not found"
            case .tokenError:
                return "Failed to get authentication token"
            case .noCurrentUser:
                return "No signed-in user found"
            case .cancelled:
                return "Sign in cancelled by user"
            case .emailNotVerified:
                return "Please verify your email before continuing"
            }
        }
    }
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}
