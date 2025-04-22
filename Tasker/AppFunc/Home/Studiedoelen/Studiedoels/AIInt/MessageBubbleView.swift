//
//  MessageBubbleView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/02/2025.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var hasAnimated = false
    private let typingInterval: TimeInterval = 0.01
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading) {
                if message.isUser {
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                } else {
                    Text(displayedText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                        .onAppear {
                            // Only animate if this is a new message (within last 2 seconds)
                            if !hasAnimated && Date().timeIntervalSince(message.timestamp) < 2 {
                                startTypingAnimation()
                            } else {
                                // For older messages, just display the full text
                                displayedText = message.content
                            }
                        }
                }
            }
            
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    private func startTypingAnimation() {
        guard !message.isUser && !isTyping else { return }
        isTyping = true
        
        let characters = Array(message.content)
        displayedText = ""
        
        let timer = Timer.scheduledTimer(withTimeInterval: typingInterval, repeats: true) { timer in
            DispatchQueue.main.async {
                if self.displayedText.count < characters.count {
                    self.displayedText += String(characters[self.displayedText.count])
                } else {
                    timer.invalidate()
                    self.isTyping = false
                    self.hasAnimated = true
                }
            }
        }
        
        RunLoop.current.add(timer, forMode: .common)
    }
}
