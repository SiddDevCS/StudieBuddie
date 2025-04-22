//
//  MeditationHistoryView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import SwiftUI

struct MeditationHistoryView: View {
    let userId: String
    @State private var sessions: [MeditationSession] = []
    @State private var isLoading = true
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var showingDeleteAlert = false
    @State private var sessionToDelete: MeditationSession?
    @AppStorage("language") private var language = "en"
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All"
        
        var localizedName: String {
            return Bundle.localizedString(forKey: self.rawValue)
        }
    }
    
    // MARK: - Computed Properties
    private var filteredSessions: [MeditationSession] {
        let calendar = Calendar.current
        let now = Date()
        
        return sessions.filter { session in
            switch selectedTimeFrame {
            case .week:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .year)
            case .all:
                return true
            }
        }
    }
    
    private var totalMinutes: Int {
        filteredSessions.reduce(0) { $0 + $1.duration }
    }
    
    private var averageRating: Double {
        let ratings = filteredSessions.compactMap { $0.rating }
        return ratings.isEmpty ? 0 : Double(ratings.reduce(0, +)) / Double(ratings.count)
    }
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 24) {
                    statsCard
                    
                    Picker(Bundle.localizedString(forKey: "Time Period"), selection: $selectedTimeFrame) {
                        ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                            Text(timeFrame.localizedName).tag(timeFrame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if filteredSessions.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredSessions) { session in
                                MeditationSessionCard(
                                    session: session,
                                    userId: userId,
                                    sessions: $sessions
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle(Bundle.localizedString(forKey: "Meditation History"))
        .environment(\.locale, Locale(identifier: language))
        .onAppear {
            loadSessions()
        }
    }
    
    // MARK: - Supporting Views
    private var statsCard: some View {
        HStack {
            statItem(
                value: "\(totalMinutes)",
                title: Bundle.localizedString(forKey: "Minutes"),
                icon: "clock.fill"
            )
            
            Divider()
                .frame(height: 40)
            
            statItem(
                value: "\(filteredSessions.count)",
                title: Bundle.localizedString(forKey: "Sessions"),
                icon: "figure.mind.and.body"
            )
            
            Divider()
                .frame(height: 40)
            
            statItem(
                value: String(format: "%.1f", averageRating),
                title: Bundle.localizedString(forKey: "Avg. Rating"),
                icon: "star.fill"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 50))
                .foregroundColor(.purple)
            Text(Bundle.localizedString(forKey: "No meditation sessions yet"))
                .font(.headline)
            Text(Bundle.localizedString(forKey: "Your meditation journey begins with one breath"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func statItem(value: String, title: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    private func loadSessions() {
        isLoading = true
        FirebaseManager.shared.fetchMeditationSessions(for: userId) { fetchedSessions in
            sessions = fetchedSessions.sorted(by: { $0.date > $1.date })
            isLoading = false
        }
    }
}
