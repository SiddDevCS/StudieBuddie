//
//  CategoryStore.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 22/01/2025.
//

import Foundation

class CategoryStore: ObservableObject {
    @Published var categories: [Category] = []
    private let defaults = UserDefaults.standard
    
    func loadCategories(userId: String) {
        let key = "\(userId)_categories"
        if let data = defaults.data(forKey: key),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            self.categories = decodedCategories
        }
    }
    
    func saveCategories(userId: String) {
        let key = "\(userId)_categories"
        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func addCategory(_ category: Category, userId: String) {
        categories.append(category)
        saveCategories(userId: userId)
    }
    
    func updateCategory(_ category: Category, userId: String) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories(userId: userId)
        }
    }
    
    func deleteCategory(_ category: Category, userId: String) {
        categories.removeAll { $0.id == category.id }
        saveCategories(userId: userId)
    }
}
