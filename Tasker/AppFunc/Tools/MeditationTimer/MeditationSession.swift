//
//  MeditationSession.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import Foundation
import FirebaseFirestore

struct MeditationSession: Codable, Identifiable {
    let id: String
    let userId: String
    let date: Date
    let duration: Int
    let type: String // Store as String instead of MeditationType
    let rating: Int?
    let notes: String?
    let breathingPattern: String? // Store as String instead of BreathingPattern
    
    init(id: String = UUID().uuidString,
         userId: String,
         date: Date = Date(),
         duration: Int,
         type: MeditationType,
         rating: Int? = nil,
         notes: String? = nil,
         breathingPattern: BreathingPattern? = nil) {
        self.id = id
        self.userId = userId
        self.date = date
        self.duration = duration
        self.type = type.rawValue
        self.rating = rating
        self.notes = notes
        self.breathingPattern = breathingPattern?.rawValue
    }
    
    // Add coding keys to handle Date encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case date
        case duration
        case type
        case rating
        case notes
        case breathingPattern
    }
    
    // Custom encoding for Date
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(type, forKey: .type)
        try container.encode(rating, forKey: .rating)
        try container.encode(notes, forKey: .notes)
        try container.encode(breathingPattern, forKey: .breathingPattern)
    }
    
    // Custom decoding for Date
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        let timestamp = try container.decode(Double.self, forKey: .date)
        date = Date(timeIntervalSince1970: timestamp)
        duration = try container.decode(Int.self, forKey: .duration)
        type = try container.decode(String.self, forKey: .type)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        breathingPattern = try container.decodeIfPresent(String.self, forKey: .breathingPattern)
    }
}

// Helper methods to convert between String and Enum types
extension MeditationSession {
    var meditationType: MeditationType {
        return MeditationType(rawValue: type) ?? .meditation
    }
    
    var breathingPatternType: BreathingPattern? {
        guard let pattern = breathingPattern else { return nil }
        return BreathingPattern(rawValue: pattern)
    }
}
