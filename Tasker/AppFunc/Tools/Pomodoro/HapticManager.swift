//
//  HapticManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        // Pre-prepare the generators for better first-time response
        lightFeedback.prepare()
        mediumFeedback.prepare()
        heavyFeedback.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    enum HapticType {
        case start
        case stop
        case reset
        case skip
        case success
        case warning
        case error
        case selection
        case tick
    }
    
    func play(_ type: HapticType) {
        switch type {
        case .start:
            mediumFeedback.impactOccurred()
            
        case .stop:
            lightFeedback.impactOccurred()
            
        case .reset:
            heavyFeedback.impactOccurred()
            
        case .skip:
            // Double tap feeling
            lightFeedback.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.lightFeedback.impactOccurred()
            }
            
        case .success:
            notificationFeedback.notificationOccurred(.success)
            
        case .warning:
            notificationFeedback.notificationOccurred(.warning)
            
        case .error:
            notificationFeedback.notificationOccurred(.error)
            
        case .selection:
            selectionFeedback.selectionChanged()
            
        case .tick:
            // Subtle tick for time passing
            let softFeedback = UIImpactFeedbackGenerator(style: .soft)
            softFeedback.impactOccurred(intensity: 0.5)
        }
    }
    
    // For continuous feedback during gestures or animations
    func prepareFeedback() {
        lightFeedback.prepare()
        mediumFeedback.prepare()
        heavyFeedback.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }
}

// MARK: - Usage Examples
extension HapticManager {
    func playTimerInteractions() {
        // When timer starts
        play(.start)
        
        // When timer stops
        play(.stop)
        
        // When timer completes
        play(.success)
        
        // When there's a warning (like low battery while timer is running)
        play(.warning)
        
        // When there's an error (like failed to start timer)
        play(.error)
        
        // When user makes a selection
        play(.selection)
        
        // When timer is reset
        play(.reset)
        
        // When interval is skipped
        play(.skip)
    }
}
