//
//  AuthPogingBegrenzer.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import Foundation

class AuthAttemptLimiter {
    static let shared = AuthAttemptLimiter()
    private var attempts: [String: [Date]] = [:]
    private let maxAttempts = 5
    private let timeWindow: TimeInterval = 300 // 5 minutes
    
    func canAttempt(for identifier: String) -> Bool {
        let now = Date()
        let recentAttempts = attempts[identifier, default: []]
            .filter { now.timeIntervalSince($0) < timeWindow }
        
        attempts[identifier] = recentAttempts
        
        if recentAttempts.count >= maxAttempts {
            return false
        }
        
        attempts[identifier, default: []].append(now)
        return true
    }
    
    func resetAttempts(for identifier: String) {
        attempts[identifier] = []
    }
}
