//
//  CalendarSyncSettingsView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import SwiftUI

struct CalendarSyncSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let todo: TodoItem
    let category: Category
    
    @State private var startDate: Date
    @State private var duration: Int = 60
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedColor: CalendarColor = .defaultColor
    @State private var reminderTime: ReminderTime = .none
    @State private var location: String = ""
    @State private var notes: String = ""
    
    init(todo: TodoItem, category: Category) {
        self.todo = todo
        self.category = category
        _startDate = State(initialValue: todo.deadline ?? Date())
    }

    var body: some View {
        NavigationView {
            Form {
                // Event Details Section
                Section(Bundle.localizedString(forKey: "Event Details")) {
                    TextField(Bundle.localizedString(forKey: "Location"), text: $location)
                    
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2))
                        )
                }
                
                // Time Settings Section
                Section(Bundle.localizedString(forKey: "Time Settings")) {
                    DatePicker(Bundle.localizedString(forKey: "Start Time"),
                             selection: $startDate,
                             displayedComponents: [.date, .hourAndMinute])
                    
                    Picker(Bundle.localizedString(forKey: "Duration"), selection: $duration) {
                        Text(Bundle.localizedString(forKey: "15 minutes")).tag(15)
                        Text(Bundle.localizedString(forKey: "30 minutes")).tag(30)
                        Text(Bundle.localizedString(forKey: "45 minutes")).tag(45)
                        Text(Bundle.localizedString(forKey: "1 hour")).tag(60)
                        Text(Bundle.localizedString(forKey: "1.5 hours")).tag(90)
                        Text(Bundle.localizedString(forKey: "2 hours")).tag(120)
                        Text(Bundle.localizedString(forKey: "3 hours")).tag(180)
                        Text(Bundle.localizedString(forKey: "4 hours")).tag(240)
                    }
                }
                
                // Reminder Section
                Section(Bundle.localizedString(forKey: "Reminder")) {
                    Picker(Bundle.localizedString(forKey: "Reminder"), selection: $reminderTime) {
                        ForEach(ReminderTime.allCases) { reminder in
                            Text(reminder.localizedDescription).tag(reminder)
                        }
                    }
                }
                
                // Color Section
                Section(Bundle.localizedString(forKey: "Color")) {
                    Picker(Bundle.localizedString(forKey: "Event Color"), selection: $selectedColor) {
                        ForEach(CalendarColor.allCases) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.localizedDescription)
                            }
                            .tag(color)
                        }
                    }
                }
                
                // Subject Details if available
                if let subject = category.subject {
                    Section(Bundle.localizedString(forKey: "Subject Details")) {
                        HStack {
                            Image(systemName: subject.icon)
                                .foregroundColor(subject.uiColor)
                            Text(subject.name)
                        }
                    }
                }
                
                // Sync Button Section
                Section {
                    Button(action: syncToCalendar) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(.blue)
                                Text(Bundle.localizedString(forKey: "Sync with Google Calendar"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Google Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Bundle.localizedString(forKey: "Cancel")) {
                        dismiss()
                    }
                }
            }
            .alert(Bundle.localizedString(forKey: "Error"), isPresented: $showError) {
                Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    private func syncToCalendar() {
        isLoading = true
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "Kon Google Agenda niet initialiseren"
            showError = true
            return
        }
        
        if !GoogleCalendarManager.shared.isSignedIn {
            GoogleCalendarManager.shared.signIn(presenting: rootViewController) { success in
                if success {
                    performSync()
                } else {
                    isLoading = false
                    errorMessage = "Kon niet inloggen bij Google Agenda"
                    showError = true
                }
            }
        } else {
            performSync()
        }
    }
    
    private func performSync() {
        let endDate = Calendar.current.date(byAdding: .minute, value: duration, to: startDate) ?? startDate
        
        // Create event description
        var description = ""
        if !notes.isEmpty { description += "\(notes)\n\n" }
        if !location.isEmpty { description += "📍 Locatie: \(location)\n" }
        description += "📁 Categorie: \(category.name)"
        if let subject = category.subject {
            description += "\n📚 Vak: \(subject.name)"
        }
        
        GoogleCalendarManager.shared.syncTodoToCalendar(
            todo: todo,
            category: category,
            startTime: startDate,
            endTime: endDate,
            description: description,
            location: location,
            colorId: selectedColor.googleColorId,
            reminder: reminderTime
        ) { success in
            isLoading = false
            if success {
                dismiss()
            } else {
                errorMessage = "Synchronisatie met Google Agenda mislukt"
                showError = true
            }
        }
    }
}
