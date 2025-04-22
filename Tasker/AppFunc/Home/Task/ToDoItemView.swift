//
//  TodoItemView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Calendar

struct TodoItemView: View {
    let todo: TodoItem
    let category: Category
    @Binding var categories: [Category]
    let userId: String
    
    @State private var showingOptions = false
    @State private var newTodoTitle = ""
    @State private var showingRenameAlert = false
    @State private var showingDateAlert = false
    @State private var showingPriorityAlert = false
    @State private var showingCalendarSync = false
    @State private var isSyncing = false
    @State private var newDeadline = Date()
    @State private var newPriority: Priority? = nil
    @State private var showingSyncResult = false
    @State private var syncSuccessful = false
    @State private var showingCharacterLimitError = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            Button {
                toggleTodoCompletion()
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .orange : .gray)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    
                    if category.subject != nil {
                        Image(systemName: "book.fill")
                            .foregroundColor(category.subject?.uiColor ?? .orange)
                            .font(.caption)
                    }
                }
                
                if let deadline = todo.deadline {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(dateFormatter.string(from: deadline))
                            .font(.caption)
                    }
                    .foregroundColor(isOverdue(deadline: deadline) ? .red : .secondary)
                }
                
                if let priority = todo.priority {
                    PriorityBadge(priority: priority)
                }
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    moveTaskUp()
                } label: {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.orange)
                }
                
                Button {
                    moveTaskDown()
                } label: {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.orange)
                }
                
                Button {
                    showingOptions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 8)
        .confirmationDialog(Bundle.localizedString(forKey: "Task Options"), isPresented: $showingOptions) {
            Button(Bundle.localizedString(forKey: "Rename")) {
                newTodoTitle = todo.title
                showingRenameAlert = true
            }
            
            Button(todo.deadline == nil ?
                  Bundle.localizedString(forKey: "Add Deadline") :
                  Bundle.localizedString(forKey: "Change Deadline")) {
                newDeadline = todo.deadline ?? Date()
                showingDateAlert = true
            }
            
            Button(todo.priority == nil ?
                  Bundle.localizedString(forKey: "Set Priority") :
                  Bundle.localizedString(forKey: "Change Priority")) {
                newPriority = todo.priority
                showingPriorityAlert = true
            }
            
            Button(Bundle.localizedString(forKey: "Sync with Calendar")) {
                showingCalendarSync = true
            }
            
            Button(Bundle.localizedString(forKey: "Share Task")) {
                shareTask()
            }
            
            Button(Bundle.localizedString(forKey: "Copy to Clipboard")) {
                UIPasteboard.general.string = formatTaskForSharing()
            }
            
            if todo.deadline != nil {
                Button(Bundle.localizedString(forKey: "Remove Deadline"), role: .destructive) {
                    updateDeadline(nil)
                }
            }
            
            if todo.priority != nil {
                Button(Bundle.localizedString(forKey: "Remove Priority"), role: .destructive) {
                    updatePriority(nil)
                }
            }
            
            Button(role: .destructive) {
                deleteTodo()
            } label: {
                Label(Bundle.localizedString(forKey: "Delete"), systemImage: "trash")
            }
        }
        .alert(Bundle.localizedString(forKey: "Rename Task"), isPresented: $showingRenameAlert) {
            TextField(Bundle.localizedString(forKey: "Task Name"), text: Binding(
                get: { newTodoTitle },
                set: { newValue in
                    if newValue.count <= CharacterLimits.todoTitle {
                        newTodoTitle = newValue
                    } else {
                        showingCharacterLimitError = true
                    }
                }
            ))
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
            Button(Bundle.localizedString(forKey: "Rename")) {
                renameTodo()
            }
            .disabled(newTodoTitle.isEmpty || newTodoTitle.count > CharacterLimits.todoTitle)
        } message: {
            Text(String(format: Bundle.localizedString(forKey: "Task names are limited to %d characters."),
                       CharacterLimits.todoTitle))
        }
        .alert(Bundle.localizedString(forKey: "Select Deadline"), isPresented: $showingDateAlert) {
            DatePicker(Bundle.localizedString(forKey: "Set Deadline"),
                      selection: $newDeadline,
                      displayedComponents: [.date, .hourAndMinute])
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
            Button(Bundle.localizedString(forKey: "Set")) {
                updateDeadline(newDeadline)
            }
        }
        .alert(Bundle.localizedString(forKey: "Set Priority"), isPresented: $showingPriorityAlert) {
            Picker(Bundle.localizedString(forKey: "Priority"), selection: $newPriority) {
                Text(Bundle.localizedString(forKey: "None")).tag(Optional<Priority>.none)
                ForEach(Priority.allCases, id: \.self) { priority in
                    Text(priority.localizedName).tag(Optional(priority))
                }
            }
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
            Button(Bundle.localizedString(forKey: "Set")) {
                updatePriority(newPriority)
            }
        }
        .sheet(isPresented: $showingCalendarSync) {
            CalendarSyncSettingsView(todo: todo, category: category)
        }
        .alert(Bundle.localizedString(forKey: "Character Limit Exceeded"),
               isPresented: $showingCharacterLimitError) {
            Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
        } message: {
            Text(String(format: Bundle.localizedString(forKey: "Task names are limited to %d characters."),
                       CharacterLimits.todoTitle))
        }
    }
    
    // MARK: - Helper Methods
    private func formatTaskForEmail() -> String {
        var text = "Taakdetails:\n\n"
        text += "Titel: \(todo.title)\n"
        text += "Categorie: \(category.name)\n"
        
        if let subject = category.subject {
            text += "Vak: \(subject.name)\n"
        }
        
        if let deadline = todo.deadline {
            text += "Deadline: \(dateFormatter.string(from: deadline))\n"
        }
        
        if let priority = todo.priority {
            text += "Prioriteit: \(priority.rawValue)\n"
        }
        
        text += "\nStatus: \(todo.isCompleted ? "Afgerond" : "Openstaand")\n"
        text += "\nVerzonden via Tasker App"
        return text
    }

    private func createNote() {
        let title = "Taak: \(todo.title)"
        let content = formatTaskForNote()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController {
            NotesManager.shared.createNote(
                title: title,
                content: content,
                from: viewController
            )
        }
    }
    
    private func isOverdue(deadline: Date) -> Bool {
        return deadline < Date()
    }
    
    private func shareTask() {
        let textToShare = formatTaskForSharing()
        let av = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let viewController = window.rootViewController {
            if let popover = av.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            viewController.present(av, animated: true)
        }
    }
    

    private func formatTaskForNote() -> String {
        var text = "\(Bundle.localizedString(forKey: "Task Details"))\n"
        text += "-------------\n\n"
        text += "\(Bundle.localizedString(forKey: "Category")): \(category.name)\n"
        
        if let subject = category.subject {
            text += "\(Bundle.localizedString(forKey: "Subject")): \(subject.name)\n"
        }
        
        if let deadline = todo.deadline {
            text += "\(Bundle.localizedString(forKey: "Deadline")): \(dateFormatter.string(from: deadline))\n"
        }
        
        if let priority = todo.priority {
            text += "\(Bundle.localizedString(forKey: "Priority")): \(priority.localizedName)\n"
        }
        
        let completionStatus = todo.isCompleted ?
            Bundle.localizedString(forKey: "Completed") :
            Bundle.localizedString(forKey: "Pending")
        text += "\n\(Bundle.localizedString(forKey: "Status")): \(completionStatus)\n"
        
        text += "\n\(Bundle.localizedString(forKey: "Created with Tasker App"))"
        return text
    }
    
    private func formatTaskForSharing() -> String {
        var text = "📝 \(Bundle.localizedString(forKey: "Title")): \(todo.title)\n"
        text += "📁 \(Bundle.localizedString(forKey: "Category")): \(category.name)\n"
        
        if let subject = category.subject {
            text += "📚 \(Bundle.localizedString(forKey: "Subject")): \(subject.name)\n"
        }
        
        if let deadline = todo.deadline {
            text += "⏰ \(Bundle.localizedString(forKey: "Deadline")): \(dateFormatter.string(from: deadline))\n"
        }
        
        if let priority = todo.priority {
            text += "🚨 \(Bundle.localizedString(forKey: "Priority")): \(priority.localizedName)\n"
        }
        
        text += "\n\(Bundle.localizedString(forKey: "Created with Tasker App"))"
        return text
    }
    
    // MARK: - Task Management Methods
    private func moveTaskUp() {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }),
           let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }),
           todoIndex > 0 {
            withAnimation {
                categories[categoryIndex].todos.swapAt(todoIndex, todoIndex - 1)
            }
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
    
    private func moveTaskDown() {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }),
           let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }),
           todoIndex < categories[categoryIndex].todos.count - 1 {
            withAnimation {
                categories[categoryIndex].todos.swapAt(todoIndex, todoIndex + 1)
            }
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
    
    private func toggleTodoCompletion() {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }),
           let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }) {
            withAnimation {
                categories[categoryIndex].todos[todoIndex].isCompleted.toggle()
            }
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
    
    private func deleteTodo() {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) {
            withAnimation {
                categories[categoryIndex].todos.removeAll(where: { $0.id == todo.id })
            }
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
    
    private func renameTodo() {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }),
           let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }) {
            categories[categoryIndex].todos[todoIndex].title = newTodoTitle
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
    
    private func updateDeadline(_ deadline: Date?) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }),
           let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }) {
            categories[categoryIndex].todos[todoIndex].deadline = deadline
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
    
    private func updatePriority(_ priority: Priority?) {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }),
           let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }) {
            categories[categoryIndex].todos[todoIndex].priority = priority
            FirebaseManager.shared.updateCategoryTodos(category: categories[categoryIndex], userId: userId)
        }
    }
}
