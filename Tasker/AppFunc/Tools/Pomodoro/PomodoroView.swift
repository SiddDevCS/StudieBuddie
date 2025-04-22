//
//  PomodoroView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import SwiftUI
import UserNotifications
import UIKit

struct PomodoroView: View {
    @StateObject private var viewModel = PomodoroViewModel()
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("language") private var language = "en"  // Add this line
    let userId: String
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.15),
                    Color.red.opacity(0.1),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Stats Card
                    HStack(spacing: 20) {
                        StatCard(
                            title: Bundle.localizedString(forKey: "Sessions Today"),
                            value: "\(viewModel.todaysSessions)",
                            icon: "chart.bar.fill"
                        )
                        
                        StatCard(
                            title: Bundle.localizedString(forKey: "Total Focus Time"),
                            value: viewModel.totalFocusTimeFormatted,
                            icon: "clock.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Timer Display
                    ZStack {
                        // Background circles for depth
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(lineWidth: 20 - Double(i * 5))
                                .opacity(0.05)
                        }
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                LinearGradient(
                                    colors: viewModel.isWorkTime ?
                                        [.orange, .red] : [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(
                                    lineWidth: 20,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.progress)
                        
                        // Time Display
                        VStack(spacing: 8) {
                            Text(viewModel.timeString)
                                .font(.system(size: 65, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.5)
                            
                            Text(viewModel.isWorkTime ?
                                 Bundle.localizedString(forKey: "Focus Time") :
                                 Bundle.localizedString(forKey: "Break Time"))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            if viewModel.isRunning {
                                Text("\(Bundle.localizedString(forKey: "Ends at")) \(viewModel.endTimeFormatted)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(25)
                    .frame(height: UIScreen.main.bounds.height * 0.35)
                    
                    // Control Buttons
                    HStack(spacing: 50) {
                        ControlButton(
                            action: viewModel.resetTimer,
                            icon: "arrow.counterclockwise",
                            color: .orange
                        )
                        
                        PlayPauseButton(
                            isRunning: $viewModel.isRunning,
                            color: viewModel.isWorkTime ? .orange : .green
                        )
                        
                        ControlButton(
                            action: {
                                viewModel.skipInterval()
                                if !viewModel.isWorkTime {
                                    StatisticsManager.shared.incrementPomodoroSessions(userId: userId)
                                }
                            },
                            icon: "forward.fill",
                            color: .orange
                        )
                    }
                    .padding(.bottom)
                    
                    // Settings Card
                    TimerSettingsCard(viewModel: viewModel)
                }
                .padding()
            }
        }
        .navigationTitle(Bundle.localizedString(forKey: "Pomodoro Timer"))
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.locale, Locale(identifier: language))  // Add this line
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.updateTimer()
            }
        }
        .onChange(of: viewModel.sessionCompleted) { completed in
            if completed {
                StatisticsManager.shared.incrementPomodoroSessions(userId: userId)
            }
        }
    }
}

#Preview {
    NavigationView {
        PomodoroView(userId: "preview")
    }
}
