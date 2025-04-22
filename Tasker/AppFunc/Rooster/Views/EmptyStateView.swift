//
//  EmptyStateView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let viewMode: WeekScheduleView.ViewMode
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 8) {
                Text("Geen lessen gevonden")
                    .font(.title3.bold())
                
                Text(emptyStateMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {}) {
                Label("Les toevoegen", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
    
    private var emptyStateMessage: String {
        switch viewMode {
        case .day:
            return "Er zijn geen lessen gepland voor deze dag.\nVoeg een les toe of selecteer een andere dag."
        case .week:
            return "Er zijn geen lessen gepland voor deze week.\nVoeg een les toe of selecteer een andere week."
        }
    }
}
