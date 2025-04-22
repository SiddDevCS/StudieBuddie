//
//  LanguageManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 19/03/2025.
//

import SwiftUI
import Foundation

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    private let defaults = UserDefaults.standard
    private let languageKey = "selectedLanguage"
    
    @Published var currentLanguage: Language = .english
    
    private init() {
        currentLanguage = getCurrentLanguage()
    }
    
    func getCurrentLanguage() -> Language {
        if let savedLanguage = defaults.string(forKey: languageKey) {
            return Language(rawValue: savedLanguage) ?? .english
        }
        return .english
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        defaults.set(language.rawValue, forKey: languageKey)
        Bundle.setLanguage(language)
    }
    
    func loadSavedLanguage() {
        let language = getCurrentLanguage()
        print("Loaded saved language: \(language.rawValue)")
        Bundle.setLanguage(language)
    }
}
