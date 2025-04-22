//
//  SocialLoginButton.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/03/2025.
//

import SwiftUI

struct SocialLoginButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "g.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.orange)
                
                Text("Continue with Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.black.opacity(0.8))
            .cornerRadius(25)
        }
    }
}

struct SocialLoginButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            SocialLoginButton(action: {})
                .padding()
        }
    }
}
