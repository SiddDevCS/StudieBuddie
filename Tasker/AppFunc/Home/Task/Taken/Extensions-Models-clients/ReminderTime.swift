//
//  ReminderTime.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/03/2025.
//

import Foundation

enum ReminderTime: String, CaseIterable, Identifiable {
    case none
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case oneDay
    
    var id: String { self.rawValue }
    
    var localizedDescription: String {
        switch self {
        case .none: return Bundle.localizedString(forKey: "No reminder")
        case .fiveMinutes: return Bundle.localizedString(forKey: "5 minutes before")
        case .fifteenMinutes: return Bundle.localizedString(forKey: "15 minutes before")
        case .thirtyMinutes: return Bundle.localizedString(forKey: "30 minutes before")
        case .oneHour: return Bundle.localizedString(forKey: "1 hour before")
        case .oneDay: return Bundle.localizedString(forKey: "1 day before")
        }
    }
    
    var minutes: Int {
        switch self {
        case .none: return 0
        case .fiveMinutes: return 5
        case .fifteenMinutes: return 15
        case .thirtyMinutes: return 30
        case .oneHour: return 60
        case .oneDay: return 1440 // 24 * 60
        }
    }
}
