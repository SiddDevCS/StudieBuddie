//
//  NotesView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import SwiftUI

struct NotesView: View {
    let type: String
    let userId: String
    
    @State private var note: Note = Note()
    @State private var isEditing = false
    @State private var showingLimitError = false
    @State private var saveTimer: Timer?
    
    // Auto-save delay in seconds
    private let autoSaveDelay: TimeInterval = 2.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label(Bundle.localizedString(forKey: "Notes"), systemImage: "note.text")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !note.content.isEmpty {
                    Text(String(format: Bundle.localizedString(forKey: "Character Count"),
                              note.content.count,
                              CharacterLimits.notesField))
                        .font(.caption)
                        .foregroundColor(note.content.count >= CharacterLimits.notesField ? .red : .secondary)
                }
                
                if isEditing {
                    Button(action: {
                        saveNote()
                        isEditing = false
                    }) {
                        Text(Bundle.localizedString(forKey: "Save"))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(note.content.count > CharacterLimits.notesField ?
                                         Color.orange.opacity(0.5) :
                                         Color.orange)
                            )
                    }
                    .disabled(note.content.count > CharacterLimits.notesField)
                }
            }
            
            // Notes Editor
            TextEditor(text: Binding(
                get: { note.content },
                set: { newValue in
                    if newValue.count <= CharacterLimits.notesField {
                        note.content = newValue
                        isEditing = true
                        scheduleAutoSave()
                    } else {
                        showingLimitError = true
                    }
                }
            ))
            .font(.body)
            .frame(height: 100)
            .padding(12)
            .background(Color(uiColor: .systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
        .onAppear {
            loadNote()
        }
        .onDisappear {
            saveTimer?.invalidate()
            if isEditing {
                saveNote()
            }
        }
        .alert(Bundle.localizedString(forKey: "Character Limit Exceeded"), isPresented: $showingLimitError) {
            Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
        } message: {
            Text(String(format: Bundle.localizedString(forKey: "Notes Character Limit Message"),
                       CharacterLimits.notesField))
        }
    }
    
    private func loadNote() {
        FirebaseManager.shared.loadNote(type: type, userId: userId) { loadedNote in
            if let loadedNote = loadedNote {
                note = loadedNote
            }
        }
    }
    
    private func saveNote() {
        note.lastModified = Date()
        FirebaseManager.shared.saveNote(note, type: type, userId: userId)
        isEditing = false
    }
    
    private func scheduleAutoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveDelay, repeats: false) { _ in
            saveNote()
        }
    }
}
