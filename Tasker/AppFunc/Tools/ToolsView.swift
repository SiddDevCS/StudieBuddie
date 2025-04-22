//
//  ToolsView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import SwiftUI

struct ToolsView: View {
    let userId: String
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("language") private var language = "en"
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Featured Tool
                    NavigationLink(destination: ChatViewAI(userId: userId)) {
                        FeaturedToolCard(
                            title: Bundle.localizedString(forKey: "AI Assistant"),
                            description: Bundle.localizedString(forKey: "Get help with tasks, studying, and relaxation"),
                            systemImage: "brain.head.profile",
                            color: .green
                        )
                    }
                    
                    // Tools Section
                    VStack(alignment: .leading, spacing: 25) {
                        Text(Bundle.localizedString(forKey: "Productivity Tools"))
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            NavigationLink(destination: PomodoroView(userId: userId)) {
                                ToolCard(
                                    title: Bundle.localizedString(forKey: "Pomodoro Timer"),
                                    description: Bundle.localizedString(forKey: "Focus & productivity"),
                                    systemImage: "timer",
                                    color: .red,
                                    gradient: Gradient(colors: [.red, .orange])
                                )
                            }
                            
                            NavigationLink(destination: MeditationView(userId: userId)) {
                                ToolCard(
                                    title: Bundle.localizedString(forKey: "Meditation"),
                                    description: Bundle.localizedString(forKey: "Peace & mindfulness"),
                                    systemImage: "sparkles",
                                    color: .purple,
                                    gradient: Gradient(colors: [.purple, .blue])
                                )
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding()
            }
            .background(
                ZStack {
                    Color(uiColor: .systemBackground)
                    
                    GeometryReader { geometry in
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: geometry.size.width * 0.8)
                            .position(x: geometry.size.width * 0.9, y: -geometry.size.height * 0.2)
                            .blur(radius: 50)
                        
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: geometry.size.width * 0.6)
                            .position(x: -geometry.size.width * 0.2, y: geometry.size.height * 0.8)
                            .blur(radius: 50)
                    }
                }
            )
            .navigationTitle(Bundle.localizedString(forKey: "Tools"))
        }
        .environment(\.locale, Locale(identifier: language))
    }
}

struct FeaturedToolCard: View {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(color.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: color.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

struct ToolCard: View {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    let gradient: Gradient
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(
                            gradient: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color.opacity(0.3))
            }
        }
        .padding(16)
        .frame(height: 180) // Increased height
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: color.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

#Preview {
    ToolsView(userId: "preview")
}
