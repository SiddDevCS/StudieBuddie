//
//  PomodoroViewModel.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import Foundation
import UserNotifications
import UIKit

class PomodoroViewModel: ObservableObject {
    // MARK: - Constants
    private let maxWorkMinutes = 120
    private let maxBreakMinutes = 60
    private let defaults = UserDefaults.standard
    private let timerEndDateKey = "pomodoro.timerEndDate"
    private let timerTypeKey = "pomodoro.timerType"
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Published Properties
    @Published var isRunning = false {
        didSet {
            if isRunning {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    @Published var isWorkTime = true
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var progress: Double = 1.0
    @Published var workMinutes: Int = 25
    @Published var breakMinutes: Int = 5
    @Published var sessionCompleted = false
    @Published var isCustomTime = false
    @Published var customWorkMinutes: Int = 25
    @Published var customBreakMinutes: Int = 5
    @Published var todaysSessions: Int = 0
    @Published var totalFocusTime: TimeInterval = 0
    @Published var currentStreak: Int = 0
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var startTime: Date?
    private var lastUpdateTime: Date?
    private var focusStartTime: Date?
    
    // MARK: - Computed Properties
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var endTimeFormatted: String {
        guard isRunning else { return "" }
        let endTime = Date().addingTimeInterval(timeRemaining)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    var totalFocusTimeFormatted: String {
        let hours = Int(totalFocusTime) / 3600
        let minutes = Int(totalFocusTime) % 3600 / 60
        if hours > 0 {
            return "\(hours)u \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private var sanitizedCustomWorkMinutes: Int {
        min(max(customWorkMinutes, 1), maxWorkMinutes)
    }
    
    private var sanitizedCustomBreakMinutes: Int {
        min(max(customBreakMinutes, 1), maxBreakMinutes)
    }
    
    // MARK: - Initialization
    init() {
        setupInitialState()
    }
    
    private func setupInitialState() {
        requestNotificationPermission()
        loadStatistics()
        restoreState()
    }
    
    // MARK: - Timer Management
    func startTimer() {
        startTime = Date()
        lastUpdateTime = startTime
        
        if isWorkTime {
            focusStartTime = Date()
        }
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        scheduleBackgroundNotification()
        HapticManager.shared.play(.start)
        SoundManager.shared.playSound(.timerStart)
    }
    
    func stopTimer() {
        if isWorkTime, let startTime = focusStartTime {
            totalFocusTime += Date().timeIntervalSince(startTime)
            saveFocusTime()
        }
        
        timer?.invalidate()
        timer = nil
        startTime = nil
        lastUpdateTime = nil
        focusStartTime = nil
        endBackgroundTask()
        saveState()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        defaults.removeObject(forKey: timerEndDateKey)
        defaults.removeObject(forKey: timerTypeKey)
        
        HapticManager.shared.play(.stop)
    }
    
    func resetTimer() {
        stopTimer()
        let minutes = isWorkTime ?
        (isCustomTime ? sanitizedCustomWorkMinutes : workMinutes) :
        (isCustomTime ? sanitizedCustomBreakMinutes : breakMinutes)
        timeRemaining = Double(minutes) * 60
        progress = 1.0
        isRunning = false
        sessionCompleted = false
        saveState()
        
        HapticManager.shared.play(.reset)
    }
    
    func skipInterval() {
        intervalComplete()
        HapticManager.shared.play(.skip)
    }
    
    // MARK: - Timer Updates
    func updateTimer() {
        guard isRunning else { return }
        
        let now = Date()
        
        if startTime == nil {
            startTime = now
        }
        
        if lastUpdateTime == nil {
            lastUpdateTime = now
        }
        
        let elapsed = now.timeIntervalSince(lastUpdateTime ?? now)
        timeRemaining -= elapsed
        lastUpdateTime = now
        
        if timeRemaining <= 0 {
            intervalComplete()
        } else {
            updateProgress()
        }
        
        saveState()
    }
    
    private func updateProgress() {
        let totalTime = isWorkTime ?
        (isCustomTime ? Double(sanitizedCustomWorkMinutes * 60) : Double(workMinutes * 60)) :
        (isCustomTime ? Double(sanitizedCustomBreakMinutes * 60) : Double(breakMinutes * 60))
        progress = timeRemaining / totalTime
    }
    
    // MARK: - Session Management
    private func intervalComplete() {
        if isWorkTime {
            if let startTime = focusStartTime {
                totalFocusTime += Date().timeIntervalSince(startTime)
                saveFocusTime()
            }
            incrementTodaysSessions()
            sessionCompleted = true
        }
        
        isWorkTime.toggle()
        resetTimer()
        
        HapticManager.shared.play(.success)
        SoundManager.shared.playSound(.timerEnd)
        saveState()
    }
    
    // MARK: - Statistics Management
    private func loadStatistics() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Load today's sessions
        if let lastSessionDate = defaults.object(forKey: "pomodoro.lastSessionDate") as? Date,
           calendar.isDate(lastSessionDate, inSameDayAs: today) {
            todaysSessions = defaults.integer(forKey: "pomodoro.todaysSessions")
        } else {
            todaysSessions = 0
            defaults.set(today, forKey: "pomodoro.lastSessionDate")
            defaults.set(0, forKey: "pomodoro.todaysSessions")
        }
        
        // Load total focus time
        totalFocusTime = defaults.double(forKey: "pomodoro.totalFocusTime")
        
        // Load streak
        currentStreak = defaults.integer(forKey: "pomodoro.currentStreak")
        if let lastActiveDate = defaults.object(forKey: "pomodoro.lastActiveDate") as? Date {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if !calendar.isDate(lastActiveDate, inSameDayAs: yesterday) &&
               !calendar.isDate(lastActiveDate, inSameDayAs: today) {
                currentStreak = 0
            }
        }
    }
    
    private func incrementTodaysSessions() {
        todaysSessions += 1
        defaults.set(todaysSessions, forKey: "pomodoro.todaysSessions")
        
        // Update streak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let lastActiveDate = defaults.object(forKey: "pomodoro.lastActiveDate") as? Date {
            if !calendar.isDate(lastActiveDate, inSameDayAs: today) {
                currentStreak += 1
                defaults.set(currentStreak, forKey: "pomodoro.currentStreak")
            }
        } else {
            currentStreak = 1
            defaults.set(currentStreak, forKey: "pomodoro.currentStreak")
        }
        
        defaults.set(today, forKey: "pomodoro.lastActiveDate")
    }
    
    private func saveFocusTime() {
        defaults.set(totalFocusTime, forKey: "pomodoro.totalFocusTime")
    }
    
    // MARK: - State Management
    private func saveState() {
        defaults.set(isRunning, forKey: "pomodoro.isRunning")
        defaults.set(isWorkTime, forKey: "pomodoro.isWorkTime")
        defaults.set(timeRemaining, forKey: "pomodoro.timeRemaining")
        defaults.set(Date(), forKey: "pomodoro.lastSaveTime")
        
        if let focusStartTime = focusStartTime {
            defaults.set(focusStartTime, forKey: "pomodoro.focusStartTime")
        }
    }
    
    func restoreState() {
        // Check for interrupted timer
        if let endDate = defaults.object(forKey: timerEndDateKey) as? Date {
            let now = Date()
            if endDate > now {
                isWorkTime = defaults.bool(forKey: timerTypeKey)
                timeRemaining = endDate.timeIntervalSince(now)
                isRunning = true
                scheduleBackgroundNotification()
            } else {
                handleExpiredTimer()
            }
        }
        
        // Restore other state
        if let lastSaveTime = defaults.object(forKey: "pomodoro.lastSaveTime") as? Date {
            isWorkTime = defaults.bool(forKey: "pomodoro.isWorkTime")
            let savedTimeRemaining = defaults.double(forKey: "pomodoro.timeRemaining")
            let wasRunning = defaults.bool(forKey: "pomodoro.isRunning")
            
            if wasRunning {
                let elapsedTime = Date().timeIntervalSince(lastSaveTime)
                timeRemaining = max(0, savedTimeRemaining - elapsedTime)
                if timeRemaining > 0 {
                    isRunning = true
                    if let focusStartTime = defaults.object(forKey: "pomodoro.focusStartTime") as? Date {
                        self.focusStartTime = focusStartTime
                    }
                } else {
                    intervalComplete()
                }
            }
        }
    }
    
    private func handleExpiredTimer() {
        defaults.removeObject(forKey: timerEndDateKey)
        defaults.removeObject(forKey: timerTypeKey)
        
        let content = UNMutableNotificationContent()
        content.title = "Timer Verlopen"
        content.body = "Je timer is afgelopen terwijl de app gesloten was"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "timerExpired",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Notification Management
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func scheduleBackgroundNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = isWorkTime ? "Focus Sessie Voltooid!" : "Pauze Voorbij!"
        content.body = isWorkTime ? "Tijd voor een pauze!" : "Tijd om te focussen!"
        content.sound = .default
        
        let endDate = Date().addingTimeInterval(timeRemaining)
        defaults.set(endDate, forKey: timerEndDateKey)
        defaults.set(isWorkTime, forKey: timerTypeKey)
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeRemaining,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "timerComplete",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}
