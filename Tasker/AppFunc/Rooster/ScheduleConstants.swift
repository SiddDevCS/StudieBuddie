//
//  ScheduleConstants.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation

// Create this as a new file
enum ScheduleConstants {
    enum ViewMode: String {
        case day = "Dag"
        case week = "Week"
    }
    
    enum Labels {
        static let schedule = "Rooster"
        static let today = "Vandaag"
        static let noLessons = "Geen lessen"
        
        enum Time {
            static let morning = "Ochtend"
            static let afternoon = "Middag"
            static let evening = "Avond"
        }
    }
    
    enum TimeSlots {
        static let morning = 0..<12    // 00:00 - 11:59
        static let afternoon = 12..<17  // 12:00 - 16:59
        static let evening = 17..<24    // 17:00 - 23:59
    }
}
