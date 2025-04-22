//
//  Category.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import Foundation
import FirebaseFirestore

struct Category: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var todos: [TodoItem]
    var subject: SchoolSubject?
    
    init(name: String, todos: [TodoItem] = [], subject: SchoolSubject? = nil) {
        self.name = name
        self.todos = todos
        self.subject = subject
    }
    
    init(id: String?, name: String, todos: [TodoItem] = [], subject: SchoolSubject? = nil) {
        self.id = id
        self.name = name
        self.todos = todos
        self.subject = subject
    }
}
