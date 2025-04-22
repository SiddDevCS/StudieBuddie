//
//  ChatViewAI.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 26/02/2025.
//

import SwiftUI

struct ChatViewAI: View {
    @StateObject private var viewModel: StudyCoachViewModel
    @ObservedObject private var usageTracker = AIUsageTracker.shared
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: StudyCoachViewModel(userId: userId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Weekly AI Uses: \(usageTracker.weeklyUsageCount)/4")
                    .font(.footnote)
                    .foregroundColor(usageTracker.weeklyUsageCount >= 4 ? .red : .secondary)
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            if viewModel.isLoading {
                LoadingDotsView()
                    .padding()
            }
            
            VStack(spacing: 0) {
                Divider()
                HStack {
                    TextField("Ask me anything about studying...", text: $viewModel.inputMessage)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.isLoading || usageTracker.weeklyUsageCount >= 4)
                    
                    Button {
                        Task {
                            if usageTracker.weeklyUsageCount >= 4 {
                                viewModel.showError(.weeklyLimitExceeded)
                                return
                            }
                            
                            do {
                                try usageTracker.incrementUsage()
                                await viewModel.sendMessage()
                            } catch {
                                viewModel.showError(error as? ChatError ?? .unknown)
                            }
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(
                                viewModel.inputMessage.isEmpty ||
                                viewModel.isLoading ||
                                usageTracker.weeklyUsageCount >= 4 ? .gray : .blue
                            )
                            .font(.system(size: 22))
                    }
                    .disabled(
                        viewModel.inputMessage.isEmpty ||
                        viewModel.isLoading ||
                        usageTracker.weeklyUsageCount >= 4
                    )
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Study Coach")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            usageTracker.loadWeeklyUsage()
        }
        .alert(viewModel.errorTitle, isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
