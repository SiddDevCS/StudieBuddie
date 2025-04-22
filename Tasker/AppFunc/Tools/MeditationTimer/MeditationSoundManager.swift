//
//  MeditationSoundManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

//
//  MeditationSoundManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import AVFoundation
import SwiftUI

class MeditationSoundManager {
    static let shared = MeditationSoundManager()
    private var audioPlayer: AVAudioPlayer?
    private var volume: Float = 0.5
    private var timer: Timer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
            
            // Add notification observer for audio interruptions
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleInterruption),
                name: AVAudioSession.interruptionNotification,
                object: session)
            
            // Add notification observer for route changes
            NotificationCenter.default.addObserver(self,
                selector: #selector(handleRouteChange),
                name: AVAudioSession.routeChangeNotification,
                object: session)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session interrupted, pause playback
            audioPlayer?.pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended, resume playback
                audioPlayer?.play()
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Audio output device was removed, pause playback
            audioPlayer?.pause()
        default:
            break
        }
    }
    
    func playBackgroundSound(_ sound: BackgroundSound, duration: TimeInterval) {
        guard sound != .none else {
            stopSound()
            return
        }
        
        let filename: String
        switch sound {
        case .none:
            return
        case .rain:
            filename = "meditation_rain"
        case .waves:
            filename = "meditation_waves"
        case .whiteNoise:
            filename = "meditation_whitenoise"
        }
        
        guard let path = Bundle.main.path(forResource: filename, ofType: "mp3") else {
            print("Could not find sound file: \(filename)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            stopSound()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 0 // Start with volume 0
            audioPlayer?.prepareToPlay() // Prepare the audio for playback
            audioPlayer?.play()
            
            // Gradually increase volume
            DispatchQueue.main.async {
                withAnimation(.easeIn(duration: 2.0)) {
                    self.audioPlayer?.volume = self.volume
                }
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: duration - 2.0, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 2.0)) {
                        self?.audioPlayer?.volume = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.stopSound()
                }
            }
            
        } catch {
            print("Could not create audio player: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func playBellSound() {
        guard let bellURL = Bundle.main.url(forResource: "meditation-bell", withExtension: "mp3") else {
            print("Could not find bell sound file")
            return
        }
        
        do {
            // Create a separate player for the bell sound
            let bellPlayer = try AVAudioPlayer(contentsOf: bellURL)
            bellPlayer.volume = volume
            bellPlayer.prepareToPlay()
            bellPlayer.play()
        } catch {
            print("Could not play bell sound: \(error.localizedDescription)")
        }
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        audioPlayer?.volume = volume
    }
    
    func pauseSound() {
        audioPlayer?.pause()
    }
    
    func resumeSound() {
        audioPlayer?.play()
    }
    
    deinit {
        stopSound()
        NotificationCenter.default.removeObserver(self)
    }
}
