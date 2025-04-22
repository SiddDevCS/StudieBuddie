//
//  ChatMessage.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/02/2025.
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: String = UUID().uuidString, content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.content == rhs.content &&
               lhs.isUser == rhs.isUser &&
               lhs.timestamp == rhs.timestamp
    }
}
