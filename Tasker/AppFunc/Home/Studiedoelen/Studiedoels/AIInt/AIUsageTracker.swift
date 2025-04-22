//
//  AIUsageTracker.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 24/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class AIUsageTracker: ObservableObject {
    static let shared = AIUsageTracker()
    
    @Published var weeklyUsageCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let storageKey = "ai_usage_data"
    private let lastResetKey = "ai_last_reset_date"
    
    private init() {
        loadWeeklyUsage()
    }
    
    func loadWeeklyUsage() {
        let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date ?? Date()
        
        if Date().timeIntervalSince(lastReset) >= 7 * 24 * 60 * 60 {
            resetUsage()
        } else {
            weeklyUsageCount = UserDefaults.standard.integer(forKey: storageKey)
        }
    }
    
    func incrementUsage() throws {
        if weeklyUsageCount >= 4 {
            throw ChatError.weeklyLimitExceeded
        }
        
        weeklyUsageCount += 1
        UserDefaults.standard.set(weeklyUsageCount, forKey: storageKey)
        UserDefaults.standard.set(Date(), forKey: lastResetKey)
    }
    
    private func resetUsage() {
        weeklyUsageCount = 0
        UserDefaults.standard.set(weeklyUsageCount, forKey: storageKey)
        UserDefaults.standard.set(Date(), forKey: lastResetKey)
    }
}
