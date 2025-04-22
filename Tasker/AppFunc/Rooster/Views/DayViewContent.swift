//
//  DayViewContent.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct DayViewContent: View {
    let entries: [RoosterEntry]
    let userId: String
    
    private let timeSlots = [
        ("Ochtend", 0..<12),
        ("Middag", 12..<17),
        ("Avond", 17..<24)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(timeSlots, id: \.0) { title, hours in
                let slotEntries = entriesInTimeSlot(hours)
                if !slotEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        // Time Slot Header
                        HStack {
                            Image(systemName: timeSlotIcon(for: title))
                                .foregroundColor(.secondary)
                            Text(title)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        // Entries
                        VStack(spacing: 12) {
                            ForEach(slotEntries) { entry in
                                RoosterItemView(
                                    entry: entry,
                                    roosterEntries: .constant([entry]),
                                    userId: userId
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                }
            }
        }
    }
    
    private func entriesInTimeSlot(_ hours: Range<Int>) -> [RoosterEntry] {
        entries.filter { entry in
            let hour = Calendar.current.component(.hour, from: entry.startTime)
            return hours.contains(hour)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    private func timeSlotIcon(for slot: String) -> String {
        switch slot {
        case "Ochtend": return "sun.and.horizon"
        case "Middag": return "sun.max"
        case "Avond": return "moon.stars"
        default: return "clock"
        }
    }
}
