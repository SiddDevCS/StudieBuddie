//
//  ChatViewAIopen.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import SwiftUI

struct ChatViewAIopen: View {
    let userId: String
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    @State private var showingOptions = false
    @State private var selectedCategory: StudyTipsCategory?
    
    private let suggestedPrompts = [
        "How can I study more effectively?",
        "Tips for better concentration",
        "Help with study planning",
        "How to prepare for exams?",
        "Motivation tips for difficult subjects"
    ]
    
    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ChatViewModel(userId: userId))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            categorySelector
                            suggestedPromptsView
                            
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                if viewModel.isLoading {
                    LoadingDotsView()
                        .padding()
                }
                
                chatInputArea
            }
        }
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingOptions = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(viewModel.errorTitle, isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(
                title: Text("Chat Options"),
                buttons: [
                    .default(Text("Share Chat")) { shareChat() },
                    .destructive(Text("Clear History")) { viewModel.clearHistory() },
                    .cancel()
                ]
            )
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.blue.opacity(0.05),
                Color(uiColor: .systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(StudyTipsCategory.allCases, id: \.self) { category in
                    CategoryButton(category: category) {
                        selectedCategory = category
                        viewModel.inputMessage = "Give me tips about \(category.rawValue.lowercased())"
                        Task {
                            await viewModel.sendMessage()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var suggestedPromptsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestedPrompts, id: \.self) { prompt in
                    SuggestedPromptButton(prompt: prompt) {
                        viewModel.inputMessage = prompt
                        Task {
                            await viewModel.sendMessage()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var chatInputArea: some View {
        HStack(alignment: .bottom) {
            TextField("Type a message...", text: $viewModel.inputMessage, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .disabled(viewModel.isLoading)
                .frame(minHeight: 40)
            
            Button {
                isFocused = false
                Task {
                    await viewModel.sendMessage()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(
                        viewModel.inputMessage.isEmpty || viewModel.isLoading ? .gray : .blue
                    )
                    .font(.system(size: 22))
            }
            .disabled(viewModel.inputMessage.isEmpty || viewModel.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func shareChat() {
        let chatText = viewModel.messages
            .map { message in
                message.isUser ? "Question: \(message.content)" : "Answer: \(message.content)"
            }
            .joined(separator: "\n\n")
        
        let activityVC = UIActivityViewController(
            activityItems: [chatText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Supporting Views

private struct CategoryButton: View {
    let category: StudyTipsCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(category.emoji)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .foregroundColor(.primary)
        }
    }
}

private struct SuggestedPromptButton: View {
    let prompt: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(prompt)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Study Tips Category
enum StudyTipsCategory: String, CaseIterable {
    case general = "General"
    case timeManagement = "Time Management"
    case concentration = "Concentration"
    case examPrep = "Exam Preparation"
    case motivation = "Motivation"
    case stressManagement = "Stress Management"
    
    var emoji: String {
        switch self {
        case .general: return "📚"
        case .timeManagement: return "⏰"
        case .concentration: return "🎯"
        case .examPrep: return "✍️"
        case .motivation: return "💪"
        case .stressManagement: return "🧘‍♂️"
        }
    }
}
