//
//  CalendarColor.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/03/2025.
//

import SwiftUI

enum CalendarColor: String, CaseIterable, Identifiable {
    case defaultColor
    case red
    case orange
    case green
    case blue
    case purple
    
    var id: String { self.rawValue }
    
    var localizedDescription: String {
        switch self {
        case .defaultColor: return Bundle.localizedString(forKey: "Default")
        case .red: return Bundle.localizedString(forKey: "Red")
        case .orange: return Bundle.localizedString(forKey: "Orange")
        case .green: return Bundle.localizedString(forKey: "Green")
        case .blue: return Bundle.localizedString(forKey: "Blue")
        case .purple: return Bundle.localizedString(forKey: "Purple")
        }
    }
    
    var color: Color {
        switch self {
        case .defaultColor: return .gray
        case .red: return .red
        case .orange: return .orange
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        }
    }
    
    var googleColorId: String {
        switch self {
        case .defaultColor: return "1"  // Lavender
        case .red: return "11"          // Tomato
        case .orange: return "6"        // Tangerine
        case .green: return "2"         // Sage
        case .blue: return "7"          // Peacock
        case .purple: return "3"        // Grape
        }
    }
}
