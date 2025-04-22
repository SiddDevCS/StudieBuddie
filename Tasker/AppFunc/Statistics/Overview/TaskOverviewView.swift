//
//  TaskOverviewView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import SwiftUI
import FirebaseFirestore

// MARK: - DueFilter Enum
fileprivate enum DueFilter: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case overdue = "Overdue"
    
    var localizedName: String {
            return Bundle.localizedString(forKey: self.rawValue)
        }
    
    var symbol: String {
        switch self {
        case .today: return "calendar.badge.exclamationmark"
        case .week: return "calendar.badge.clock"
        case .overdue: return "exclamationmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .today: return .orange
        case .week: return .blue
        case .overdue: return .red
        }
    }
}

struct TaskOverviewView: View {
    let userId: String
    @State private var categories: [Category] = []
    @State private var selectedSection: DueFilter = .today
    // Add this line to observe language changes
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        ZStack {
            // Achtergrond gradient
            LinearGradient(
                colors: [
                    selectedSection.color.opacity(0.1),
                    selectedSection.color.opacity(0.05),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Sectie Kiezer
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(DueFilter.allCases, id: \.self) { section in
                            SectionButton(
                                title: section.rawValue,
                                icon: section.symbol,
                                color: section.color,
                                isSelected: selectedSection == section,
                                action: {
                                    withAnimation {
                                        selectedSection = section
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Taken ScrollView
                ScrollView {
                    VStack(spacing: 15) {
                        let tasks = filterTasksByDue(for: selectedSection)
                        
                        if tasks.isEmpty {
                            EmptyStateViewOverview(filter: selectedSection)
                        } else {
                            ForEach(tasks, id: \.0.id) { category, todos in
                                CategoryTasksView(
                                    category: category,
                                    todos: todos,
                                    accentColor: selectedSection.color
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .environment(\.locale, Locale(identifier: language)) // Add this line
        .navigationTitle(NSLocalizedString("Task Overview", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCategories()
        }
    }
    
    private func loadCategories() {
        FirebaseManager.shared.loadCategories(userId: userId) { loadedCategories in
            categories = loadedCategories
        }
    }
    
    private func filterTasksByDue(for filter: DueFilter) -> [(Category, [TodoItem])] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        return categories.compactMap { category in
            let filteredTodos = category.todos.filter { todo in
                guard let deadline = todo.deadline, !todo.isCompleted else { return false }
                
                switch filter {
                case .today:
                    return calendar.isDate(deadline, inSameDayAs: today)
                case .week:
                    return deadline > today && deadline <= endOfWeek
                case .overdue:
                    return deadline < today
                }
            }
            let sortedTodos = filteredTodos.sorted { todo1, todo2 in
                guard let date1 = todo1.deadline, let date2 = todo2.deadline else {
                    return false
                }
                return date1 < date2
            }
            
            return sortedTodos.isEmpty ? nil : (category, sortedTodos)
        }
    }
}

// MARK: - Ondersteunende Views
fileprivate struct SectionButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : color.opacity(0.3), lineWidth: 1.5)
            )
        }
        .foregroundColor(isSelected ? color : .secondary)
        .buttonStyle(PlainButtonStyle())
    }
}

fileprivate struct CategoryTasksView: View {
    let category: Category
    let todos: [TodoItem]
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Categorie Header
            HStack {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(accentColor)
                
                Spacer()
                
                Text("\(todos.count) " + Bundle.localizedString(forKey: "tasks"))
            }
            
            // Taken
            ForEach(todos) { todo in
                TaskRow(todo: todo, accentColor: accentColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: accentColor.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
}

fileprivate struct TaskRow: View {
    let todo: TodoItem
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .stroke(accentColor, lineWidth: 1.5)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(.body, design: .rounded))
                
                if let deadline = todo.deadline {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(deadline.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                    }
                    .foregroundColor(accentColor)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

fileprivate struct EmptyStateViewOverview: View {
    let filter: DueFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 50))
                .foregroundColor(filter.color)
            
            Text(Bundle.localizedString(forKey: "No tasks") + " " + filter.localizedName.lowercased())
            Text(Bundle.localizedString(forKey: "You're all caught up! Time to relax or plan ahead."))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: filter.color.opacity(0.1), radius: 10)
        )
        .padding(.top, 40)
    }
}

#Preview {
    TaskOverviewView(userId: "preview")
}
