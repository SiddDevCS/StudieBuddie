//
//  BreathingPatternCard.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import SwiftUI

struct BreathingPatternCard: View {
    let pattern: BreathingPattern
    let isSelected: Bool
    let action: () -> Void
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(pattern.localizedName)
                    .font(.headline)
                Text(pattern.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 160, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple.opacity(0.15) : Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .environment(\.locale, Locale(identifier: language))
    }
}
