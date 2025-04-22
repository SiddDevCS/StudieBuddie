//
//  NewStudiedoelView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import SwiftUI

struct NewStudiedoelView: View {
    @Environment(\.dismiss) var dismiss
    let userId: String
    
    @State private var title = ""
    @State private var description = ""
    @State private var deadline: Date = Date()
    @State private var selectedSubject: SchoolSubject?
    @State private var showingSubjectPicker = false
    @State private var showingLimitError = false
    @State private var currentGrade: String = ""
    @State private var targetGrade: String = ""
    
    var isValidForm: Bool {
        !title.isEmpty &&
        (currentGrade.isEmpty || (Double(currentGrade) ?? 0 >= 1 && Double(currentGrade) ?? 0 <= 10)) &&
        (targetGrade.isEmpty || (Double(targetGrade) ?? 0 >= 1 && Double(targetGrade) ?? 0 <= 10))
    }
    
    var body: some View {
        Form {
            Section(header: Text(Bundle.localizedString(forKey: "Title"))) {
                let titleBinding = Binding(
                    get: { title },
                    set: { newValue in
                        if newValue.count <= CharacterLimits.studiedoelTitel {
                            title = newValue
                        } else {
                            showingLimitError = true
                        }
                    }
                )
                
                TextField(Bundle.localizedString(forKey: "Enter title"), text: titleBinding)
            }
            
            Section(header: Text(Bundle.localizedString(forKey: "Description"))) {
                let descBinding = Binding(
                    get: { description },
                    set: { newValue in
                        if newValue.count <= CharacterLimits.studiedoelOmschrijving {
                            description = newValue
                        } else {
                            showingLimitError = true
                        }
                    }
                )
                
                TextEditor(text: descBinding)
                    .frame(height: 100)
            }
            
            Section(header: Text(Bundle.localizedString(forKey: "Deadline"))) {
                DatePicker(Bundle.localizedString(forKey: "Choose deadline"),
                          selection: $deadline,
                          displayedComponents: [.date])
            }
            
            Section(header: Text(Bundle.localizedString(forKey: "Subject"))) {
                Button {
                    showingSubjectPicker = true
                } label: {
                    HStack {
                        if let subject = selectedSubject {
                            Image(systemName: subject.icon)
                                .foregroundColor(subject.uiColor)
                            Text(subject.name)
                        } else {
                            Image(systemName: "book.fill")
                            Text(Bundle.localizedString(forKey: "Choose a subject"))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text(Bundle.localizedString(forKey: "Grades (Optional)"))) {
                HStack {
                    Text(Bundle.localizedString(forKey: "Current grade"))
                    Spacer()
                    TextField("", text: $currentGrade)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text(Bundle.localizedString(forKey: "Target grade"))
                    Spacer()
                    TextField("", text: $targetGrade)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
            }
        }
        .navigationTitle(Bundle.localizedString(forKey: "New Study Goal"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(Bundle.localizedString(forKey: "Cancel")) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Bundle.localizedString(forKey: "Save")) {
                    saveStudiedoel()
                }
                .disabled(!isValidForm)
            }
        }
        .sheet(isPresented: $showingSubjectPicker) {
            SubjectPickerView(selectedSubject: $selectedSubject)
        }
        .alert(Bundle.localizedString(forKey: "Character Limit Exceeded"),
               isPresented: $showingLimitError) {
            Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
        } message: {
            Text(Bundle.localizedString(forKey: "Maximum length has been reached."))
        }
    }
    
    private func saveStudiedoel() {
        let newStudiedoel = Studiedoel(
            title: title,
            description: description,
            deadline: deadline,
            subject: selectedSubject,
            isCompleted: false,
            dateCreated: Date(),
            currentGrade: Double(currentGrade),
            targetGrade: Double(targetGrade)
        )
        
        FirebaseManager.shared.saveStudiedoel(newStudiedoel, userId: userId) { success in
            if success {
                dismiss()
            }
        }
    }
}
