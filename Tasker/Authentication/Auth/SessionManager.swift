//
//  SessionManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import Foundation
import FirebaseAuth

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    @Published private(set) var isSessionValid = false
    private let sessionTimeout: TimeInterval = 3600 // 1 hour
    private var sessionTimer: Timer?
    
    func startSession() {
        isSessionValid = true
        resetSessionTimer()
    }
    
    private func resetSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: sessionTimeout, repeats: false) { [weak self] _ in
            self?.endSession()
        }
    }
    
    func endSession() {
        isSessionValid = false
        sessionTimer?.invalidate()
        sessionTimer = nil
        try? Auth.auth().signOut()
    }
}
