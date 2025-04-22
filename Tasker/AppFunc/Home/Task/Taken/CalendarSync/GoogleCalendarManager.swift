//
//  GoogleCalendarManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import GoogleSignIn
import GoogleAPIClientForREST_Calendar
import UIKit

class GoogleCalendarManager {
    static let shared = GoogleCalendarManager()
    
    private var calendarService: GTLRCalendarService?
    
    var isSignedIn: Bool {
        return GIDSignIn.sharedInstance.currentUser != nil
    }
    
    init() {
        setupCalendarService()
    }
    
    private func setupCalendarService() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            let service = GTLRCalendarService()
            service.authorizer = user.fetcherAuthorizer
            calendarService = service
            print("Calendar service setup successfully")
        } else {
            print("Failed to setup calendar service - no signed in user")
        }
    }
    
    func signIn(presenting viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let config = GIDConfiguration(clientID: "676996401002-v6874sl066bfk928jirqrjsfcn230vu9.apps.googleusercontent.com")
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: viewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/calendar"]
        ) { [weak self] result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            self?.setupCalendarService()
            completion(true)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        calendarService = nil
    }
    
    func syncTimeTableEntryToCalendar(
        entry: RoosterEntry,
        recurrenceRule: String? = nil,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let service = calendarService else {
                print("Calendar service not available")
                completion(false, nil)
                return
            }
            
            let event = GTLRCalendar_Event()
            event.summary = entry.title
            event.descriptionProperty = entry.description
            
            let startDateTime = GTLRDateTime(date: entry.startTime)
            let endDateTime = GTLRDateTime(date: entry.endTime)
            
            let startEventDateTime = GTLRCalendar_EventDateTime()
            startEventDateTime.dateTime = startDateTime
            startEventDateTime.timeZone = TimeZone.current.identifier
            event.start = startEventDateTime
            
            let endEventDateTime = GTLRCalendar_EventDateTime()
            endEventDateTime.dateTime = endDateTime
            endEventDateTime.timeZone = TimeZone.current.identifier
            event.end = endEventDateTime
            
            event.colorId = convertHexToGoogleCalendarColor(entry.color)
        
        if let recurrenceRule = recurrenceRule {
                event.recurrence = [recurrenceRule]
            }
        
        // If we have an existing calendar event ID, update it instead of creating new
        if let existingEventId = entry.calendarEventId {
            let query = GTLRCalendarQuery_EventsUpdate.query(withObject: event, calendarId: "primary", eventId: existingEventId)
            
            service.executeQuery(query) { (_, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error updating calendar event: \(error.localizedDescription)")
                        completion(false, nil)
                    } else if let updatedEvent = response as? GTLRCalendar_Event {
                        completion(true, updatedEvent.identifier)
                    } else {
                        completion(false, nil)
                    }
                }
            }
        } else {
            // Create new event
            let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
            
            service.executeQuery(query) { (_, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error creating calendar event: \(error.localizedDescription)")
                        completion(false, nil)
                    } else if let newEvent = response as? GTLRCalendar_Event {
                        completion(true, newEvent.identifier)
                    } else {
                        completion(false, nil)
                    }
                }
            }
        }
    }
    
    func deleteCalendarEvent(eventId: String, completion: @escaping (Bool) -> Void) {
        guard let service = calendarService else {
            completion(false)
            return
        }
        
        let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: eventId)
        
        service.executeQuery(query) { (_, response, error) in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }
    
    private func convertHexToGoogleCalendarColor(_ hex: String) -> String {
        switch hex {
        case "#FF9500": return "6"  // Orange -> Tangerine
        case "#FF2D55": return "11" // Red -> Tomato
        case "#5856D6": return "9"  // Purple -> Blueberry
        case "#34C759": return "2"  // Green -> Sage
        case "#007AFF": return "7"  // Blue -> Peacock
        default: return "1"         // Default -> Lavender
        }
    }
    
    func syncTodoToCalendar(
        todo: TodoItem,
        category: Category,
        startTime: Date,
        endTime: Date,
        description: String,
        location: String,
        colorId: String,
        reminder: ReminderTime,
        completion: @escaping (Bool) -> Void
    ) {
        guard let service = calendarService else {
            print("Calendar service not available")
            completion(false)
            return
        }
        
        let event = GTLRCalendar_Event()
        event.summary = todo.title
        event.descriptionProperty = description
        event.location = location.isEmpty ? nil : location
        event.colorId = colorId
        
        let description = "Category: \(category.name)"
        event.descriptionProperty = description
        
        let startDateTime = GTLRDateTime(date: startTime)
        let endDateTime = GTLRDateTime(date: endTime)
        
        let startEventDateTime = GTLRCalendar_EventDateTime()
        startEventDateTime.dateTime = startDateTime
        startEventDateTime.timeZone = TimeZone.current.identifier
        event.start = startEventDateTime
        
        let endEventDateTime = GTLRCalendar_EventDateTime()
        endEventDateTime.dateTime = endDateTime
        endEventDateTime.timeZone = TimeZone.current.identifier
        event.end = endEventDateTime
        
        event.colorId = "1"
        
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
        
        print("Creating calendar event: \(todo.title) at \(startTime)")
        
        service.executeQuery(query) { (_, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error creating calendar event: \(error.localizedDescription)")
                    completion(false)
                } else if let createdEvent = response as? GTLRCalendar_Event {
                    print("Successfully created event with ID: \(createdEvent.identifier ?? "unknown")")
                    completion(true)
                } else {
                    print("Unknown error creating calendar event")
                    completion(false)
                }
            }
        }
    }
}
