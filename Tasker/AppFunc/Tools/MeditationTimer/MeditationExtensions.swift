//
//  MeditationExtensions.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import Foundation

extension BackgroundSound {
    var icon: String {
        switch self {
        case .none: return "speaker.slash"
        case .rain: return "cloud.rain"
        case .waves: return "water.waves"
        case .whiteNoise: return "waveform"
        }
    }
}

extension GuidanceLevel {
    var icon: String {
        switch self {
        case .none: return "person.fill.xmark"
        case .minimal: return "person.fill.checkmark"
        case .full: return "person.2.fill"
        }
    }
}

extension Int {
    var formattedInterval: String {
        if self >= 60 {
            return "\(self/60)m"
        }
        return "\(self)s"
    }
}
