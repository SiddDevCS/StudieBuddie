//
//  NewCategoryView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import SwiftUI

struct NewCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var categories: [Category]
    var userId: String
    
    @State private var categoryName = ""
    @State private var selectedSubject: SchoolSubject?
    @State private var showingSubjectPicker = false
    @State private var showingLimitError = false
    @State private var categoryType = "regular" // "regular" or "homework"
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(Bundle.localizedString(forKey: "Cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text(Bundle.localizedString(forKey: "New Category"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding()
                
                // Category Type Picker
                Picker("Type", selection: $categoryType) {
                    Text(Bundle.localizedString(forKey: "Task")).tag("regular")
                    Text(Bundle.localizedString(forKey: "Homework")).tag("homework")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(Bundle.localizedString(forKey: "Category Name"))
                        .foregroundColor(.gray)
                    
                    ZStack(alignment: .trailing) {
                        TextField(Bundle.localizedString(forKey: "Enter category name"),
                                text: Binding(
                            get: { categoryName },
                            set: { newValue in
                                if newValue.count <= CharacterLimits.categoryName {
                                    categoryName = newValue
                                } else {
                                    showingLimitError = true
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                        )
                        
                        if !categoryName.isEmpty {
                            Text("\(categoryName.count)/\(CharacterLimits.categoryName)")
                                .font(.caption)
                                .foregroundColor(categoryName.count >= CharacterLimits.categoryName ? .red : .secondary)
                                .padding(.trailing, 8)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                if categoryType == "homework" {
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
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                        .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                }
                
                Button {
                    addCategory()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(Bundle.localizedString(forKey: "Create Category"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(categoryName.isEmpty ? Color.orange.opacity(0.5) : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(categoryName.isEmpty ||
                         (categoryType == "homework" && selectedSubject == nil))
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingSubjectPicker) {
            SubjectPickerView(selectedSubject: $selectedSubject)
        }
        .alert(Bundle.localizedString(forKey: "Character Limit Exceeded"),
               isPresented: $showingLimitError) {
            Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
        } message: {
            Text(String(format: Bundle.localizedString(forKey: "Category names are limited to %d characters."),
                       CharacterLimits.categoryName))
        }
    }
    
    private func addCategory() {
        let newCategory = Category(
            name: categoryName,
            subject: categoryType == "homework" ? selectedSubject : nil
        )
        categories.append(newCategory)
        FirebaseManager.shared.createNewCategory(newCategory, userId: userId)
        dismiss()
    }
}
