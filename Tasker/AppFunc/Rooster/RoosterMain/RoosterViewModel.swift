//
//  RoosterViewModel.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation
import SwiftUI

@MainActor
class RoosterViewModel: ObservableObject {
    @Published var entries: [RoosterEntry] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let zermeloManager = ZermeloManager.shared
    private let firebaseManager = FirebaseManager.shared
    private let authManager = AuthManager.shared
    
    // For caching
    private var lastLoadedWeek: Date?
    private var lastLoadedEntries: [RoosterEntry] = []
    
    func loadSchedule(for week: Date) async {
        print("📅 Loading schedule for week of: \(week)")
        
        if let lastWeek = lastLoadedWeek,
           Calendar.current.isDate(lastWeek, equalTo: week, toGranularity: .weekOfYear) {
            print("📋 Using cached entries for this week")
            entries = lastLoadedEntries
            return
        }
        
        isLoading = true
        
        do {
            let calendar = Calendar.current
            let startOfWeek = calendar.startOfDay(for: calendar.startOfWeek(for: week))
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
            
            let start = Int(startOfWeek.timeIntervalSince1970)
            let end = Int(endOfWeek.timeIntervalSince1970)
            
            print("🔄 Fetching Zermelo appointments...")
            let appointments = try await zermeloManager.fetchSchedule(start: start, end: end)
            
            let zermeloEntries = appointments.map { appointment in
                RoosterEntry(
                    id: String(appointment.id),
                    title: appointment.subjects.first ?? "Onbekend",
                    startTime: Date(timeIntervalSince1970: TimeInterval(appointment.start)),
                    endTime: Date(timeIntervalSince1970: TimeInterval(appointment.end)),
                    color: getColorForSubject(appointment.subjects.first ?? ""),
                    teacher: appointment.teachers.first,
                    room: appointment.locations.first,
                    description: appointment.changeDescription.isEmpty ? nil : appointment.changeDescription,
                    isRecurring: false
                )
            }
            print("✅ Loaded \(zermeloEntries.count) Zermelo entries")
            
            let userId = authManager.currentUserId ?? ""
            print("👤 Fetching manual entries for user: \(userId)")
            let manualEntries = await firebaseManager.fetchRoosterEntries(userId: userId)
            print("✅ Loaded \(manualEntries.count) manual entries")
            
            let allEntries = (zermeloEntries + manualEntries).sorted { $0.startTime < $1.startTime }
            
            lastLoadedWeek = week
            lastLoadedEntries = allEntries
            entries = allEntries
            
            print("✅ Total entries loaded: \(allEntries.count)")
            
        } catch {
            self.error = error
            print("❌ Error loading schedule: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func addEntry(_ entry: RoosterEntry) {
        print("➕ Adding new entry: \(entry.title)")
        entries.append(entry)
        entries.sort { $0.startTime < $1.startTime }
        
        if let userId = authManager.currentUserId {
            print("💾 Saving to Firebase for user: \(userId)")
            firebaseManager.saveRoosterEntry(entry, userId: userId) { error in
                if let error = error {
                    print("❌ Error saving entry: \(error.localizedDescription)")
                } else {
                    print("✅ Entry saved successfully")
                }
            }
        } else {
            print("❌ No user ID available for saving entry")
        }
    }
    
    func updateEntry(_ entry: RoosterEntry) {
        print("🔄 Updating entry: \(entry.title)")
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            entries.sort { $0.startTime < $1.startTime }
            
            if let userId = authManager.currentUserId {
                print("💾 Saving updates to Firebase")
                firebaseManager.saveRoosterEntry(entry, userId: userId) { error in
                    if let error = error {
                        print("❌ Error updating entry: \(error.localizedDescription)")
                    } else {
                        print("✅ Entry updated successfully")
                    }
                }
            } else {
                print("❌ No user ID available for updating entry")
            }
        }
    }
    
    func deleteEntry(_ entry: RoosterEntry) {
        print("🗑️ Deleting entry: \(entry.title)")
        entries.removeAll { $0.id == entry.id }
        
        if let userId = authManager.currentUserId {
            print("🗑️ Removing from Firebase")
            firebaseManager.deleteRoosterEntry(userId: userId, entryId: entry.id)
            
            if let calendarEventId = entry.calendarEventId {
                print("🗑️ Removing from Google Calendar")
                GoogleCalendarManager.shared.deleteCalendarEvent(eventId: calendarEventId) { success in
                    if success {
                        print("✅ Calendar event deleted successfully")
                    } else {
                        print("❌ Failed to delete calendar event")
                    }
                }
            }
        } else {
            print("❌ No user ID available for deleting entry")
        }
    }
    
    private func getColorForSubject(_ subject: String) -> String {
        let colors = [
            "#FF9500", // Orange
            "#FF2D55", // Red
            "#5856D6", // Purple
            "#34C759", // Green
            "#007AFF", // Blue
            "#FF9EAC", // Pink
            "#BF5AF2", // Purple
            "#FFD60A"  // Yellow
        ]
        
        let index = abs(subject.hashValue) % colors.count
        return colors[index]
    }
}
