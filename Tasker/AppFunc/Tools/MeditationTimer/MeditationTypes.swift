//
//  MeditationTypes.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import Foundation

enum MeditationType: String, Codable, CaseIterable {
    case meditation = "Meditation"
    case breathing = "Breathing"
    
    var localizedName: String {
        return Bundle.localizedString(forKey: self.rawValue)
    }
}

enum BackgroundSound: String, CaseIterable, Codable {
    case none = "None"
    case rain = "Rain"
    case waves = "Waves"
    case whiteNoise = "White Noise"
    
    var localizedName: String {
        return Bundle.localizedString(forKey: self.rawValue)
    }
}

enum GuidanceLevel: String, CaseIterable, Codable {
    case none = "None"
    case minimal = "Minimal"
    case full = "Full"
    
    var localizedName: String {
        return Bundle.localizedString(forKey: self.rawValue)
    }
}

enum MeditationFocus: String, CaseIterable, Codable {
    case mindfulness = "Mindfulness"
    case relaxation = "Relaxation"
    case stress = "Stress"
    case sleep = "Sleep"
    case energy = "Energy"
    
    var localizedName: String {
        return Bundle.localizedString(forKey: self.rawValue)
    }
    
    var localizedDescription: String {
        switch self {
        case .mindfulness:
            return Bundle.localizedString(forKey: "Focus on the present moment")
        case .relaxation:
            return Bundle.localizedString(forKey: "Relax body and mind")
        case .stress:
            return Bundle.localizedString(forKey: "Reduce stress and anxiety")
        case .sleep:
            return Bundle.localizedString(forKey: "Improve your sleep quality")
        case .energy:
            return Bundle.localizedString(forKey: "Increase your energy level")
        }
    }

    var recommendedDuration: Int {
        switch self {
        case .mindfulness: return 10
        case .relaxation: return 15
        case .stress: return 10
        case .sleep: return 20
        case .energy: return 5
        }
    }
}

enum BreathingPhase: String {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"
    case rest = "Rest"
    
    var localizedName: String {
        return Bundle.localizedString(forKey: self.rawValue)
    }
}

enum BreathingPattern: String, CaseIterable, Codable {
    case boxBreathing = "Box Breathing"
    case relaxingBreath = "Relaxing Breath"
    case energizingBreath = "Energizing Breath"
    
    var localizedName: String {
        return Bundle.localizedString(forKey: self.rawValue)
    }
    
    var localizedDescription: String {
        switch self {
        case .boxBreathing:
            return Bundle.localizedString(forKey: "4-4-4-4 pattern for focus and calm")
        case .relaxingBreath:
            return Bundle.localizedString(forKey: "4-7-8 pattern for deep relaxation")
        case .energizingBreath:
            return Bundle.localizedString(forKey: "Quick breathing for more energy")
        }
    }
    
    var phases: [(BreathingPhase, Double)] {
        switch self {
        case .boxBreathing:
            return [
                (.inhale, 4.0),
                (.hold, 4.0),
                (.exhale, 4.0),
                (.rest, 4.0)
            ]
        case .relaxingBreath:
            return [
                (.inhale, 4.0),
                (.hold, 7.0),
                (.exhale, 8.0),
                (.rest, 2.0)
            ]
        case .energizingBreath:
            return [
                (.inhale, 2.0),
                (.hold, 0.5),
                (.exhale, 2.0),
                (.rest, 0.5)
            ]
        }
    }
}

struct MeditationSettings: Codable {
    var focus: MeditationFocus = .mindfulness
    var backgroundSound: BackgroundSound = .none
    var soundVolume: Double = 0.5
    var guidanceLevel: GuidanceLevel = .minimal
    var useInterval: Bool = false
    var intervalDuration: Int = 60
    var endBellEnabled: Bool = true
}
