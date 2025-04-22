//
//  LoginView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 17/01/2025.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import UIKit
import _AuthenticationServices_SwiftUI

// MARK: - Notifications
extension Notification.Name {
    static let googleAuthenticationFailed = Notification.Name("GoogleAuthenticationFailed")
}

struct LoginView: View {
    // MARK: - Properties
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn = false
    @State private var isLoading = false
    @State private var showVerificationSent = false  // Add this line
    @Binding var showLoginView: Bool
    
    @State private var showPasswordResetAlert = false
    @State private var passwordResetMessage = ""
    @State private var showPasswordResetSuccess = false
    @State private var showReloginAlert = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 25) {
                headerView
                inputFieldsView
                errorMessageView
                loginButton
                dividerLine
                socialLoginButtons
                registerLink
                Spacer()
            }
            .padding()
            .disabled(isLoading)
            .overlay(loadingOverlay)
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            MainView()
        }
        .alert("Error", isPresented: .constant(!errorMessage.isEmpty)) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
        .alert("Password Reset", isPresented: $showPasswordResetAlert) {
            Button("OK") { }
        } message: {
            Text(passwordResetMessage)
        }
        .sheet(isPresented: $showPasswordResetSuccess) {
            PasswordResetSuccessView(email: email)
        }
        .sheet(isPresented: $showVerificationSent) {
            EmailVerificationView(email: email) {
                // This closure is called when verification is completed
                isLoggedIn = true
            }
        }
        .alert("Error", isPresented: .constant(!errorMessage.isEmpty)) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - View Components
extension LoginView {
    private var backgroundView: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.orange.opacity(0.3))
                .blur(radius: 50)
                .frame(width: 250, height: 250)
                .position(x: UIScreen.main.bounds.width * 0.8, y: 100)
            
            Circle()
                .fill(Color.orange.opacity(0.2))
                .blur(radius: 50)
                .frame(width: 200, height: 200)
                .position(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.8)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Welcome Back")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $email,
                          placeholder: "Email",
                          systemImage: "envelope")
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
            CustomSecureField(text: $password,
                            placeholder: "Password",
                            systemImage: "lock")
                .textContentType(.password)
            
            HStack {
                Spacer()
                Button(action: handleForgotPassword) {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private var errorMessageView: some View {
        Group {
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: handleLogin) {
            Text("Sign In")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color.orange)
                .cornerRadius(10)
        }
    }
    
    private var dividerLine: some View {
        HStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
            Text("or")
                .foregroundColor(.secondary)
                .font(.footnote)
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    private var socialLoginButtons: some View {
        VStack(spacing: 15) {
            // Google Button
            SocialLoginButton(action: handleGoogleLogin)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.5), .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: .orange.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            
            SignInWithAppleButton { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task {
                    do {
                        switch result {
                        case .success(let authorization):
                            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                                print("Invalid credential")
                                return
                            }
                            
                            try await AuthenticationManager.shared.signInWithApple(presenting: UIApplication.shared.windows.first?.rootViewController ?? UIViewController())
                            isLoggedIn = true
                            
                        case .failure(let error):
                            print("Apple sign in error: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .frame(height: 45)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.5), .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .orange.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .padding(.horizontal, 2) // Add some padding to prevent shadow clipping
    }
    
    private var registerLink: some View {
        Button(action: { showLoginView = false }) {
            Text("Don't have an account? Sign Up")
                .foregroundColor(.orange)
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
}

// MARK: - Helper Methods
extension LoginView {
    private func handleLogin() {
        isLoading = true
        Task {
            do {
                try await viewModel.signIn(email: email, password: password)
                DispatchQueue.main.async {
                    isLoading = false
                    isLoggedIn = true
                    errorMessage = ""
                }
            } catch let error as AuthError {
                DispatchQueue.main.async {
                    isLoading = false
                    if case .emailNotVerified = error {
                        // Show verification view
                        showVerificationSent = true
                    } else {
                        errorMessage = error.errorDescription ?? "An error occurred"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleForgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false
            if let error = error {
                passwordResetMessage = error.localizedDescription
                showPasswordResetAlert = true
            } else {
                showPasswordResetSuccess = true
            }
        }
    }
    
    private func handleGoogleLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        isLoading = true
        Task {
            do {
                try await AuthenticationManager.shared.signInWithGoogle(presenting: rootViewController)
                isLoggedIn = true
            } catch {
                handleAuthError(error)
            }
            isLoading = false
        }
    }
    
    private func handleAuthError(_ error: Error) {
        DispatchQueue.main.async {
            if let authError = error as? AuthError {
                errorMessage = authError.errorDescription ?? "An error occurred"
            } else {
                let nsError = error as NSError
                switch nsError.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    errorMessage = "Invalid password. Please try again"
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email address"
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error. Please check your connection"
                case AuthErrorCode.userDisabled.rawValue:
                    errorMessage = "This account has been disabled"
                case AuthErrorCode.tooManyRequests.rawValue:
                    errorMessage = "Too many attempts. Please try again later"
                default:
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
