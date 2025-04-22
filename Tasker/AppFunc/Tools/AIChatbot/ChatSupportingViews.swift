//
//  ChatSupportingViews.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/01/2025.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(10)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct LoadingDots: View {
    @State private var dotsCount = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(String(repeating: ".", count: (dotsCount % 4) + 1))
            .onReceive(timer) { _ in
                dotsCount += 1
            }
    }
}

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Error: \(error.localizedDescription)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.bordered)
        }
    }
}

