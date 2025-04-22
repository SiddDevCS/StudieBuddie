//
//  EmailVerificationView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 26/01/2025.
//

import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    let email: String
    var onVerificationCompleted: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "envelope.badge.shield.half.filled")
                .font(.system(size: 70))
                .foregroundColor(.orange)
            
            Text("Verify Your Email")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We've sent a verification link to:\n\(email)")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Next steps:")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                BulletPoint(text: "Open your email inbox")
                BulletPoint(text: "Click the verification link")
                BulletPoint(text: "Return here to sign in")
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            Button(action: resendVerification) {
                Text("Resend Email")
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Button(action: checkVerification) {
                Text("I've Verified")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            
            Button(action: { dismiss() }) {
                Text("Verify Later")
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func resendVerification() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user found"
            showError = true
            return
        }
        
        Task {
            do {
                try await user.sendEmailVerification()
                errorMessage = "Verification email has been resent"
                showError = true
            } catch {
                errorMessage = "Could not send verification email: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func checkVerification() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user found"
            showError = true
            return
        }
        
        Task {
            do {
                try await user.reload()
                if user.isEmailVerified {
                    onVerificationCompleted()
                    dismiss()
                } else {
                    errorMessage = "Email is not yet verified"
                    showError = true
                }
            } catch {
                errorMessage = "Could not check verification status: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(.headline)
            Text(text)
        }
    }
}
