//
//  PriorityBadge.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import SwiftUI

struct PriorityBadge: View {
    let priority: Priority
    
    var body: some View {
        Label {
            Text(priority.rawValue)
                .font(.caption)
        } icon: {
            Image(systemName: priority.icon)
        }
        .foregroundColor(priority.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(priority.color.opacity(0.1))
        )
    }
}
