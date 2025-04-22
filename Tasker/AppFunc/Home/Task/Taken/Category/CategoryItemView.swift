//
//  CategoryItemView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import SwiftUI

struct CategoryItemView: View {
    let category: Category
    @Binding var categories: [Category]
    let userId: String
    
    @State private var isExpanded = true
    @State private var showingOptions = false
    @State private var newCategoryName = ""
    @State private var showingRenameAlert = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 12) {
            // Category Header
            HStack {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.orange)
                }
                
                if let subject = category.subject {
                    Image(systemName: subject.icon)
                        .foregroundColor(subject.uiColor)
                }
                
                Text(category.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(category.todos.filter { !$0.isCompleted }.count)/\(category.todos.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button {
                    showingOptions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            
            // Todos List
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(category.todos) { todo in
                        TodoItemView(todo: todo,
                                   category: category,
                                   categories: $categories,
                                   userId: userId)
                    }
                    
                    NavigationLink {
                        NewTodoView(category: category,
                                  categories: $categories,
                                  userId: userId)
                    } label: {
                        Label(Bundle.localizedString(forKey: "New Task"),
                              systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .confirmationDialog(Bundle.localizedString(forKey: "Category Options"),
                          isPresented: $showingOptions) {
            Button {
                newCategoryName = category.name
                showingRenameAlert = true
            } label: {
                Label(Bundle.localizedString(forKey: "Rename"),
                      systemImage: "pencil")
            }
            
            Button {
                shareCategory()
            } label: {
                Label(Bundle.localizedString(forKey: "Share Category"),
                      systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                deleteCategory()
            } label: {
                Label(Bundle.localizedString(forKey: "Delete"),
                      systemImage: "trash")
            }
        }
        .alert(Bundle.localizedString(forKey: "Rename Category"),
               isPresented: $showingRenameAlert) {
            TextField(Bundle.localizedString(forKey: "Category Name"),
                     text: Binding(
                get: { newCategoryName },
                set: { newValue in
                    if newValue.count <= CharacterLimits.categoryName {
                        newCategoryName = newValue
                    }
                }
            ))
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
            Button(Bundle.localizedString(forKey: "Rename")) {
                renameCategory()
            }
            .disabled(newCategoryName.isEmpty ||
                     newCategoryName.count > CharacterLimits.categoryName)
        } message: {
            Text(String(format: Bundle.localizedString(forKey: "Maximum %d characters"),
                       CharacterLimits.categoryName))
        }
    }
    
    private func deleteCategory() {
        if let categoryId = category.id {
            FirebaseManager.shared.deleteCategory(userId: userId, categoryId: categoryId)
            categories.removeAll { $0.id == category.id }
        }
    }
    
    private func renameCategory() {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index].name = newCategoryName
            FirebaseManager.shared.saveCategory(categories[index], userId: userId)
        }
    }
    
    private func shareCategory() {
        let textToShare = formatCategoryForSharing()
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
    
    private func formatCategoryForSharing() -> String {
        var text = "📁 \(Bundle.localizedString(forKey: "Category")): \(category.name)\n"
        if let subject = category.subject {
            text += "📚 \(Bundle.localizedString(forKey: "Subject")): \(subject.name)\n"
        }
        text += "📝 \(Bundle.localizedString(forKey: "Tasks")) (\(category.todos.count)):\n\n"
        
        for (index, todo) in category.todos.enumerated() {
            text += "\(index + 1). \(todo.title)"
            
            if let deadline = todo.deadline {
                text += "\n   ⏰ \(dateFormatter.string(from: deadline))"
            }
            
            if let priority = todo.priority {
                text += "\n   🚨 \(priority.rawValue)"
            }
            
            if todo.isCompleted {
                text += "\n   ✅ Afgerond"
            }
            
            text += "\n\n"
        }
        
        text += "\n\(Bundle.localizedString(forKey: "Shared via Tasker App"))"
        return text
    }
}

#Preview {
    CategoryItemView(
        category: Category(
            name: "Voorbeeld Categorie",
            subject: SchoolSubject.subjects[0]
        ),
        categories: .constant([]),
        userId: "preview"
    )
}
