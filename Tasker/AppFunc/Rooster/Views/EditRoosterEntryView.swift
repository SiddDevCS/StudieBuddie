//
//  EditRoosterEntryView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import SwiftUI

struct EditRoosterEntryView: View {
    @Environment(\.dismiss) var dismiss
    let entry: RoosterEntry
    @Binding var roosterEntries: [RoosterEntry]
    let userId: String
    
    @State private var title: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedColor: String
    @State private var teacher: String
    @State private var room: String
    @State private var description: String
    @State private var isRecurring: Bool
    @State private var showingGoogleCalendarSync: Bool
    @State private var showingTitleLimitError = false
    @State private var showingDeleteAlert = false
    
    let colors = ["#FF9500", "#FF2D55", "#5856D6", "#34C759", "#007AFF"]
    
    init(entry: RoosterEntry, roosterEntries: Binding<[RoosterEntry]>, userId: String) {
        self.entry = entry
        self._roosterEntries = roosterEntries
        self.userId = userId
        
        _title = State(initialValue: entry.title)
        _startTime = State(initialValue: entry.startTime)
        _endTime = State(initialValue: entry.endTime)
        _selectedColor = State(initialValue: entry.color)
        _teacher = State(initialValue: entry.teacher ?? "")
        _room = State(initialValue: entry.room ?? "")
        _description = State(initialValue: entry.description ?? "")
        _isRecurring = State(initialValue: entry.isRecurring)
        _showingGoogleCalendarSync = State(initialValue: entry.calendarEventId != nil)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Vaknaam", systemImage: "book.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Voer vaknaam in", text: Binding(
                            get: { title },
                            set: { newValue in
                                if newValue.count <= CharacterLimits.lessonTitle {
                                    title = newValue
                                } else {
                                    showingTitleLimitError = true
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !title.isEmpty {
                            Text("\(title.count)/\(CharacterLimits.lessonTitle)")
                                .font(.caption)
                                .foregroundColor(title.count >= CharacterLimits.lessonTitle ? .red : .secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Time Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tijden", systemImage: "clock.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        DatePicker("Start", selection: $startTime, displayedComponents: [.hourAndMinute])
                        DatePicker("Eind", selection: $endTime, displayedComponents: [.hourAndMinute])
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Teacher & Room Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Details", systemImage: "person.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Docent (optioneel)", text: $teacher)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Lokaal (optioneel)", text: $room)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Kleur", systemImage: "paintpalette.fill")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(hex: color) ?? .orange)
                                    .frame(width: 35, height: 35)
                                    .overlay(
                                        Circle()
                                            .stroke(color == selectedColor ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Recurring Option
                    Toggle(isOn: $isRecurring) {
                        Label("Wekelijks Herhalen", systemImage: "repeat")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Google Calendar Sync
                    Toggle(isOn: $showingGoogleCalendarSync) {
                        Label("Synchroniseer met Google Agenda", systemImage: "calendar")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Delete Button
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Verwijder Les", systemImage: "trash")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Les Bewerken")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Opslaan") {
                        updateEntry()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Karakterlimiet Overschreden", isPresented: $showingTitleLimitError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Vaknaam is beperkt tot \(CharacterLimits.lessonTitle) karakters.")
            }
            .alert("Les Verwijderen", isPresented: $showingDeleteAlert) {
                Button("Verwijderen", role: .destructive) { deleteEntry() }
                Button("Annuleren", role: .cancel) { }
            } message: {
                Text("Weet je zeker dat je deze les wilt verwijderen?")
            }
        }
    }
    
    private func updateEntry() {
        let updatedEntry = RoosterEntry(
            id: entry.id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            color: selectedColor,
            teacher: teacher.isEmpty ? nil : teacher,
            room: room.isEmpty ? nil : room,
            description: description.isEmpty ? nil : description,
            calendarEventId: entry.calendarEventId,
            isRecurring: isRecurring,
            recurrenceRule: entry.recurrenceRule
        )
        
        if showingGoogleCalendarSync {
            if entry.calendarEventId != nil {
                updateGoogleCalendarEvent(updatedEntry)
            } else {
                createGoogleCalendarEvent(updatedEntry)
            }
        } else if entry.calendarEventId != nil {
            deleteGoogleCalendarEvent(updatedEntry)
        } else {
            saveEntry(updatedEntry)
        }
    }
    
    private func createGoogleCalendarEvent(_ entry: RoosterEntry) {
        let recurrenceRule = entry.isRecurring ? "RRULE:FREQ=WEEKLY" : nil
        
        GoogleCalendarManager.shared.syncTimeTableEntryToCalendar(
            entry: entry,
            recurrenceRule: recurrenceRule
        ) { success, eventId in
            if success {
                // Create new entry with calendar event ID
                let updatedEntry = RoosterEntry(
                    id: entry.id,
                    title: entry.title,
                    startTime: entry.startTime,
                    endTime: entry.endTime,
                    color: entry.color,
                    teacher: entry.teacher,
                    room: entry.room,
                    description: entry.description,
                    calendarEventId: eventId, // Set the new event ID
                    isRecurring: entry.isRecurring,
                    recurrenceRule: recurrenceRule
                )
                saveEntry(updatedEntry)
            } else {
                saveEntry(entry)
            }
        }
    }

    private func deleteGoogleCalendarEvent(_ entry: RoosterEntry) {
        if let eventId = entry.calendarEventId {
            GoogleCalendarManager.shared.deleteCalendarEvent(eventId: eventId) { _ in
                // Create new entry without calendar event ID
                let updatedEntry = RoosterEntry(
                    id: entry.id,
                    title: entry.title,
                    startTime: entry.startTime,
                    endTime: entry.endTime,
                    color: entry.color,
                    teacher: entry.teacher,
                    room: entry.room,
                    description: entry.description,
                    calendarEventId: nil, // Remove the event ID
                    isRecurring: entry.isRecurring,
                    recurrenceRule: entry.recurrenceRule
                )
                saveEntry(updatedEntry)
            }
        } else {
            saveEntry(entry)
        }
    }
    
    private func updateGoogleCalendarEvent(_ entry: RoosterEntry) {
        let recurrenceRule = entry.isRecurring ? "RRULE:FREQ=WEEKLY" : nil
        
        GoogleCalendarManager.shared.syncTimeTableEntryToCalendar(
            entry: entry,
            recurrenceRule: recurrenceRule
        ) { success, _ in
            saveEntry(entry)
        }
    }
    
    private func saveEntry(_ entry: RoosterEntry) {
        if let index = roosterEntries.firstIndex(where: { $0.id == entry.id }) {
            roosterEntries[index] = entry
        }
        FirebaseManager.shared.saveRoosterEntry(entry, userId: userId)
        dismiss()
    }
    
    private func deleteEntry() {
        if let calendarEventId = entry.calendarEventId {
            GoogleCalendarManager.shared.deleteCalendarEvent(eventId: calendarEventId) { _ in }
        }
        FirebaseManager.shared.deleteRoosterEntry(userId: userId, entryId: entry.id)
        roosterEntries.removeAll { $0.id == entry.id }
        dismiss()
    }
}

#Preview {
    EditRoosterEntryView(
        entry: RoosterEntry(
            title: "Nederlands",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            teacher: "Dhr. Jansen",
            room: "A1.05"
        ),
        roosterEntries: .constant([]),
        userId: "preview"
    )
}
