//
//  SoundManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    enum SoundType {
        case timerStart
        case timerEnd
        
        var filename: String {
            switch self {
            case .timerStart: return "timer_start"
            case .timerEnd: return "timer_end"
            }
        }
    }
    
    func playSound(_ type: SoundType) {
        print("Attempting to play sound: \(type.filename)")
        
        guard let soundURL = Bundle.main.url(forResource: type.filename, withExtension: "mp3") else {
            print("❌ Sound file not found: \(type.filename).mp3")
            return
        }
        
        print("Found sound file at: \(soundURL)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
            print("✅ Playing sound: \(type.filename)")
        } catch {
            print("❌ Error playing sound: \(error.localizedDescription)")
        }
    }
}
