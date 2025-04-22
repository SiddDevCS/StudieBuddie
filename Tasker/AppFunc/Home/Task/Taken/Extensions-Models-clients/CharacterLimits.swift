//
//  CharacterLimits.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import Foundation

enum CharacterLimits {
    // Categories and Tasks
    static let categoryName = 30      // Keep this shorter for better UI
    static let todoTitle = 100        // Good length for detailed task names
    
    // Lessons and Schedule
    static let lessonTitle = 50       // Good length for class names
    
    // Study Goals
    static let studiedoelTitel = 50        // Consistent with other titles
    static let studiedoelOmschrijving = 500  // Good length for detailed descriptions
    
    // Notes
    static let notesField = 1000      // Plenty of space for detailed notes
    // Remove these as they're duplicates or unused
    // static let goalTitle = 100      // Duplicate of todoTitle
    // static let categoryTitle = 50   // Use categoryName instead
}

