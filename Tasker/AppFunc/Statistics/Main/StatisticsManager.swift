//
//  StatisticsManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 22/01/2025.
//

import Foundation

class StatisticsManager {
    static let shared = StatisticsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys for UserDefaults
    private func key(_ type: String, for userId: String) -> String {
        return "\(userId)_\(type)"
    }
    
    // MARK: - App Launch Check
    func checkAndUpdateStreak(userId: String) {
        let lastLoginKey = key("last_login_date", for: userId)
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastLogin = defaults.object(forKey: lastLoginKey) as? Date {
            if !Calendar.current.isDate(lastLogin, inSameDayAs: today) {
                updateDailyStreak(userId: userId)
            }
        } else {
            updateDailyStreak(userId: userId)
        }
        
        defaults.set(today, forKey: lastLoginKey)
    }
    
    // MARK: - Monthly Reset
    private func checkAndResetMonthlyStats(userId: String) {
        let lastResetKey = self.key("last_reset_date", for: userId)
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastReset = defaults.object(forKey: lastResetKey) as? Date {
            let calendar = Calendar.current
            if !calendar.isDate(lastReset, equalTo: today, toGranularity: .month) {
                resetMonthlyStats(userId: userId)
                defaults.set(today, forKey: lastResetKey)
            }
        } else {
            defaults.set(today, forKey: lastResetKey)
        }
    }
    
    private func resetMonthlyStats(userId: String) {
        defaults.set(0, forKey: self.key("pomodoro_sessions", for: userId))
        defaults.set(0, forKey: self.key("meditation_sessions", for: userId))
        defaults.set(0, forKey: self.key("quotes_viewed", for: userId))
        defaults.set(0, forKey: self.key("tasks_completed", for: userId))
    }
    
    // MARK: - Streak Management
    func updateDailyStreak(userId: String) {
        let today = Calendar.current.startOfDay(for: Date())
        let streakDateKey = key("last_streak_date", for: userId)
        let streakCountKey = key("current_streak", for: userId)
        let bestStreakKey = key("best_streak", for: userId)
        
        if let lastDate = defaults.object(forKey: streakDateKey) as? Date {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            
            if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                let currentStreak = defaults.integer(forKey: streakCountKey)
                let newStreak = currentStreak + 1
                defaults.set(newStreak, forKey: streakCountKey)
                
                let bestStreak = defaults.integer(forKey: bestStreakKey)
                if newStreak > bestStreak {
                    defaults.set(newStreak, forKey: bestStreakKey)
                }
            } else if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
                defaults.set(1, forKey: streakCountKey)
            }
        } else {
            defaults.set(1, forKey: streakCountKey)
            defaults.set(1, forKey: bestStreakKey)
        }
        
        defaults.set(today, forKey: streakDateKey)
    }
    
    func getCurrentStreak(userId: String) -> Int {
        let streakCountKey = key("current_streak", for: userId)
        let streakDateKey = key("last_streak_date", for: userId)
        
        if let lastDate = defaults.object(forKey: streakDateKey) as? Date {
            let today = Calendar.current.startOfDay(for: Date())
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            
            if !Calendar.current.isDate(lastDate, inSameDayAs: today) &&
               !Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                defaults.set(0, forKey: streakCountKey)
                return 0
            }
        }
        
        return defaults.integer(forKey: streakCountKey)
    }
    
    func getBestStreak(userId: String) -> Int {
        return defaults.integer(forKey: key("best_streak", for: userId))
    }
    
    // MARK: - Task Statistics
    func incrementTasksCompleted(userId: String) {
        checkAndResetMonthlyStats(userId: userId)
        let key = self.key("tasks_completed", for: userId)
        let newValue = defaults.integer(forKey: key) + 1
        defaults.set(newValue, forKey: key)
    }
    
    func getTasksCompleted(userId: String) -> Int {
        checkAndResetMonthlyStats(userId: userId)
        return defaults.integer(forKey: self.key("tasks_completed", for: userId))
    }
    
    // MARK: - Feature Usage Statistics
    func incrementPomodoroSessions(userId: String) {
        checkAndResetMonthlyStats(userId: userId)
        let key = self.key("pomodoro_sessions", for: userId)
        let newValue = defaults.integer(forKey: key) + 1
        defaults.set(newValue, forKey: key)
    }
    
    func incrementMeditationSessions(userId: String) {
        checkAndResetMonthlyStats(userId: userId)
        let key = self.key("meditation_sessions", for: userId)
        let newValue = defaults.integer(forKey: key) + 1
        defaults.set(newValue, forKey: key)
    }
    
    func incrementQuotesViewed(userId: String) {
        checkAndResetMonthlyStats(userId: userId)
        let key = self.key("quotes_viewed", for: userId)
        let newValue = defaults.integer(forKey: key) + 1
        defaults.set(newValue, forKey: key)
    }
    
    // MARK: - Get Statistics
    func getPomodoroSessions(userId: String) -> Int {
        checkAndResetMonthlyStats(userId: userId)
        return defaults.integer(forKey: self.key("pomodoro_sessions", for: userId))
    }
    
    func getMeditationSessions(userId: String) -> Int {
        checkAndResetMonthlyStats(userId: userId)
        return defaults.integer(forKey: self.key("meditation_sessions", for: userId))
    }
    
    func getQuotesViewed(userId: String) -> Int {
        checkAndResetMonthlyStats(userId: userId)
        return defaults.integer(forKey: self.key("quotes_viewed", for: userId))
    }
    
    // MARK: - Reset All Statistics
    func resetAllStats(userId: String) {
        let keysToReset = [
            "current_streak",
            "best_streak",
            "tasks_completed",
            "pomodoro_sessions",
            "meditation_sessions",
            "quotes_viewed"
        ]
        
        for keyType in keysToReset {
            defaults.removeObject(forKey: key(keyType, for: userId))
        }
    }
}
