//
//  FirebaseManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 18/01/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    // Variables
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    // MARK: - Method's for Zermelo
    func fetchRoosterEntries(userId: String) async -> [RoosterEntry] {
        guard let currentUser = Auth.auth().currentUser else {
            print("⚠️ No authenticated user")
            return []
        }
        
        do {
            let snapshot = try await db.collection("users").document(currentUser.uid)
                .collection("rooster")
                .getDocuments()
            
            let entries = snapshot.documents.compactMap { document -> RoosterEntry? in
                let data = document.data()
                
                guard let title = data["title"] as? String,
                      let startTimeStamp = data["startTime"] as? Timestamp,
                      let endTimeStamp = data["endTime"] as? Timestamp,
                      let color = data["color"] as? String else {
                    print("Error parsing rooster entry data")
                    return nil
                }
                
                return RoosterEntry(
                    id: document.documentID,
                    title: title,
                    startTime: startTimeStamp.dateValue(),
                    endTime: endTimeStamp.dateValue(),
                    color: color,
                    teacher: data["teacher"] as? String,
                    room: data["room"] as? String,
                    description: data["description"] as? String,
                    calendarEventId: data["calendarEventId"] as? String,
                    isRecurring: data["isRecurring"] as? Bool ?? false,
                    recurrenceRule: data["recurrenceRule"] as? String
                )
            }
            
            print("✅ Loaded \(entries.count) rooster entries")
            return entries
        } catch {
            print("❌ Error fetching rooster entries: \(error.localizedDescription)")
            return []
        }
    }
    
    
    
    // MARK: - Rooster Methods
    func saveRoosterEntry(_ entry: RoosterEntry, userId: String, completion: ((Error?) -> Void)? = nil) {
        print("Saving rooster entry to Firebase...")
        print("Entry: \(entry)")
        
        // Get current authenticated user
        guard let currentUser = Auth.auth().currentUser else {
            let error = NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
            completion?(error)
            return
        }
        
        let data: [String: Any] = [
            "title": entry.title,
            "startTime": Timestamp(date: entry.startTime),
            "endTime": Timestamp(date: entry.endTime),
            "color": entry.color,
            "teacher": entry.teacher as Any,
            "room": entry.room as Any,
            "description": entry.description as Any,
            "calendarEventId": entry.calendarEventId as Any,
            "isRecurring": entry.isRecurring,
            "recurrenceRule": entry.recurrenceRule as Any,
            "lastUpdated": Timestamp(date: Date()),
            "userId": currentUser.uid  // Add the user ID to the document
        ]
        
        // Use the authenticated user's ID for the path
        db.collection("users").document(currentUser.uid)
            .collection("rooster").document(entry.id)
            .setData(data) { error in
                if let error = error {
                    print("❌ Firebase save error: \(error.localizedDescription)")
                    completion?(error)
                } else {
                    print("✅ Firebase save successful")
                    completion?(nil)
                }
            }
    }

    func loadRoosterEntries(userId: String, completion: @escaping ([RoosterEntry]) -> Void) {
        // Get current authenticated user
        guard let currentUser = Auth.auth().currentUser else {
            print("⚠️ No authenticated user")
            completion([])
            return
        }
        
        print("Loading rooster entries for user: \(currentUser.uid)")
        
        db.collection("users").document(currentUser.uid)
            .collection("rooster")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading rooster entries: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No rooster documents found")
                    completion([])
                    return
                }
                
                let entries = documents.compactMap { document -> RoosterEntry? in
                    let data = document.data()
                    
                    guard let title = data["title"] as? String,
                            let startTimeStamp = data["startTime"] as? Timestamp,
                            let endTimeStamp = data["endTime"] as? Timestamp,
                            let color = data["color"] as? String else {
                        print("Error parsing rooster entry data")
                        return nil
                    }
                    
                    return RoosterEntry(
                        id: document.documentID,
                        title: title,
                        startTime: startTimeStamp.dateValue(),
                        endTime: endTimeStamp.dateValue(),
                        color: color,
                        teacher: data["teacher"] as? String,
                        room: data["room"] as? String,
                        description: data["description"] as? String,
                        calendarEventId: data["calendarEventId"] as? String,
                        isRecurring: data["isRecurring"] as? Bool ?? false,
                        recurrenceRule: data["recurrenceRule"] as? String
                    )
                }
                
                print("✅ Loaded \(entries.count) rooster entries")
                completion(entries)
            }
    }

    func deleteRoosterEntry(userId: String, entryId: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("⚠️ No authenticated user")
            return
        }
        
        print("Deleting rooster entry: \(entryId)")
        
        db.collection("users").document(currentUser.uid)
            .collection("rooster").document(entryId)
            .delete { error in
                if let error = error {
                    print("❌ Error deleting rooster entry: \(error.localizedDescription)")
                } else {
                    print("✅ Successfully deleted rooster entry")
                }
            }
    }
    
    
    
    // MARK: - Category Methods
    func saveCategory(_ category: Category, userId: String) {
        guard let categoryId = category.id else {
            print("Error: Category ID is nil")
            return
        }
        
        var categoryData: [String: Any] = [
            "name": category.name,
            "todos": category.todos.map { todo in
                [
                    "id": todo.id,
                    "title": todo.title,
                    "isCompleted": todo.isCompleted,
                    "dateCreated": Timestamp(date: todo.dateCreated),
                    "deadline": todo.deadline.map { Timestamp(date: $0) } as Any,
                    "priority": todo.priority?.rawValue as Any  // Keep this rawValue as Priority is still an enum
                ]
            }
        ]
        
        // Add subject data if it exists
        if let subject = category.subject {
            categoryData["subject"] = [
                "id": subject.id,
                "name": subject.name,
                "icon": subject.icon,
                "color": subject.color
            ]
        }
        
        print("Updating category: \(category.name) with ID: \(categoryId)")
        
        db.collection("users").document(userId)
            .collection("categories").document(categoryId)
            .setData(categoryData) { error in
                if let error = error {
                    print("Error saving category: \(error.localizedDescription)")
                } else {
                    print("Successfully updated category: \(category.name)")
                }
            }
    }

    func createNewCategory(_ category: Category, userId: String) {
        var categoryData: [String: Any] = [
            "name": category.name,
            "todos": []
        ]
        
        // Add subject data if it exists
        if let subject = category.subject {
            categoryData["subject"] = [
                "id": subject.id,
                "name": subject.name,
                "icon": subject.icon,
                "color": subject.color
            ]
        }
        
        let newCategoryRef = db.collection("users").document(userId)
            .collection("categories").document()
        
        newCategoryRef.setData(categoryData) { error in
            if let error = error {
                print("Error creating category: \(error.localizedDescription)")
            } else {
                print("Successfully created new category: \(category.name)")
            }
        }
    }

    func loadCategories(userId: String, completion: @escaping ([Category]) -> Void) {
        print("Attempting to load categories for user: \(userId)")
        
        db.collection("users").document(userId)
            .collection("categories")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading categories: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    completion([])
                    return
                }
                
                let categories = documents.compactMap { document -> Category? in
                    let data = document.data()
                    let name = data["name"] as? String ?? ""
                    
                    // Handle subject data
                    if let subjectData = data["subject"] as? [String: Any] {
                        let subject = SchoolSubject(
                            id: subjectData["id"] as? String ?? UUID().uuidString,
                            name: subjectData["name"] as? String ?? "",
                            icon: subjectData["icon"] as? String ?? "book.fill",
                            color: subjectData["color"] as? String ?? "orange"
                        )
                        
                        // Handle todos data
                        let todosData = data["todos"] as? [[String: Any]] ?? []
                        let todos = todosData.compactMap { todoData -> TodoItem? in
                            guard let id = todoData["id"] as? String,
                                  let title = todoData["title"] as? String,
                                  let isCompleted = todoData["isCompleted"] as? Bool,
                                  let dateCreated = (todoData["dateCreated"] as? Timestamp)?.dateValue() else {
                                return nil
                            }
                            
                            let deadline = (todoData["deadline"] as? Timestamp)?.dateValue()
                            let priorityString = todoData["priority"] as? String
                            let priority = priorityString.flatMap { Priority(rawValue: $0) }
                            
                            return TodoItem(
                                id: id,
                                title: title,
                                isCompleted: isCompleted,
                                dateCreated: dateCreated,
                                deadline: deadline,
                                priority: priority
                            )
                        }
                        
                        return Category(
                            id: document.documentID,
                            name: name,
                            todos: todos,
                            subject: subject
                        )
                    } else {
                        // Category without subject
                        let todosData = data["todos"] as? [[String: Any]] ?? []
                        let todos = todosData.compactMap { todoData -> TodoItem? in
                            guard let id = todoData["id"] as? String,
                                  let title = todoData["title"] as? String,
                                  let isCompleted = todoData["isCompleted"] as? Bool,
                                  let dateCreated = (todoData["dateCreated"] as? Timestamp)?.dateValue() else {
                                return nil
                            }
                            
                            let deadline = (todoData["deadline"] as? Timestamp)?.dateValue()
                            let priorityString = todoData["priority"] as? String
                            let priority = priorityString.flatMap { Priority(rawValue: $0) }
                            
                            return TodoItem(
                                id: id,
                                title: title,
                                isCompleted: isCompleted,
                                dateCreated: dateCreated,
                                deadline: deadline,
                                priority: priority
                            )
                        }
                        
                        return Category(
                            id: document.documentID,
                            name: name,
                            todos: todos,
                            subject: nil
                        )
                    }
                }
                
                print("Loaded \(categories.count) categories")
                completion(categories)
            }
    }
    
    func deleteCategory(userId: String, categoryId: String) {
        print("Deleting category with ID: \(categoryId)")
        
        db.collection("users").document(userId)
            .collection("categories").document(categoryId)
            .delete() { error in
                if let error = error {
                    print("Error deleting category: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted category")
                }
            }
    }
    
    func updateCategoryTodos(category: Category, userId: String) {
        guard let categoryId = category.id else {
            print("Error: Category ID is nil")
            return
        }
        
        let categoryData: [String: Any] = [
            "name": category.name,
            "todos": category.todos.map { todo in
                [
                    "id": todo.id,
                    "title": todo.title,
                    "isCompleted": todo.isCompleted,
                    "dateCreated": todo.dateCreated,
                    "deadline": todo.deadline as Any,
                    "priority": todo.priority?.rawValue as Any
                ]
            }
        ]
        
        db.collection("users").document(userId)
            .collection("categories").document(categoryId)
            .setData(categoryData) { error in
                if let error = error {
                    print("Error updating todos: \(error.localizedDescription)")
                } else {
                    print("Successfully updated todos for category: \(category.name)")
                }
            }
    }
    
    

    // MARK: - Notes Methods
    func saveNote(_ note: Note, type: String, userId: String) {
        print("Saving note of type: \(type)")
        
        let noteData: [String: Any] = [
            "content": note.content,
            "lastModified": Timestamp(date: note.lastModified)
        ]
        
        db.collection("users").document(userId)
            .collection("notes").document(type)
            .setData(noteData) { error in
                if let error = error {
                    print("Error saving note: \(error.localizedDescription)")
                } else {
                    print("Successfully saved note")
                }
            }
    }

    func loadNote(type: String, userId: String, completion: @escaping (Note?) -> Void) {
        print("Loading note of type: \(type)")
        
        db.collection("users").document(userId)
            .collection("notes").document(type)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading note: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No note data found")
                    completion(nil)
                    return
                }
                
                let content = data["content"] as? String ?? ""
                let lastModified = (data["lastModified"] as? Timestamp)?.dateValue() ?? Date()
                
                let note = Note(id: type, content: content, lastModified: lastModified)
                print("Successfully loaded note")
                completion(note)
            }
    }
    
    
    
    // MARK: - Studiedoelen Methods
    func saveStudiedoel(_ studiedoel: Studiedoel, userId: String, completion: @escaping (Bool) -> Void) {
        do {
            let data = try studiedoel.asDictionary()
            let docRef = studiedoel.id.map {
                db.collection("users").document(userId).collection("studiedoelen").document($0)
            } ?? db.collection("users").document(userId).collection("studiedoelen").document()
            
            docRef.setData(data) { error in
                DispatchQueue.main.async {
                    completion(error == nil)
                }
            }
        } catch {
            print("Error saving studiedoel: \(error)")
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    func loadStudiedoelen(userId: String, completion: @escaping ([Studiedoel]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("studiedoelen")
            .order(by: "dateCreated", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading studiedoelen: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
                
                let studiedoelen = documents.compactMap { document -> Studiedoel? in
                    var studiedoel = try? document.data(as: Studiedoel.self)
                    studiedoel?.id = document.documentID
                    return studiedoel
                }
                
                DispatchQueue.main.async {
                    completion(studiedoelen)
                }
            }
    }

    func updateStudiedoel(_ studiedoel: Studiedoel, userId: String, completion: @escaping (Bool) -> Void) {
        guard let id = studiedoel.id else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        do {
            let data = try studiedoel.asDictionary()
            let db = Firestore.firestore()
            db.collection("users").document(userId).collection("studiedoelen").document(id)
                .setData(data) { error in
                    DispatchQueue.main.async {
                        completion(error == nil)
                    }
                }
        } catch {
            print("Error updating studiedoel: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }

    func deleteStudiedoel(userId: String, studiedoelId: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userId)
            .collection("studiedoelen").document(studiedoelId)
            .delete { error in
                if let error = error {
                    print("Error deleting studiedoel: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Successfully deleted studiedoel")
                    completion(true)
                }
            }
    }
    
    
    
    
    // MARK: - Meditation session saving to Firebase
    
    func saveMeditationSession(_ session: MeditationSession) {
        let data: [String: Any] = [
            "date": Timestamp(date: session.date),
            "duration": session.duration,
            "type": session.type,  // Already a String
            "rating": session.rating as Any,
            "notes": session.notes as Any,
            "breathingPattern": session.breathingPattern as Any  // Already a String
        ]
        
        print("Saving meditation session for user: \(session.userId)")
        
        db.collection("users").document(session.userId)
            .collection("meditation_sessions").document(session.id)
            .setData(data) { error in
                if let error = error {
                    print("Error saving meditation session: \(error.localizedDescription)")
                } else {
                    print("Successfully saved meditation session with ID: \(session.id)")
                }
            }
    }

    func fetchMeditationSessions(for userId: String, completion: @escaping ([MeditationSession]) -> Void) {
        print("Fetching meditation sessions for user: \(userId)")
        
        db.collection("users").document(userId)
            .collection("meditation_sessions")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching meditation sessions: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let sessions = documents.compactMap { document -> MeditationSession? in
                    let data = document.data()
                    let timestamp = data["date"] as? Timestamp ?? Timestamp(date: Date())
                    let duration = data["duration"] as? Int ?? 0
                    let typeString = data["type"] as? String ?? "Meditatie"  // Default to "Meditatie"
                    let rating = data["rating"] as? Int
                    let notes = data["notes"] as? String
                    let breathingPatternString = data["breathingPattern"] as? String
                    
                    return MeditationSession(
                        id: document.documentID,
                        userId: userId,
                        date: timestamp.dateValue(),
                        duration: duration,
                        type: MeditationType(rawValue: typeString) ?? .meditation,
                        rating: rating,
                        notes: notes,
                        breathingPattern: breathingPatternString.flatMap { BreathingPattern(rawValue: $0) }
                    )
                }
                
                completion(sessions)
            }
    }
    
    func deleteMeditationSession(userId: String, sessionId: String) {
        print("Deleting meditation session: \(sessionId)")
        
        db.collection("users").document(userId)
            .collection("meditation_sessions").document(sessionId)
            .delete { error in
                if let error = error {
                    print("Error deleting meditation session: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted meditation session")
                }
            }
    }
}
