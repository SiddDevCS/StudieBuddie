//
//  RoosterItemView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import SwiftUI

struct RoosterItemView: View {
    let entry: RoosterEntry
    @Binding var roosterEntries: [RoosterEntry]
    let userId: String
    
    @State private var showingOptionsSheet = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { showingOptionsSheet = true }) {
            HStack(spacing: 16) {
                // Time Column
                VStack(spacing: 4) {
                    Text(formatTime(entry.startTime))
                        .font(.system(.callout, design: .rounded).bold())
                    Text(formatTime(entry.endTime))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(width: 65)
                
                // Colored Bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: entry.color) ?? .orange)
                    .frame(width: 4)
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        if let teacher = entry.teacher {
                            LabeledIcon("person.fill", text: teacher)
                        }
                        
                        if let room = entry.room {
                            LabeledIcon("door.left.hand.closed", text: room)
                        }
                    }
                    
                    if entry.isRecurring {
                        LabeledIcon("repeat", text: "Wekelijks")
                            .foregroundColor(.accentColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Options Icon
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(90))
                    .padding(8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(
                        color: Color.black.opacity(isPressed ? 0.1 : 0.05),
                        radius: isPressed ? 5 : 10,
                        y: isPressed ? 2 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1) { pressed in
            isPressed = pressed
        } perform: {
            showingOptionsSheet = true
            hapticFeedback()
        }
        .confirmationDialog("Lesopties", isPresented: $showingOptionsSheet) {
            Button("Bewerken") {
                hapticFeedback(.medium)
                showingEditSheet = true
            }
            Button("Verwijderen", role: .destructive) {
                hapticFeedback(.medium)
                showingDeleteAlert = true
            }
            Button("Annuleren", role: .cancel) { }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditRoosterEntryView(
                    entry: entry,
                    roosterEntries: $roosterEntries,
                    userId: userId
                )
            }
            .presentationDragIndicator(.visible)
        }
        .alert("Les Verwijderen", isPresented: $showingDeleteAlert) {
            Button("Verwijderen", role: .destructive) {
                withAnimation {
                    deleteEntry()
                }
            }
            Button("Annuleren", role: .cancel) { }
        } message: {
            Text("Weet je zeker dat je deze les wilt verwijderen?")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func deleteEntry() {
        if let calendarEventId = entry.calendarEventId {
            GoogleCalendarManager.shared.deleteCalendarEvent(eventId: calendarEventId) { _ in }
        }
        FirebaseManager.shared.deleteRoosterEntry(userId: userId, entryId: entry.id)
        roosterEntries.removeAll { $0.id == entry.id }
        hapticFeedback(.heavy)
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Supporting Views
struct LabeledIcon: View {
    let icon: String
    let text: String
    
    init(_ icon: String, text: String) {
        self.icon = icon
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .imageScale(.small)
            Text(text)
                .font(.system(.footnote, design: .rounded))
        }
        .foregroundColor(.secondary)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        RoosterItemView(
            entry: RoosterEntry(
                title: "Nederlands",
                startTime: Date(),
                endTime: Date().addingTimeInterval(3600),
                color: "#FF9500",
                teacher: "Dhr. Jansen",
                room: "A1.05",
                isRecurring: true
            ),
            roosterEntries: .constant([]),
            userId: "preview"
        )
        
        RoosterItemView(
            entry: RoosterEntry(
                title: "Wiskunde",
                startTime: Date().addingTimeInterval(4000),
                endTime: Date().addingTimeInterval(7600),
                color: "#5856D6",
                teacher: "Mevr. Peters",
                room: "B2.10"
            ),
            roosterEntries: .constant([]),
            userId: "preview"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
