//
//  SubjectPickerView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 14/02/2025.
//

import SwiftUI

struct SubjectPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedSubject: SchoolSubject?
    
    var body: some View {
        NavigationView {
            List {
                Button {
                    selectedSubject = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "books.vertical")
                            .foregroundColor(.gray)
                        Text(Bundle.localizedString(forKey: "All Subjects"))
                        Spacer()
                        if selectedSubject == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                ForEach(SchoolSubject.subjects) { subject in
                    Button {
                        selectedSubject = subject
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: subject.icon)
                                .foregroundColor(subject.uiColor)
                            Text(subject.name)
                            Spacer()
                            if selectedSubject?.id == subject.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Bundle.localizedString(forKey: "Choose a subject"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Bundle.localizedString(forKey: "Done")) {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}
