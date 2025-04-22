//
//  WeekContentView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct WeekViewContent: View {
    let daysInWeek: [Date]
    let viewModel: RoosterViewModel
    let userId: String
    
    var body: some View {
        ForEach(daysInWeek, id: \.self) { day in
            let dayEntries = entriesForDay(day)
            if !dayEntries.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    // Day Header
                    HStack {
                        Text(formatDayHeader(day))
                            .font(.headline)
                        
                        if Calendar.current.isDateInToday(day) {
                            Text("Vandaag")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Time Slots
                    VStack(spacing: 12) {
                        ForEach(dayEntries) { entry in
                            RoosterItemView(
                                entry: entry,
                                roosterEntries: .constant(viewModel.entries),
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
    
    private func entriesForDay(_ date: Date) -> [RoosterEntry] {
        viewModel.entries.filter { entry in
            Calendar.current.isDate(entry.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    private func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "EEEE d MMMM"
        return formatter.string(from: date).capitalized
    }
}
