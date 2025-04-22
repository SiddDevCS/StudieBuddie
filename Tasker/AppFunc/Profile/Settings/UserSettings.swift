//
//  UserSettings.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/01/2025.
//

import Foundation

// First, define the Language enum with Codable conformance
enum Language: String, Codable, CaseIterable {
    case english = "en"
    case dutch = "nl"
    case spanish = "es"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .dutch: return "Nederlands"
        case .spanish: return "Español"
        case .french: return "Français"
        }
    }
}

class UserSettings: ObservableObject, Codable {
    @Published var notificationPreferences: NotificationPreferences
    @Published var hasCompletedTutorial: Bool
    @Published var profileImageURL: String?
    @Published var selectedLanguage: Language
    
    struct NotificationPreferences: Codable {
        var dueTasks: Bool
        var dueGoals: Bool
        var timetables: Bool
        var timers: Bool
        var randomReminders: RandomReminders
        
        struct RandomReminders: Codable {
            var enabled: Bool
            var meditation: Bool
            var appEngagement: Bool
        }
        
        static let `default` = NotificationPreferences(
            dueTasks: true,
            dueGoals: true,
            timetables: true,
            timers: true,
            randomReminders: RandomReminders(
                enabled: true,
                meditation: true,
                appEngagement: true
            )
        )
    }
    
    static let `default` = UserSettings()
    
    enum CodingKeys: CodingKey {
        case notificationPreferences
        case hasCompletedTutorial
        case profileImageURL
        case selectedLanguage
    }
    
    init() {
        self.notificationPreferences = .default
        self.hasCompletedTutorial = false
        self.profileImageURL = nil
        self.selectedLanguage = .english
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notificationPreferences = try container.decode(NotificationPreferences.self, forKey: .notificationPreferences)
        hasCompletedTutorial = try container.decode(Bool.self, forKey: .hasCompletedTutorial)
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        selectedLanguage = try container.decode(Language.self, forKey: .selectedLanguage)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(notificationPreferences, forKey: .notificationPreferences)
        try container.encode(hasCompletedTutorial, forKey: .hasCompletedTutorial)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encode(selectedLanguage, forKey: .selectedLanguage)
    }
    
    func resetToDefaults() {
        notificationPreferences = .default
        hasCompletedTutorial = false
        profileImageURL = nil
        selectedLanguage = .english
    }
}
