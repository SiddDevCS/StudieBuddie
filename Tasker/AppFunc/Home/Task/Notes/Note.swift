//
//  Note.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import Foundation

struct Note: Codable, Identifiable {
    var id: String
    var content: String
    var lastModified: Date
    
    init(id: String = UUID().uuidString, content: String = "", lastModified: Date = Date()) {
        self.id = id
        self.content = content
        self.lastModified = lastModified
    }
}
