//
//  LoadingOverlayView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct LoadingOverlayView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Custom Loading Animation
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.accentColor, lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(
                            .linear(duration: 1)
                            .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                
                Text("Rooster laden...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground).opacity(0.8))
                    .backgroundStyle(.thickMaterial)
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}
