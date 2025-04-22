//
//  EditStudiedoelenView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct EditStudiedoelView: View {
    @Environment(\.dismiss) var dismiss
    let studiedoel: Studiedoel
    @Binding var studiedoelen: [Studiedoel]
    let userId: String
    
    @State private var title: String
    @State private var description: String
    @State private var deadline: Date
    @State private var selectedSubject: SchoolSubject?
    @State private var showingSubjectPicker = false
    @State private var showingLimitError = false
    @State private var currentGrade: String
    @State private var targetGrade: String
    
    init(studiedoel: Studiedoel, studiedoelen: Binding<[Studiedoel]>, userId: String) {
        self.studiedoel = studiedoel
        self._studiedoelen = studiedoelen
        self.userId = userId
        
        _title = State(initialValue: studiedoel.title)
        _description = State(initialValue: studiedoel.description)
        _deadline = State(initialValue: studiedoel.deadline)
        _selectedSubject = State(initialValue: studiedoel.subject)
        _currentGrade = State(initialValue: studiedoel.currentGrade.map { String(format: "%.1f", $0) } ?? "")
        _targetGrade = State(initialValue: studiedoel.targetGrade.map { String(format: "%.1f", $0) } ?? "")
    }
    
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
        .navigationTitle(Bundle.localizedString(forKey: "Edit Study Goal"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(Bundle.localizedString(forKey: "Cancel")) {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Bundle.localizedString(forKey: "Save")) {
                    updateStudiedoel()
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
    
    private func updateStudiedoel() {
        var updatedStudiedoel = studiedoel
        updatedStudiedoel.title = title
        updatedStudiedoel.description = description
        updatedStudiedoel.deadline = deadline
        updatedStudiedoel.subject = selectedSubject
        updatedStudiedoel.currentGrade = Double(currentGrade)
        updatedStudiedoel.targetGrade = Double(targetGrade)
        
        FirebaseManager.shared.updateStudiedoel(updatedStudiedoel, userId: userId) { success in
            if success {
                if let index = studiedoelen.firstIndex(where: { $0.id == studiedoel.id }) {
                    DispatchQueue.main.async {
                        studiedoelen[index] = updatedStudiedoel
                        dismiss()
                    }
                }
            }
        }
    }
}
