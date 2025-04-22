//
//  StatisticsView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 19/01/2025.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    let userId: String
    @State private var categories: [Category] = []
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var currentStreak: Int = 0
    @State private var showStreakInfo: Bool = false
    
    @AppStorage("language") private var language = "en"
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var localizedName: String {
            return Bundle.localizedString(forKey: self.rawValue)
        }
    }
    
    // MARK: - Computed Properties
    private var streakMessage: String {
        switch currentStreak {
        case 0:
            return Bundle.localizedString(forKey: "Start your streak today!")
        case 1:
            return Bundle.localizedString(forKey: "First day, keep going!")
        case 2...6:
            return Bundle.localizedString(forKey: "You're doing great!")
        case 7...13:
            return Bundle.localizedString(forKey: "Amazing achievement!")
        default:
            return Bundle.localizedString(forKey: "Incredible! Keep it up!")
        }
    }
    
    private var streakEmoji: String {
        switch currentStreak {
        case 0:
            return "🌱"
        case 1:
            return "🔥"
        case 2...6:
            return "🔥🔥"
        case 7...13:
            return "🔥🔥🔥"
        case 14...20:
            return "⚡️🔥⚡️"
        default:
            return "🌟🔥🌟"
        }
    }
    
    var completedTodos: Int {
        categories.reduce(0) { count, category in
            count + category.todos.filter { $0.isCompleted }.count
        }
    }
    
    var remainingTodos: Int {
        categories.reduce(0) { count, category in
            count + category.todos.filter { !$0.isCompleted }.count
        }
    }
    
    var totalTodos: Int {
        completedTodos + remainingTodos
    }
    
    var completionPercentage: Double {
        guard totalTodos > 0 else { return 0 }
        return Double(completedTodos) / Double(totalTodos) * 100
    }
    
    var completionData: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(Date, Int)] = []
        
        let days: Int
        switch selectedTimeFrame {
        case .week:
            days = 7
        case .month:
            days = 30
        case .year:
            days = 365
        }
        
        for dayOffset in (0..<days).reversed() {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let completedCount = categories.reduce(0) { count, category in
                count + category.todos.filter { todo in
                    todo.isCompleted && calendar.isDate(todo.dateCreated, inSameDayAs: date)
                }.count
            }
            data.append((date, completedCount))
        }
        
        return data
    }
    
    // MARK: - Body
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Enhanced Streak Card
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text(Bundle.localizedString(forKey: "Daily Streak"))
                                    .font(.headline)
                                Spacer()
                                
                                Button(action: { showStreakInfo = true }) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("\(currentStreak)")
                                        .font(.system(size: 40, weight: .bold))
                                    Text(Bundle.localizedString(forKey: "days"))
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 4)
                                
                                Text(streakEmoji)
                                    .font(.title)
                                
                                Text(streakMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: Color.orange.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Time frame picker
                        Picker(Bundle.localizedString(forKey: "Time Period"), selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                                Text(timeFrame.localizedName).tag(timeFrame)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Chart Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text(Bundle.localizedString(forKey: "Task Completion"))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Chart {
                                ForEach(completionData, id: \.date) { item in
                                    BarMark(
                                        x: .value(Bundle.localizedString(forKey: "Date"), item.date, unit: .day),
                                        y: .value(Bundle.localizedString(forKey: "Completed"), item.count)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color.orange,
                                                Color.orange.opacity(0.7)
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                }
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(uiColor: .systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        // Statistics cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            StatisticsCard(
                                title: Bundle.localizedString(forKey: "Completed"),
                                value: "\(completedTodos)",
                                icon: "checkmark.circle.fill"
                            )
                            StatisticsCard(
                                title: Bundle.localizedString(forKey: "Remaining"),
                                value: "\(remainingTodos)",
                                icon: "clock.fill"
                            )
                            StatisticsCard(
                                title: Bundle.localizedString(forKey: "Total"),
                                value: "\(totalTodos)",
                                icon: "list.bullet.circle.fill"
                            )
                            StatisticsCard(
                                title: Bundle.localizedString(forKey: "Completion Rate"),
                                value: String(format: "%.1f%%", completionPercentage),
                                icon: "chart.line.uptrend.xyaxis.circle.fill"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Task Overview Button
                        NavigationLink(destination: TaskOverviewView(userId: userId)) {
                            HStack {
                                Image(systemName: "list.bullet.clipboard.fill")
                                Text(Bundle.localizedString(forKey: "Task Overview"))
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(uiColor: .systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                            )
                            .padding(.horizontal)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle(Bundle.localizedString(forKey: "Statistics"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.locale, Locale(identifier: language))
        .alert(Bundle.localizedString(forKey: "About Daily Streak"), isPresented: $showStreakInfo) {
            Button(Bundle.localizedString(forKey: "OK"), role: .cancel) { }
        } message: {
            Text(Bundle.localizedString(forKey: "The daily streak shows the number of consecutive days you've completed at least one task. Keep your streak alive by staying active every day!"))
        }
        .onAppear {
            loadCategories()
            updateStreak()
        }
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        FirebaseManager.shared.loadCategories(userId: userId) { loadedCategories in
            categories = loadedCategories
        }
    }
    
    private func updateStreak() {
        StatisticsManager.shared.updateDailyStreak(userId: userId)
        currentStreak = StatisticsManager.shared.getCurrentStreak(userId: userId)
    }
}

// MARK: - Statistics Card View
struct StatisticsCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.orange.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Preview Provider
#Preview {
    StatisticsView(userId: "preview")
}
