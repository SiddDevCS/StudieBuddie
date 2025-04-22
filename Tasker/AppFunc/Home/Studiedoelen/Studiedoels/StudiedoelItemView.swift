//
//  StudiedoelItemView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct StudiedoelItemView: View {
    let studiedoel: Studiedoel
    @Binding var studiedoelen: [Studiedoel]
    let userId: String
    let onAICoachTap: () -> Void
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Subject Icon, Title, and Completion Checkbox
            HStack {
                HStack(spacing: 8) {
                    if let subject = studiedoel.subject {
                        Image(systemName: subject.icon)
                            .foregroundColor(subject.uiColor)
                    }
                    
                    Text(studiedoel.title)
                        .font(.headline)
                        .strikethrough(studiedoel.isCompleted)
                }
                
                Spacer()
                
                Button {
                    toggleCompletion()
                } label: {
                    Image(systemName: studiedoel.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(studiedoel.isCompleted ? .green : .gray)
                        .font(.title3)
                }
            }
            
            // Description
            if !studiedoel.description.isEmpty {
                Text(studiedoel.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Deadline and Grades
            HStack {
                Label(formatDate(studiedoel.deadline), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let current = studiedoel.currentGrade,
                   let target = studiedoel.targetGrade {
                    Spacer()
                    Label("\(String(format: "%.1f", current)) → \(String(format: "%.1f", target))",
                          systemImage: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack {
                Button {
                    onAICoachTap()
                } label: {
                    Label(Bundle.localizedString(forKey: "AI Coach"), systemImage: "brain")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                Button {
                    showingEditSheet = true
                } label: {
                    Label(Bundle.localizedString(forKey: "Edit"), systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button {
                    showingDeleteAlert = true
                } label: {
                    Label(Bundle.localizedString(forKey: "Delete"), systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .alert(Bundle.localizedString(forKey: "Delete Study Goal?"), isPresented: $showingDeleteAlert) {
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
            Button(Bundle.localizedString(forKey: "Delete"), role: .destructive) {
                deleteStudiedoel()
            }
        } message: {
            Text(Bundle.localizedString(forKey: "Are you sure you want to delete this study goal?"))
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationView {
                EditStudiedoelView(
                    studiedoel: studiedoel,
                    studiedoelen: $studiedoelen,
                    userId: userId
                )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current // Use system locale instead of hardcoded
        return formatter.string(from: date)
    }
    
    private func toggleCompletion() {
        guard let index = studiedoelen.firstIndex(where: { $0.id == studiedoel.id }) else { return }
        
        // Update local state immediately
        studiedoelen[index].isCompleted.toggle()
        
        // Update in Firebase
        FirebaseManager.shared.saveStudiedoel(studiedoelen[index], userId: userId) { success in
            if !success {
                // Revert if failed
                DispatchQueue.main.async {
                    studiedoelen[index].isCompleted.toggle()
                }
            }
        }
    }
    
    private func deleteStudiedoel() {
        guard let id = studiedoel.id else { return }
        
        FirebaseManager.shared.deleteStudiedoel(userId: userId, studiedoelId: id) { success in
            if success {
                DispatchQueue.main.async {
                    studiedoelen.removeAll { $0.id == id }
                }
            }
        }
    }
}
