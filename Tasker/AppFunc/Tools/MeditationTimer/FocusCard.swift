//
//  FocusCard.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import SwiftUI

struct FocusCard: View {
    let focus: MeditationFocus
    let isSelected: Bool
    let action: () -> Void
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        Button(action: action) {
            cardContent
        }
        .buttonStyle(.plain)
        .environment(\.locale, Locale(identifier: language))
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(focus.localizedName)
                    .font(.headline)
                Spacer()
                Image(systemName: focus.icon)
                    .foregroundColor(.purple.opacity(0.8))
            }
            
            Text(focus.localizedDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(cardBackground)
        .overlay(cardBorder)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.purple.opacity(0.15) : Color(uiColor: .secondarySystemBackground))
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(isSelected ? Color.purple : Color.clear)
    }
}

extension MeditationFocus {
    var icon: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .relaxation: return "leaf"
        case .stress: return "heart.circle"
        case .sleep: return "moon.stars"
        case .energy: return "bolt"
        }
    }
}
