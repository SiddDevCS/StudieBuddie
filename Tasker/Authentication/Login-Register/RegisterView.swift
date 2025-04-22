//
//  RegisterView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 17/01/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    // MARK: - Properties
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showVerificationSent = false
    @State private var showResendAlert = false
    @Binding var showLoginView: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView {
                VStack(spacing: 25) {
                    headerView
                    inputFieldsView
                    errorMessageView
                    registerButton
                    loginLink
                }
                .padding()
            }
            .disabled(isLoading)
            .overlay(loadingOverlay)
        }
        .alert("Error", isPresented: .constant(!errorMessage.isEmpty)) {
            Button("OK") { errorMessage = "" }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showVerificationSent) {
            EmailVerificationView(email: email) {
                showLoginView = true
            }
        }
        .alert("Verification Email", isPresented: $showResendAlert) {
            Button("Resend") {
                resendVerificationEmail()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to resend the verification email?")
        }
    }
    
    // MARK: - UI Components
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
            Text("Create Account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            Text("Register to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 20) {
            CustomTextField(text: $fullName,
                          placeholder: "Full Name",
                          systemImage: "person")
                .textContentType(.name)
            
            CustomTextField(text: $email,
                          placeholder: "Email Address",
                          systemImage: "envelope")
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
            
            CustomSecureField(text: $password,
                            placeholder: "Password",
                            systemImage: "lock")
            
            CustomSecureField(text: $confirmPassword,
                            placeholder: "Confirm Password",
                            systemImage: "lock")
            
            passwordRequirementsView
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var passwordRequirementsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password must contain:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Group {
                RequirementRow(text: "At least 8 characters",
                             isMet: password.count >= 8)
                RequirementRow(text: "One uppercase letter",
                             isMet: password.contains(where: { $0.isUppercase }))
                RequirementRow(text: "One lowercase letter",
                             isMet: password.contains(where: { $0.isLowercase }))
                RequirementRow(text: "One number",
                             isMet: password.contains(where: { $0.isNumber }))
                RequirementRow(text: "One special character",
                             isMet: password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }))
            }
            .font(.caption2)
        }
    }
    
    struct RequirementRow: View {
        let text: String
        let isMet: Bool
        
        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isMet ? .green : .secondary)
                
                Text(text)
                    .foregroundColor(isMet ? .primary : .secondary)
                
                Spacer()
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
    
    private var registerButton: some View {
        Button(action: handleRegister) {
            Text("Create Account")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color.orange)
                .cornerRadius(10)
        }
    }
    
    private var loginLink: some View {
        Button(action: { showLoginView = true }) {
            Text("Already have an account? Sign In")
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
extension RegisterView {
    private func validateInputs() -> Bool {
        // Validate full name
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your full name"
            return false
        }
        
        // Validate email
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Validate password
        guard password.count >= 8,
              password.contains(where: { $0.isUppercase }),
              password.contains(where: { $0.isLowercase }),
              password.contains(where: { $0.isNumber }),
              password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) }) else {
            errorMessage = "Please ensure your password meets all requirements"
            return false
        }
        
        // Validate password confirmation
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        return true
    }
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = "Email is already in use"
        case AuthErrorCode.invalidEmail.rawValue:
            errorMessage = "Invalid email address"
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = "Password is too weak"
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "Network error. Please check your connection"
        default:
            errorMessage = error.localizedDescription
        }
    }
    
    private func createUserProfile(for user: FirebaseAuth.User) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        let userData: [String: Any] = [
            "email": email.lowercased(),
            "fullName": fullName,
            "created": FieldValue.serverTimestamp(),
            "lastLogin": FieldValue.serverTimestamp(),
            "isEmailVerified": false,
            "profilePhotoUrl": "",
            "userType": "email",
        ]
        
        try await userRef.setData(userData)
    }
    
    private func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user found"
            return
        }
        
        Task {
            do {
                try await user.sendEmailVerification()
                errorMessage = "Verification email has been resent"
            } catch {
                errorMessage = "Could not send verification email: \(error.localizedDescription)"
            }
        }
    }
    
    private func handleRegister() {
        guard validateInputs() else { return }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                handleAuthError(error)
                return
            }
            
            guard let user = result?.user else {
                isLoading = false
                errorMessage = "Failed to create user"
                return
            }
            
            // Send verification email and create profile
            Task {
                do {
                    try await user.sendEmailVerification()
                    try await createUserProfile(for: user)
                    
                    DispatchQueue.main.async {
                        isLoading = false
                        showVerificationSent = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        isLoading = false
                        handleAuthError(error)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(showLoginView: .constant(false))
    }
}
