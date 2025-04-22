//
//  RoosterEntry.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import Foundation

struct RoosterEntry: Identifiable {
    let id: String
    let title: String
    let startTime: Date
    let endTime: Date
    let color: String
    let teacher: String?
    let room: String?
    let description: String?
    let calendarEventId: String?
    let isRecurring: Bool
    let recurrenceRule: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        startTime: Date,
        endTime: Date,
        color: String = "#FF9500",
        teacher: String? = nil,
        room: String? = nil,
        description: String? = nil,
        calendarEventId: String? = nil,
        isRecurring: Bool = false,
        recurrenceRule: String? = nil
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.teacher = teacher
        self.room = room
        self.description = description
        self.calendarEventId = calendarEventId
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
    }
}
