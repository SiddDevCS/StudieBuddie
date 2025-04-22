//
//  TodoItem.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TodoItem: Identifiable, Codable {
    var id: String
    var title: String
    var isCompleted: Bool
    var dateCreated: Date
    var deadline: Date?
    var priority: Priority?
    
    init(id: String = UUID().uuidString,
         title: String,
         isCompleted: Bool = false,
         dateCreated: Date = Date(),
         deadline: Date? = nil,
         priority: Priority? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.deadline = deadline
        self.priority = priority
    }
}

@available(iOS 16.0, *)
extension TodoItem: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .plainText) // Using built-in UTType
    }
}

@available(iOS 16.0, *)
extension Category: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .plainText) // Using built-in UTType
    }
}
