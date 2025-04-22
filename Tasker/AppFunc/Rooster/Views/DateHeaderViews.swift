//
//  DateHeaderViews.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct DateHeaderView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: WeekScheduleView.ViewMode
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    private let weekDays = ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"]
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 12) {
            // Month and Year
            HStack {
                VStack(alignment: .leading) {
                    Text(monthYearString)
                        .font(.title2.bold())
                    
                    if viewMode == .week {
                        Text("Week \(weekNumber)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: 12) {
                    Button(action: onPrevious) {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                    }
                    .buttonStyle(CircleButtonStyle())
                    
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .imageScale(.large)
                    }
                    .buttonStyle(CircleButtonStyle())
                }
            }
            .padding(.horizontal)
            
            // Week Days
            if viewMode == .week {
                HStack(spacing: 0) {
                    ForEach(0..<7) { index in
                        let date = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
                        WeekDayCell(
                            day: weekDays[index],
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date)
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate).capitalized
    }
    
    private var weekNumber: String {
        let week = calendar.component(.weekOfYear, from: selectedDate)
        return String(format: "%02d", week)
    }
    
    private var startOfWeek: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
    }
}

// MARK: - Supporting Views
private struct WeekDayCell: View {
    let day: String
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.callout.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .opacity(isSelected || isToday ? 1 : 0)
        )
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        } else if isToday {
            return Color(.systemGray5)
        } else {
            return .clear
        }
    }
}

// MARK: - Button Style
private struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(
                Circle()
                    .fill(Color(.systemGray6))
                    .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .foregroundColor(.primary)
    }
}
