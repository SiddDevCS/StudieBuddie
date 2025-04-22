//
//  WachtwoordResetSuccesView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 26/01/2025.
//

import SwiftUI

struct PasswordResetSuccessView: View {
    @Environment(\.dismiss) var dismiss
    let email: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Check Your Email")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We've sent a password reset link to:\n\(email)")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Next steps:")
                    .font(.headline)
                
                BulletPoint(text: "Check your email inbox")
                BulletPoint(text: "Click the reset link in the email")
                BulletPoint(text: "Create a new password")
                BulletPoint(text: "Return here to sign in")
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            Button(action: {
                dismiss()
            }) {
                Text("Back to Sign In")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .padding()
    }
}
