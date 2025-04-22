//
//  StudyTipsCategory.swift
//  Tasker
//
//  Created by Chetna Sehgal on 27/02/2025.
//

import Foundation

enum StudyTipsCategory: String, CaseIterable {
    case general = "Algemeen"
    case timeManagement = "Timemanagement"
    case concentration = "Concentratie"
    case examPrep = "Tentamenvoorbereiding"
    case motivation = "Motivatie"
    case stressManagement = "Stressmanagement"
    
    var emoji: String {
        switch self {
        case .general: return "📚"
        case .timeManagement: return "⏰"
        case .concentration: return "🎯"
        case .examPrep: return "✍️"
        case .motivation: return "💪"
        case .stressManagement: return "🧘‍♂️"
        }
    }
}
