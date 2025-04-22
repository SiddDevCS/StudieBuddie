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
    func signInWithApple() async throws {
        let nonce = generateNonce()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let result = try await performAppleSignIn(request: request)
        
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.tokenError
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        try await Auth.auth().signIn(with: credential)
    }
    
    private func performAppleSignIn(request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation)
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
            
            // Keep delegate alive until completion
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
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
    func signOut() async throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
    
    // MARK: - Error Handling
    enum AuthError: LocalizedError {
        case clientIDNotFound
        case tokenError
        case noCurrentUser
        case cancelled
        
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