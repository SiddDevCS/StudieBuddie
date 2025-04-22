//
//  CalendarPickerView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: WeekScheduleView.ViewMode
    let onDateSelected: (Date) -> Void
    
    @State private var monthOffset = 0
    @State private var showMonthPicker = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month Navigation
            HStack {
                Button(action: { monthOffset -= 1 }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                
                Spacer()
                
                Button(action: { showMonthPicker = true }) {
                    Text(monthYearString)
                        .font(.title3.bold())
                }
                
                Spacer()
                
                Button(action: { monthOffset += 1 }) {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                }
            }
            .padding(.horizontal)
            
            // Days of Week Header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                                onDateSelected(date)
                            }
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .sheet(isPresented: $showMonthPicker) {
            MonthYearPickerView(
                selectedDate: $selectedDate,
                monthOffset: $monthOffset
            )
            .presentationDetents([.height(300)])
        }
    }
    
    private var currentMonth: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "nl_NL")
        return formatter.string(from: currentMonth).capitalized
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        
        return calendar.generateDates(for: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .font(.system(.callout, design: .rounded))
            .fontWeight(isToday ? .bold : .regular)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .scaleEffect(isSelected ? 0.9 : 1)
            )
            .foregroundColor(textColor)
            .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        } else if isToday {
            return .accentColor.opacity(0.2)
        }
        return .clear
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isCurrentMonth {
            return .secondary.opacity(0.5)
        }
        return .primary
    }
}

struct MonthYearPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    @Binding var monthOffset: Int
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    private let calendar = Calendar.current
    private let months = Calendar.current.shortMonthSymbols
    private let years: [Int]
    
    init(selectedDate: Binding<Date>, monthOffset: Binding<Int>) {
        self._selectedDate = selectedDate
        self._monthOffset = monthOffset
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        self.years = (currentYear-2...currentYear+5).map { $0 }
        
        self._selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        self._selectedMonth = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue) - 1)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(months[index]).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding()
            }
            .navigationTitle("Selecteer Datum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gereed") {
                        updateDate()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1
        components.day = 1
        
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
            monthOffset = calendar.dateComponents([.month], from: Date(), to: newDate).month ?? 0
        }
    }
}
