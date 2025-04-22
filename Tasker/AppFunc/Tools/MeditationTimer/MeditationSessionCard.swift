//
//  MeditationSessionCard.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import SwiftUI

struct MeditationSessionCard: View {
    let session: MeditationSession
    let userId: String
    @Binding var sessions: [MeditationSession]
    @State private var showingDeleteAlert = false
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: session.type == Bundle.localizedString(forKey: "Meditation") ?
                      "brain.head.profile" : "lungs.fill")
                    .foregroundColor(.purple)
                Text(session.type)
                    .font(.headline)
                Spacer()
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                Label("\(session.duration) \(Bundle.localizedString(forKey: "minutes"))",
                      systemImage: "clock")
                if let pattern = session.breathingPattern {
                    Label(pattern, systemImage: "lungs")
                }
                if let rating = session.rating {
                    Label("\(rating)/10", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            .font(.subheadline)
            
            if let notes = session.notes {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .alert(Bundle.localizedString(forKey: "Delete Session"),
               isPresented: $showingDeleteAlert) {
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) {}
            Button(Bundle.localizedString(forKey: "Delete"), role: .destructive) {
                FirebaseManager.shared.deleteMeditationSession(userId: userId, sessionId: session.id)
                sessions.removeAll { $0.id == session.id }
            }
        } message: {
            Text(Bundle.localizedString(forKey: "Are you sure you want to delete this meditation session?"))
        }
        .environment(\.locale, Locale(identifier: language))
    }
}
