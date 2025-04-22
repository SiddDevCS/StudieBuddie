//
//  NewToDoView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import SwiftUI

struct NewTodoView: View {
    let category: Category
    @Binding var categories: [Category]
    let userId: String
    
    @Environment(\.dismiss) var dismiss
    @State private var todoTitle = ""
    @State private var deadline: Date?
    @State private var showingDatePicker = false
    @State private var selectedDate = Date()
    @State private var priority: Priority?
    @State private var isDeadlineEnabled = false
    @State private var showingCharacterLimitError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Info Header
                        if let subject = category.subject {
                            HStack {
                                Image(systemName: subject.icon)
                                    .foregroundColor(subject.uiColor)
                                Text(subject.name)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                        
                        // Task Title Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label(Bundle.localizedString(forKey: "Task Name"), systemImage: "pencil")
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .trailing) {
                                TextField(Bundle.localizedString(forKey: "Enter task name"), text: Binding(
                                    get: { todoTitle },
                                    set: { newValue in
                                        if newValue.count <= CharacterLimits.todoTitle {
                                            todoTitle = newValue
                                        } else {
                                            showingCharacterLimitError = true
                                        }
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                if !todoTitle.isEmpty {
                                    Text("\(todoTitle.count)/\(CharacterLimits.todoTitle)")
                                        .font(.caption)
                                        .foregroundColor(todoTitle.count >= CharacterLimits.todoTitle ? .red : .secondary)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Priority Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label(Bundle.localizedString(forKey: "Priority"), systemImage: "flag")
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                PriorityButton(
                                    title: Bundle.localizedString(forKey: "None"),
                                    symbol: "minus.circle",
                                    isSelected: priority == nil
                                ) {
                                    priority = nil
                                }
                                
                                PriorityButton(
                                    title: Bundle.localizedString(forKey: "High"),
                                    symbol: "exclamationmark.3",
                                    isSelected: priority == .high
                                ) {
                                    priority = .high
                                }
                                
                                PriorityButton(
                                    title: Bundle.localizedString(forKey: "Medium"),
                                    symbol: "exclamationmark.2",
                                    isSelected: priority == .medium
                                ) {
                                    priority = .medium
                                }
                                
                                PriorityButton(
                                    title: Bundle.localizedString(forKey: "Low"),
                                    symbol: "exclamationmark",
                                    isSelected: priority == .low
                                ) {
                                    priority = .low
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Deadline Section
                        VStack(alignment: .leading, spacing: 8) {
                            Label(Bundle.localizedString(forKey: "Deadline"), systemImage: "calendar")
                                .foregroundColor(.gray)
                            
                            Toggle(isOn: $isDeadlineEnabled.animation()) {
                                Text(Bundle.localizedString(forKey: "Add Deadline"))
                            }
                            
                            if isDeadlineEnabled {
                                DatePicker(Bundle.localizedString(forKey: "Select deadline"),
                                         selection: $selectedDate,
                                         displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.graphical)
                                    .onChange(of: selectedDate) { newValue in
                                        deadline = newValue
                                    }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Create Task Button
                        Button {
                            addTodo()
                        } label: {
                            Label(Bundle.localizedString(forKey: "Create Task"), systemImage: "plus")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(todoTitle.isEmpty ? Color.orange.opacity(0.5) : Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(todoTitle.isEmpty)
                        .padding(.vertical)
                    }
                    .padding()
                }
            }
            .navigationTitle(Bundle.localizedString(forKey: "New Task"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Bundle.localizedString(forKey: "Cancel")) {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
            .alert(Bundle.localizedString(forKey: "Character Limit Exceeded"), isPresented: $showingCharacterLimitError) {
                Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
            } message: {
                Text(String(format: Bundle.localizedString(forKey: "Task names are limited to %d characters."),
                          CharacterLimits.todoTitle))
            }
        }
    }
    
    private func addTodo() {
        let newTodo = TodoItem(
            title: todoTitle,
            deadline: isDeadlineEnabled ? deadline : nil,
            priority: priority
        )
        
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].todos.append(newTodo)
            FirebaseManager.shared.updateCategoryTodos(category: categories[index], userId: userId)
        }
        
        dismiss()
    }
}

struct PriorityButton: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: symbol)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color(uiColor: .systemGray4) : Color(uiColor: .systemGray6))
            .foregroundColor(isSelected ? .primary : .gray)
            .cornerRadius(8)
        }
    }
}
