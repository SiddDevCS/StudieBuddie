//
//  ToDoItem.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 18/01/2025.
//

import Foundation

struct TodoItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var isCompleted: Bool
    var details: String?
    // Add any other properties you have
}
