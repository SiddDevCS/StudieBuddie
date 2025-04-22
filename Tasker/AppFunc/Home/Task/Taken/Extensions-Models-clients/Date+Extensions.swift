//
//  Date+Extensions.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation

extension Date {
    func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }
    
    var isOverdue: Bool {
        return self < Date()
    }
    
    func formatRelative() -> String {
        let daysUntil = Date().daysUntil(self)
        
        if daysUntil == 0 {
            return Bundle.localizedString(forKey: "Today")
        } else if daysUntil == 1 {
            return Bundle.localizedString(forKey: "Tomorrow")
        } else if daysUntil == -1 {
            return Bundle.localizedString(forKey: "Yesterday")
        } else if daysUntil > 0 {
            return String(format: Bundle.localizedString(forKey: "In %d days"), daysUntil)
        } else {
            return String(format: Bundle.localizedString(forKey: "%d days ago"), abs(daysUntil))
        }
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = self.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
}
