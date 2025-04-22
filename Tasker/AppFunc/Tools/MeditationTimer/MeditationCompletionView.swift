//
//  MeditationCompletionView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import SwiftUI
import Foundation
import FirebaseFirestore

struct MeditationCompletionView: View {
    let duration: Int
    let type: MeditationType
    let pattern: BreathingPattern?
    let userId: String
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 5
    @State private var notes: String = ""
    @State private var showingConfetti = false
    @State private var isSaving = false
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Success Animation
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)
                    
                    // Session Summary Card
                    VStack(spacing: 16) {
                        summaryRow(title: Bundle.localizedString(forKey: "Duration"),
                                 value: "\(duration) \(Bundle.localizedString(forKey: "minutes"))")
                        summaryRow(title: Bundle.localizedString(forKey: "Type"),
                                 value: type.localizedName)
                        if let pattern = pattern {
                            summaryRow(title: Bundle.localizedString(forKey: "Pattern"),
                                     value: pattern.localizedName)
                        }
                    }
                    .padding()
                    .background(/* ... */)
                    
                    // Waardering Sectie
                    VStack(alignment: .leading, spacing: 12) {
                        Text(Bundle.localizedString(forKey: "How was your session?"))
                            .font(.headline)
                        
                        HStack(spacing: 8) {
                            ForEach(1...10, id: \.self) { number in
                                Button {
                                    withAnimation {
                                        rating = number
                                    }
                                } label: {
                                    Text("\(number)")
                                        .font(.system(.body, design: .rounded))
                                        .frame(width: 30, height: 30)
                                        .background(
                                            Circle()
                                                .fill(rating == number ?
                                                    Color.purple.opacity(0.15) :
                                                    Color(uiColor: .secondarySystemBackground))
                                        )
                                        .foregroundColor(rating == number ? .purple : .secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Notities Sectie
                    VStack(alignment: .leading, spacing: 12) {
                        Text(Bundle.localizedString(forKey: "Add notes"))
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                    }
                    .padding(.horizontal)
                    
                    // Actie Knoppen
                    VStack(spacing: 16) {
                        Button {
                                guard !isSaving else { return }
                                isSaving = true
                                saveSession()
                                showingConfetti = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    isSaving = false
                                    dismiss()
                                }
                            } label: {
                                Text(Bundle.localizedString(forKey: "Save Session"))
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isSaving ? Color.gray : Color.purple)
                                    )
                                    .foregroundColor(.white)
                            }
                            .disabled(isSaving)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text(Bundle.localizedString(forKey: "Cancel"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle(Bundle.localizedString(forKey: "Session Complete"))
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.locale, Locale(identifier: language))
        }
    }
    
    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func saveSession() {
        let session = MeditationSession(
            userId: userId,
            duration: duration,
            type: type,  // This will now correctly use the passed type
            rating: rating,
            notes: notes.isEmpty ? nil : notes,
            breathingPattern: type == .breathing ? pattern : nil  // Only include pattern for breathing type
        )
        
        FirebaseManager.shared.saveMeditationSession(session)
    }
}
