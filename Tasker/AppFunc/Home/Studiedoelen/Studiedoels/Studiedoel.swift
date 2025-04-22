//
//  Studiedoel.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 14/02/2025.
//

import Foundation

struct Studiedoel: Identifiable, Codable {
    var id: String?
    var title: String           // Changed from let to var
    var description: String     // Changed from let to var
    var deadline: Date         // Changed from let to var
    var subject: SchoolSubject?
    var isCompleted: Bool
    var dateCreated: Date      // Changed from let to var
    var currentGrade: Double?  // Changed from let to var
    var targetGrade: Double?   // Changed from let to var
    
    init(id: String? = nil,
         title: String,
         description: String,
         deadline: Date,
         subject: SchoolSubject? = nil,
         isCompleted: Bool = false,
         dateCreated: Date = Date(),
         currentGrade: Double? = nil,
         targetGrade: Double? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.deadline = deadline
        self.subject = subject
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.currentGrade = currentGrade
        self.targetGrade = targetGrade
    }
}

// Extension remains the same
extension Studiedoel {
    func asDictionary() throws -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "description": description,
            "deadline": deadline,
            "isCompleted": isCompleted,
            "dateCreated": dateCreated,
            "currentGrade": currentGrade as Any,
            "targetGrade": targetGrade as Any
        ]
        
        if let subject = subject {
            dict["subject"] = [
                "id": subject.id,
                "name": subject.name,
                "icon": subject.icon,
                "color": subject.color
            ]
        }
        
        return dict
    }
}
