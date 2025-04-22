//
//  Subject.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 14/02/2025.
//

import Foundation
import SwiftUI

struct SchoolSubject: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let color: String
    
    init(id: String = UUID().uuidString,
         name: String,
         icon: String = "book.fill",
         color: String = "orange") {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
    
    var uiColor: Color {
        switch color {
        case "orange": return .orange
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "mint": return .mint
        case "purple": return .purple
        case "indigo": return .indigo
        case "teal": return .teal
        case "brown": return .brown
        case "cyan": return .cyan
        default: return .orange
        }
    }
    
    // Change from static let to static var and make it a computed property
    static var subjects: [SchoolSubject] {
        [
            // Languages
            SchoolSubject(name: Bundle.localizedString(forKey: "Dutch"), icon: "text.book.closed", color: "red"),
            SchoolSubject(name: Bundle.localizedString(forKey: "English"), icon: "globe.europe.africa", color: "blue"),
            SchoolSubject(name: Bundle.localizedString(forKey: "French"), icon: "flag.fill", color: "indigo"),
            SchoolSubject(name: Bundle.localizedString(forKey: "German"), icon: "flag.fill", color: "orange"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Spanish"), icon: "flag.fill", color: "purple"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Latin"), icon: "scroll", color: "brown"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Greek"), icon: "building.columns", color: "cyan"),
            
            // STEM
            SchoolSubject(name: Bundle.localizedString(forKey: "Mathematics"), icon: "function", color: "blue"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Physics"), icon: "atom", color: "purple"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Chemistry"), icon: "flask", color: "green"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Biology"), icon: "leaf", color: "mint"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Computer Science"), icon: "desktopcomputer", color: "teal"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Technology"), icon: "wrench.and.screwdriver", color: "orange"),
            
            // Social Studies
            SchoolSubject(name: Bundle.localizedString(forKey: "History"), icon: "clock.fill", color: "brown"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Geography"), icon: "globe.americas", color: "green"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Economics"), icon: "chart.line.uptrend.xyaxis", color: "blue"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Social Studies"), icon: "person.3", color: "purple"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Philosophy"), icon: "brain.head.profile", color: "indigo"),
            
            // Arts
            SchoolSubject(name: Bundle.localizedString(forKey: "Drawing"), icon: "paintbrush.fill", color: "red"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Arts and Crafts"), icon: "hand.draw", color: "orange"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Music"), icon: "music.note", color: "purple"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Drama"), icon: "theatermasks", color: "cyan"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Cultural Arts"), icon: "paintpalette", color: "mint"),
            
            // Physical Education & Health
            SchoolSubject(name: Bundle.localizedString(forKey: "Physical Education"), icon: "figure.run", color: "green"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Health Care"), icon: "heart.fill", color: "red"),
            
            // Vocational
            SchoolSubject(name: Bundle.localizedString(forKey: "Business Economics"), icon: "building.2", color: "blue"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Management & Organization"), icon: "person.2.circle", color: "purple"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Care"), icon: "cross.case", color: "mint"),
            
            // Other
            SchoolSubject(name: Bundle.localizedString(forKey: "Religion"), icon: "book.closed", color: "indigo"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Life Philosophy"), icon: "sun.max", color: "orange"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Study Skills"), icon: "book.closed", color: "teal"),
            SchoolSubject(name: Bundle.localizedString(forKey: "Mentoring"), icon: "person.circle", color: "blue")
        ]
    }
}
