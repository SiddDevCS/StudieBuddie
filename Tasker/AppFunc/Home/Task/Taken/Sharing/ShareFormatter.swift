//
//  ShareFormatter.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import Foundation

struct ShareFormatter {
    static func formatTodo(_ todo: TodoItem, in category: Category) -> String {
        var text = "📝 \(Bundle.localizedString(forKey: "Task")): \(todo.title)\n"
        text += "📁 \(Bundle.localizedString(forKey: "Category")): \(category.name)\n"
        
        if let subject = category.subject {
            text += "📚 \(Bundle.localizedString(forKey: "Subject")): \(subject.name)\n"
        }
        
        if let deadline = todo.deadline {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            text += "⏰ \(Bundle.localizedString(forKey: "Deadline")): \(formatter.string(from: deadline))\n"
        }
        
        if let priority = todo.priority {
            text += "🚨 \(Bundle.localizedString(forKey: "Priority")): \(priority.localizedName)\n"
        }
        
        text += "\n\(Bundle.localizedString(forKey: "Shared via Tasker App"))"
        return text
    }
    
    static func formatCategory(_ category: Category) -> String {
        var text = "📁 \(Bundle.localizedString(forKey: "Category")): \(category.name)\n"
        
        if let subject = category.subject {
            text += "📚 \(Bundle.localizedString(forKey: "Subject")): \(subject.name)\n"
        }
        
        text += "📝 \(Bundle.localizedString(forKey: "Tasks")) (\(category.todos.count)):\n\n"
        
        for (index, todo) in category.todos.enumerated() {
            text += "\(index + 1). \(todo.title)"
            
            if let deadline = todo.deadline {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                text += "\n   ⏰ \(formatter.string(from: deadline))"
            }
            
            if let priority = todo.priority {
                text += "\n   🚨 \(priority.rawValue)"
            }
            
            if todo.isCompleted {
                text += "\n   ✅ Afgerond"
            }
            
            text += "\n\n"
        }
        
        text += "\(Bundle.localizedString(forKey: "Shared via Tasker App"))"
        return text
    }
}
