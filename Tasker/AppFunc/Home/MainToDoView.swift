//
//  MainToDoView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 16/01/2025.
//

import SwiftUI
import FirebaseFirestore

struct MainToDoView: View {
    var userId: String
    @State private var categories: [Category] = []
    @State private var showingNewCategorySheet = false
    @State private var selectedTab = 0
    @State private var selectedSubject: SchoolSubject?
    @State private var showingSubjectPicker = false
    
    // Separate categories into homework and regular tasks
    var homeworkCategories: [Category] {
        guard let subject = selectedSubject else {
            return categories.filter { $0.subject != nil }
        }
        return categories.filter { $0.subject == subject }
    }
    
    var regularCategories: [Category] {
        categories.filter { $0.subject == nil }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.1),
                        Color.orange.opacity(0.05),
                        Color(uiColor: .systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main Tab Picker
                    Picker("View", selection: $selectedTab) {
                        Text(Bundle.localizedString(forKey: "Tasks")).tag(0)
                        Text(Bundle.localizedString(forKey: "Study Goals")).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        // Tasks Tab
                        ScrollView {
                            VStack(spacing: 20) {
                                // Subject Filter for Homework
                                Button(action: { showingSubjectPicker = true }) {
                                    HStack {
                                        Image(systemName: "book.fill")
                                        Text(selectedSubject?.name ?? Bundle.localizedString(forKey: "All Subjects"))
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemBackground))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                
                                // Regular Tasks Section
                                if !regularCategories.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(Bundle.localizedString(forKey: "Regular Tasks"))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)
                                        
                                        LazyVStack(spacing: 20) {
                                            ForEach(regularCategories) { category in
                                                CategoryItemView(category: category,
                                                               categories: $categories,
                                                               userId: userId)
                                            }
                                        }
                                    }
                                }
                                
                                // Homework Section
                                if !homeworkCategories.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(Bundle.localizedString(forKey: "Homework"))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal)
                                        
                                        LazyVStack(spacing: 20) {
                                            ForEach(homeworkCategories) { category in
                                                CategoryItemView(category: category,
                                                               categories: $categories,
                                                               userId: userId)
                                            }
                                        }
                                    }
                                }
                                
                                NotesView(type: "taken", userId: userId)
                            }
                            .padding()
                        }
                        .tag(0)
                        
                        // Study Goals Tab
                        StudiedoelenView(userId: userId)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: selectedTab)
                }
            }
            .navigationTitle(getNavigationTitle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == 0 {
                        Button {
                            showingNewCategorySheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                NewCategoryView(categories: $categories, userId: userId)
            }
            .sheet(isPresented: $showingSubjectPicker) {
                SubjectPickerView(selectedSubject: $selectedSubject)
            }
        }
        .onAppear {
            loadCategories()
        }
    }
    
    private func getNavigationTitle() -> String {
        switch selectedTab {
        case 0: return Bundle.localizedString(forKey: "Tasks")
        case 1: return Bundle.localizedString(forKey: "Study Goals")
        default: return ""
        }
    }
    
    private func loadCategories() {
        FirebaseManager.shared.loadCategories(userId: userId) { loadedCategories in
            categories = loadedCategories
        }
    }
}
