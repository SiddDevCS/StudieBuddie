//
//  Bundle+Language.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 19/03/2025.
//

import Foundation

extension Bundle {
    private static var bundle: Bundle?
    
    static func setLanguage(_ language: Language) {
        let bundlePath = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
        print("Main bundle path: \(Bundle.main.bundlePath)")
        print("Available .lproj directories: \(Bundle.main.paths(forResourcesOfType: "lproj", inDirectory: nil))")
        print("Found language bundle path: \(bundlePath ?? "none")")
        
        guard let bundlePath = bundlePath,
              let languageBundle = Bundle(path: bundlePath) else {
            print("Failed to create bundle for language: \(language.rawValue)")
            return
        }
        
        bundle = languageBundle
        print("Successfully set language bundle for: \(language.rawValue)")
        
        // Debug the bundle contents
        let url = URL(fileURLWithPath: bundlePath)
        if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            print("Bundle contents: \(contents)")
            
            // Additional debug to check for Localizable.strings
            let stringsFiles = contents.filter { $0.lastPathComponent == "Localizable.strings" }
            print("Found Localizable.strings files: \(stringsFiles)")
        }
    }
    
    static func localizedString(forKey key: String) -> String {
        let defaultValue = NSLocalizedString(key, comment: "")
        guard let bundle = bundle else {
            print("Using main bundle for localization as language bundle is not set")
            return defaultValue
        }
        let localizedString = bundle.localizedString(forKey: key, value: defaultValue, table: nil)
        print("Localizing key: \(key) to: \(localizedString)")
        return localizedString
    }
}
