//
//  NewRoosterEntryView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import SwiftUI
import Foundation

struct NewRoosterEntryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var roosterEntries: [RoosterEntry]
    let userId: String
    let selectedDate: Date
    
    @State private var title = ""
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedColor = "#FF9500"
    @State private var teacher = ""
    @State private var room = ""
    @State private var description = ""
    @State private var isRecurring = false
    @State private var showingGoogleCalendarSync = false
    @State private var showingTitleLimitError = false
    @State private var selectedSection: FormSection = .basic
    
    private let colors = ["#FF9500", "#FF2D55", "#5856D6", "#34C759", "#007AFF", "#BF5AF2"]
    
    enum FormSection: String {
        case basic = "Basis"
        case details = "Details"
        case recurring = "Herhaling"
    }
    
    init(roosterEntries: Binding<[RoosterEntry]>, userId: String, selectedDate: Date) {
        self._roosterEntries = roosterEntries
        self.userId = userId
        self.selectedDate = selectedDate
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = calendar.component(.hour, from: Date())
        components.minute = 0
        let initialStartTime = calendar.date(from: components) ?? Date()
        _startTime = State(initialValue: initialStartTime)
        _endTime = State(initialValue: initialStartTime.addingTimeInterval(3600))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Section Picker
                    Picker("Section", selection: $selectedSection) {
                        ForEach([FormSection.basic, .details, .recurring], id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Dynamic Form Content
                    Group {
                        switch selectedSection {
                        case .basic:
                            basicSection
                        case .details:
                            detailsSection
                        case .recurring:
                            recurringSection
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                .padding(.vertical)
            }
            .navigationTitle("Nieuwe Les")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Toevoegen") {
                        addEntry()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Karakterlimiet", isPresented: $showingTitleLimitError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Vaknaam is beperkt tot \(CharacterLimits.lessonTitle) karakters.")
            }
        }
    }
    
    private var basicSection: some View {
        VStack(spacing: 20) {
            // Title Input
            FormCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vaknaam")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Bijv: Nederlands", text: Binding(
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
                            .foregroundColor(
                                title.count >= CharacterLimits.lessonTitle ? .red : .secondary
                            )
                    }
                }
            }
            
            // Time Selection
            FormCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tijden")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        DatePicker("Start", selection: $startTime, displayedComponents: [.hourAndMinute])
                        Divider()
                        DatePicker("Eind", selection: $endTime, displayedComponents: [.hourAndMinute])
                    }
                }
            }
            
            // Color Selection
            FormCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kleur")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [GridItem](repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            ColorButton(
                                color: color,
                                isSelected: color == selectedColor,
                                action: { selectedColor = color }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var detailsSection: some View {
        VStack(spacing: 20) {
            FormCard {
                VStack(alignment: .leading, spacing: 16) {
                    // Teacher Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Docent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Bijv: Dhr. Jansen", text: $teacher)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                    
                    // Room Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lokaal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Bijv: A1.05", text: $room)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            FormCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beschrijving")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var recurringSection: some View {
        VStack(spacing: 20) {
            FormCard {
                Toggle(isOn: $isRecurring) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wekelijks Herhalen")
                            .font(.headline)
                        Text("Deze les wordt elke week herhaald")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            FormCard {
                Toggle(isOn: $showingGoogleCalendarSync) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Google Agenda")
                            .font(.headline)
                        Text("Synchroniseer met Google Agenda")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if isRecurring {
                FormCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Let op", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("Herhalende lessen kunnen later worden aangepast of verwijderd.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Add this function inside NewRoosterEntryView
    private func addEntry() {
        print("Creating new rooster entry...")
        
        let newEntry = RoosterEntry(
            title: title,
            startTime: startTime,
            endTime: endTime,
            color: selectedColor,
            teacher: teacher.isEmpty ? nil : teacher,
            room: room.isEmpty ? nil : room,
            description: description.isEmpty ? nil : description,
            isRecurring: isRecurring
        )
        
        print("New entry created: \(newEntry)")
        print("User ID: \(userId)")
        
        // Add to local array
        roosterEntries.append(newEntry)
        
        // Save to Firebase
        FirebaseManager.shared.saveRoosterEntry(newEntry, userId: userId) { error in
            if let error = error {
                print("❌ Error saving to Firebase: \(error.localizedDescription)")
            } else {
                print("✅ Successfully saved to Firebase")
            }
        }
        
        // Google Calendar sync
        if showingGoogleCalendarSync {
            GoogleCalendarManager.shared.syncTimeTableEntryToCalendar(
                entry: newEntry,
                recurrenceRule: isRecurring ? "RRULE:FREQ=WEEKLY" : nil
            ) { success, eventId in
                if success, let eventId = eventId {
                    let updatedEntry = RoosterEntry(
                        id: newEntry.id,
                        title: newEntry.title,
                        startTime: newEntry.startTime,
                        endTime: newEntry.endTime,
                        color: newEntry.color,
                        teacher: newEntry.teacher,
                        room: newEntry.room,
                        description: newEntry.description,
                        calendarEventId: eventId,
                        isRecurring: newEntry.isRecurring,
                        recurrenceRule: isRecurring ? "RRULE:FREQ=WEEKLY" : nil
                    )
                    FirebaseManager.shared.saveRoosterEntry(updatedEntry, userId: userId) { error in
                        if let error = error {
                            print("❌ Error updating entry with calendar ID: \(error.localizedDescription)")
                        } else {
                            print("✅ Successfully updated entry with calendar ID")
                        }
                    }
                }
            }
        }
        
        dismiss()
    }

}

struct ColorButton: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: color) ?? .orange)
                .frame(width: 35, height: 35)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white, lineWidth: isSelected ? 2 : 0)
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: isSelected ? 1 : 0)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 3)
        }
    }
}
