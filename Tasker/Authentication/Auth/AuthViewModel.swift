//
//  AuthViewModel.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 18/01/2025.
//

import Foundation
import FirebaseAuth
import LocalAuthentication

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var error: AuthError?
    @Published var isLoading: Bool = false
    @Published var username: String = ""
    @Published var isEmailVerified = false
    @Published var showVerificationAlert = false
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        isSignedIn = Auth.auth().currentUser != nil
        setupAuthStateListener()
        if let user = Auth.auth().currentUser {
            loadUserInfo(user)
        }
    }
    
    private func setupAuthStateListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isSignedIn = user != nil
                if let user = user {
                    self?.loadUserInfo(user)
                }
                print("Auth status changed - User is \(user != nil ? "signed in" : "signed out")")
            }
        }
    }
    
    private func loadUserInfo(_ user: FirebaseAuth.User) {
        username = user.displayName ?? "User"
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        // Check email verification
        if !result.user.isEmailVerified {
            // Sign out the user
            try await Auth.auth().signOut()
            throw AuthError.emailNotVerified
        }
        
        // User is verified, complete sign in
        AuthenticationManager.shared.completeSignIn()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            SessionManager.shared.endSession()
        } catch {
            self.error = .signOutFailed
        }
    }
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            self.error = .invalidPassword
        case AuthErrorCode.invalidEmail.rawValue:
            self.error = .invalidEmail
        case AuthErrorCode.networkError.rawValue:
            self.error = .networkError
        case AuthErrorCode.userDisabled.rawValue:
            self.error = .userDisabled
        case AuthErrorCode.tooManyRequests.rawValue:
            self.error = .tooManyAttempts
        default:
            self.error = .unknown(error.localizedDescription)
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
