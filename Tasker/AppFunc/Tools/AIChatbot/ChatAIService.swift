//
//  ChatAIService.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 17/02/2025.
//

import Foundation
import SwiftUI

@MainActor
class ChatAIService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showingError = false
    @Published var errorTitle = ""
    @Published var errorMessage = ""
    
    private let userId: String
    private let endpoint = "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2"
    private let apiKey = "YOUR_API_KEY_HERE" // Replace with your Hugging Face API key
    private let storageKey: String
    
    // Inappropriate content filter
    private let inappropriateWords = ["inappropriate", "offensive", "nsfw"]
    
    init(userId: String) {
        self.userId = userId
        self.storageKey = "ai_chat_history_\(userId)"
        
        if let savedMessages = loadMessages() {
            self.messages = savedMessages
        } else {
            messages.append(ChatMessage(
                content: "Hello! I'm your AI assistant. I can help you with various tasks, including productivity, learning, and general questions. How can I assist you today?",
                isUser: false
            ))
        }
    }
    
    func showError(_ error: ChatError) {
        errorTitle = "AI Service Error"
        errorMessage = error.localizedDescription
        showingError = true
    }
    
    func sendMessage() async {
        guard !inputMessage.isEmpty else { return }
        guard !containsInappropriateContent(inputMessage) else {
            showError(.inappropriateContent)
            return
        }
        
        // Check weekly usage limit
        if AIUsageTracker.shared.weeklyUsageCount >= 4 {
            showError(.weeklyLimitExceeded)
            return
        }
        
        let userMessage = inputMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        inputMessage = ""
        
        let message = ChatMessage(content: userMessage, isUser: true)
        messages.append(message)
        saveMessages()
        
        isLoading = true
        
        do {
            try AIUsageTracker.shared.incrementUsage()
            let response = try await generateResponse(to: userMessage)
            messages.append(ChatMessage(content: response, isUser: false))
            saveMessages()
        } catch {
            showError(error as? ChatError ?? .unknown)
        }
        
        isLoading = false
    }
    
    private func containsInappropriateContent(_ text: String) -> Bool {
        let lowercasedText = text.lowercased()
        return inappropriateWords.contains { lowercasedText.contains($0) }
    }
    
    private func generateResponse(to message: String) async throws -> String {
        guard let url = URL(string: endpoint) else {
            throw ChatError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        <s>[INST] You are a helpful AI assistant. Please provide a clear and concise response. 
        Here's the user's message: \(message) [/INST]
        """
        
        let body: [String: Any] = [
            "inputs": prompt,
            "parameters": [
                "max_new_tokens": 500,
                "temperature": 0.7,
                "top_p": 0.95,
                "do_sample": true,
                "return_full_text": false
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatError.networkError
        }
        
        if httpResponse.statusCode != 200 {
            throw ChatError.serverError
        }
        
        guard let responseArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let firstResponse = responseArray.first,
              let generatedText = firstResponse["generated_text"] as? String else {
            throw ChatError.invalidResponse
        }
        
        let cleanedResponse = generatedText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[INST]", with: "")
            .replacingOccurrences(of: "[/INST]", with: "")
            .replacingOccurrences(of: "<s>", with: "")
            .replacingOccurrences(of: "</s>", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanedResponse.isEmpty ? "I apologize, but I couldn't generate a proper response. Could you rephrase your question?" : cleanedResponse
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadMessages() -> [ChatMessage]? {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            return decoded
        }
        return nil
    }
}
