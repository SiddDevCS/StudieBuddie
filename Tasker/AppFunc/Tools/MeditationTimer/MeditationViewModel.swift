//
//  MeditationViewModel.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class MeditationViewModel: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var breathingProgress: Double = 0
    @Published var breathingPhase: BreathingPhase = .inhale
    @Published var phaseTimeRemaining: Double = 0
    @Published var sessionCompleted = false
    @Published var showingCompletionView = false
    @Published var settings = MeditationSettings()
    
    private var timer: Timer?
    private var breathingTimer: Timer?
    private var intervalTimer: Timer?
    private let soundManager = MeditationSoundManager.shared
    private var currentPhaseIndex = 0
    private var currentPattern: BreathingPattern?
    
    var timeRemainingText: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var currentSessionInfo: (duration: Int, type: MeditationType, pattern: BreathingPattern?) {
        let duration = (timeRemaining > 0 ? timeRemaining : 0) / 60
        return (duration, currentPattern != nil ? .breathing : .meditation, currentPattern)
    }
    
    // MARK: - Session Control
    func startSession(type: MeditationType, pattern: BreathingPattern?, duration: Int) {
        timeRemaining = duration
        currentPattern = pattern
        sessionCompleted = false
        
        if type == .breathing {
            startBreathingSession(pattern: pattern!)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func pauseSession() {
        timer?.invalidate()
        breathingTimer?.invalidate()
        intervalTimer?.invalidate()
        pauseBackgroundSound()
    }
    
    func resumeSession() {
        startSession(
            type: currentPattern != nil ? .breathing : .meditation,
            pattern: currentPattern,
            duration: timeRemaining
        )
        resumeBackgroundSound()
    }
    
    func stopSession() {
        timer?.invalidate()
        breathingTimer?.invalidate()
        intervalTimer?.invalidate()
        stopBackgroundSound()
        timeRemaining = 0
        breathingProgress = 0
        currentPhaseIndex = 0
        showingCompletionView = true
    }
    
    // MARK: - Timer Updates
    private func updateTimer() {
        guard timeRemaining > 0 else {
            completeSession()
            return
        }
        
        timeRemaining -= 1
    }
    
    private func completeSession() {
        timer?.invalidate()
        breathingTimer?.invalidate()
        intervalTimer?.invalidate()
        sessionCompleted = true
        showingCompletionView = true
        
        if settings.endBellEnabled {
            playBellSound()
        }
    }
    
    // MARK: - Breathing Control
    private func startBreathingSession(pattern: BreathingPattern) {
        let phases = pattern.phases
        currentPhaseIndex = 0
        updateBreathingPhase(phases: phases)
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateBreathing(phases: phases)
        }
    }
    
    private func updateBreathing(phases: [(BreathingPhase, Double)]) {
        guard currentPhaseIndex < phases.count else {
            currentPhaseIndex = 0
            updateBreathingPhase(phases: phases)
            return
        }
        
        let (_, duration) = phases[currentPhaseIndex]
        phaseTimeRemaining -= 0.1
        
        if phaseTimeRemaining <= 0 {
            currentPhaseIndex = (currentPhaseIndex + 1) % phases.count
            updateBreathingPhase(phases: phases)
        } else {
            breathingProgress = 1.0 - (phaseTimeRemaining / duration)
        }
    }
    
    private func updateBreathingPhase(phases: [(BreathingPhase, Double)]) {
        let (phase, duration) = phases[currentPhaseIndex]
        breathingPhase = phase
        phaseTimeRemaining = duration
        breathingProgress = 0
    }
    
    // MARK: - Interval Timer
    func startIntervalTimer() {
        guard settings.useInterval else { return }
        
        intervalTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(settings.intervalDuration), repeats: true) { [weak self] _ in
            self?.playBellSound()
        }
    }
    
    // MARK: - Sound Management
    func playBackgroundSound(_ sound: BackgroundSound) {
        print("Playing background sound: \(sound.rawValue)")
        soundManager.playBackgroundSound(sound, duration: Double(timeRemaining))
    }
    
    func stopBackgroundSound() {
        print("Stopping background sound")
        soundManager.stopSound()
    }
    
    func pauseBackgroundSound() {
        soundManager.pauseSound()
    }
    
    func resumeBackgroundSound() {
        soundManager.resumeSound()
    }
    
    func updateSoundVolume() {
        soundManager.setVolume(Float(settings.soundVolume))
    }
    
    private func playBellSound() {
        soundManager.playBellSound()
    }
    
    deinit {
        timer?.invalidate()
        breathingTimer?.invalidate()
        intervalTimer?.invalidate()
        stopBackgroundSound()
    }
}
