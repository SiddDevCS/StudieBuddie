//
//  MeditationView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 21/01/2025.
//

import SwiftUI
import CoreHaptics

struct MeditationView: View {
    @StateObject private var viewModel = MeditationViewModel()
    @State private var selectedType: MeditationType = .meditation
    @State private var selectedPattern: BreathingPattern = .boxBreathing
    @State private var selectedTime = 5
    @State private var isPlaying = false
    @State private var engine: CHHapticEngine?
    @AppStorage("language") private var language = "en"
    let userId: String
    
    // Add available times array
    private let availableTimes = [5, 10, 15, 20, 25, 30, 45, 60]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                VStack(spacing: 0) {
                    typeSelector
                    
                    TabView(selection: $selectedType) {
                        ScrollView(showsIndicators: false) {
                            meditationContent(geometry: geometry)
                        }
                        .tag(MeditationType.meditation)
                        
                        ScrollView(showsIndicators: false) {
                            breathingContent(geometry: geometry)
                        }
                        .tag(MeditationType.breathing)
                    }
                }
            }
        }
        .navigationTitle(Bundle.localizedString(forKey: "Meditation"))
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.locale, Locale(identifier: language))
    }
    
    // MARK: - Type Selector
    private var typeSelector: some View {
        HStack(spacing: 0) {
            ForEach([MeditationType.meditation, .breathing], id: \.self) { type in
                Button {
                    withAnimation {
                        selectedType = type
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: type == .meditation ? "brain.head.profile" : "lungs.fill")
                            .font(.title3)
                        Text(type.localizedName)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedType == type ?
                                  Color.purple.opacity(0.15) :
                                    Color.clear)
                    )
                    .foregroundColor(selectedType == type ? .purple : .secondary)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
        .padding(.top)
    }
    
    // MARK: - UI Components
    private var segmentedTypeSelector: some View {
        HStack(spacing: 0) {
            ForEach([MeditationType.meditation, .breathing], id: \.self) { type in
                Button {
                    withAnimation {
                        selectedType = type
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: type == .meditation ? "brain.head.profile" : "lungs.fill")
                            .font(.title3)
                        Text(type.rawValue)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(selectedType == type ?
                                  Color.purple.opacity(0.15) :
                                    Color.clear)
                    )
                    .foregroundColor(selectedType == type ? .purple : .secondary)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.15),
                Color.blue.opacity(0.1),
                Color(uiColor: .systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Meditation Content
    private func meditationContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            // Timer Circle
            ZStack {
                // Background circles for depth
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.purple.opacity(0.05), lineWidth: 20 - Double(i * 5))
                }
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: isPlaying ? 1 - (Double(viewModel.timeRemaining) / Double(selectedTime * 60)) : 0)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.timeRemaining)
                
                // Time display
                VStack(spacing: 8) {
                    Text(viewModel.timeRemainingText)
                        .font(.system(size: 60, design: .rounded))
                        .fontWeight(.light)
                        .foregroundColor(.purple)
                        .contentTransition(.numericText())
                    
                    if isPlaying {
                        Text(viewModel.settings.focus.rawValue)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: geometry.size.width * 0.7)
            .padding(.vertical)
            
            if !isPlaying {
                // Focus Areas
                VStack(alignment: .leading, spacing: 16) {
                    Text("Focus Gebied")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(MeditationFocus.allCases, id: \.self) { focus in
                            FocusCard(
                                focus: focus,
                                isSelected: viewModel.settings.focus == focus,
                                action: {
                                    withAnimation {
                                        viewModel.settings.focus = focus
                                        selectedTime = focus.recommendedDuration
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                // Settings Card
                settingsCard
                    .padding(.horizontal)
            }
            
            // Control Buttons
            HStack(spacing: 40) {
                // Stop button (if playing)
                if isPlaying {
                    Button {
                        withAnimation {
                            viewModel.stopSession()
                            isPlaying = false
                            StatisticsManager.shared.incrementMeditationSessions(userId: userId)
                        }
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(
                                Color.red.opacity(0.8)
                            )
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 60, height: 60)
                            )
                    }
                }
                
                // Play/Pause button
                Button {
                    withAnimation {
                        if isPlaying {
                            viewModel.pauseSession()
                        } else {
                            viewModel.startSession(
                                type: selectedType,
                                pattern: selectedPattern,
                                duration: selectedTime * 60
                            )
                            if viewModel.settings.backgroundSound != .none {
                                viewModel.playBackgroundSound(viewModel.settings.backgroundSound)
                            }
                            viewModel.startIntervalTimer()
                        }
                        isPlaying.toggle()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            Circle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 88, height: 88)
                        )
                }
            }
            .padding(.vertical, 30)
        }
        .padding(.vertical)
    }
    
    private var settingsCard: some View {
        VStack(spacing: 24) {
            // Duration Picker
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.purple)
                    Text("Duur")
                        .font(.headline)
                }
                
                HStack(spacing: 12) {
                    ForEach(availableTimes, id: \.self) { time in
                        Button {
                            withAnimation {
                                selectedTime = time
                            }
                        } label: {
                            Text("\(time)m")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(selectedTime == time ? .semibold : .regular)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedTime == time ?
                                              Color.purple.opacity(0.15) :
                                                Color(uiColor: .secondarySystemBackground)
                                             )
                                )
                                .foregroundColor(selectedTime == time ? .purple : .secondary)
                        }
                    }
                }
            }
            
            // Background Sound
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.purple)
                    Text("Sfeergeluid")
                        .font(.headline)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(BackgroundSound.allCases, id: \.self) { sound in
                            Button {
                                withAnimation {
                                    viewModel.settings.backgroundSound = sound
                                    if sound != .none {
                                        viewModel.playBackgroundSound(sound)
                                    }
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: sound.icon)
                                        .font(.title2)
                                    Text(sound.rawValue)
                                        .font(.caption)
                                }
                                .frame(width: 80)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(viewModel.settings.backgroundSound == sound ?
                                              Color.purple.opacity(0.15) :
                                                Color(uiColor: .secondarySystemBackground))
                                )
                                .foregroundColor(viewModel.settings.backgroundSound == sound ?
                                    .purple : .secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                
                if viewModel.settings.backgroundSound != .none {
                    HStack {
                        Image(systemName: "speaker.wave.1")
                            .foregroundColor(.secondary)
                        Slider(value: $viewModel.settings.soundVolume)
                            .tint(.purple)
                        Image(systemName: "speaker.wave.3")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
            
            // Guidance Level
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.wave.2")
                        .foregroundColor(.purple)
                    Text("Begeleiding")
                        .font(.headline)
                }
                
                HStack(spacing: 12) {
                    ForEach(GuidanceLevel.allCases, id: \.self) { level in
                        Button {
                            withAnimation {
                                viewModel.settings.guidanceLevel = level
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: level.icon)
                                    .font(.title3)
                                Text(level.rawValue)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.settings.guidanceLevel == level ?
                                          Color.purple.opacity(0.15) :
                                            Color(uiColor: .secondarySystemBackground))
                            )
                            .foregroundColor(viewModel.settings.guidanceLevel == level ?
                                .purple : .secondary)
                        }
                    }
                }
            }
            
            // Interval Settings
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $viewModel.settings.useInterval) {
                    HStack {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.purple)
                        Text("Interval Bel")
                            .font(.headline)
                    }
                }
                .tint(.purple)
                
                if viewModel.settings.useInterval {
                    HStack {
                        Text("Elke")
                            .foregroundColor(.secondary)
                        Picker("", selection: $viewModel.settings.intervalDuration) {
                            ForEach([30, 60, 90, 120, 180, 300], id: \.self) { seconds in
                                Text(seconds.formattedInterval).tag(seconds)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 100)
                    }
                }
                
                Toggle(isOn: $viewModel.settings.endBellEnabled) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.purple)
                        Text("Eindbel")
                            .font(.headline)
                    }
                }
                .tint(.purple)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
    
    // Add this after the settingsCard
    
    // MARK: - Breathing Content
    private func breathingContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            // Breathing Pattern Selection
            VStack(alignment: .leading, spacing: 16) {
                Text("Ademhalingspatroon")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                            BreathingPatternCard(
                                pattern: pattern,
                                isSelected: selectedPattern == pattern,
                                action: {
                                    withAnimation {
                                        selectedPattern = pattern
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Breathing Circle
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.1), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: isPlaying ? viewModel.breathingProgress : 0)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    if isPlaying {
                        Text(viewModel.breathingPhase.rawValue)
                            .font(.title)
                            .foregroundColor(.purple)
                            .transition(.opacity)
                        
                        Text(String(format: "%.1fs", viewModel.phaseTimeRemaining))
                            .font(.title3)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(selectedTime) min")
                            .font(.title)
                            .foregroundColor(.purple)
                    }
                }
            }
            .frame(height: geometry.size.width * 0.7)
            .padding(.vertical)
            .animation(.linear(duration: 0.1), value: viewModel.breathingProgress)
            
            if !isPlaying {
                // Duration Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duur")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(availableTimes, id: \.self) { time in
                            Button {
                                withAnimation {
                                    selectedTime = time
                                }
                            } label: {
                                Text("\(time)m")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(selectedTime == time ? .semibold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedTime == time ?
                                                  Color.purple.opacity(0.15) :
                                                    Color(uiColor: .secondarySystemBackground))
                                    )
                                    .foregroundColor(selectedTime == time ? .purple : .secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Control Buttons (reuse the same buttons as meditation content)
            HStack(spacing: 40) {
                if isPlaying {
                    Button {
                        withAnimation {
                            viewModel.stopSession()
                            isPlaying = false
                            StatisticsManager.shared.incrementMeditationSessions(userId: userId)
                        }
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundStyle(Color.red.opacity(0.8))
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 60, height: 60)
                            )
                    }
                }
                
                Button {
                    withAnimation {
                        if isPlaying {
                            viewModel.pauseSession()
                        } else {
                            viewModel.startSession(
                                type: selectedType,
                                pattern: selectedPattern,
                                duration: selectedTime * 60
                            )
                        }
                        isPlaying.toggle()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            Circle()
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 88, height: 88)
                        )
                }
            }
            .padding(.vertical, 30)
        }
        .padding(.vertical)
    }
    
    // MARK: - Haptics
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error creating haptic engine: \(error.localizedDescription)")
        }
    }

    private func playHapticForPhase(_ phase: BreathingPhase) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        do {
            let events: [CHHapticEvent]
            
            switch phase {
            case .inhale:
                // Gradual increase in intensity for inhale
                events = [
                    CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                            CHHapticEventParameter(parameterID: .attackTime, value: 0.1),
                            CHHapticEventParameter(parameterID: .decayTime, value: 0.1),
                            CHHapticEventParameter(parameterID: .sustained, value: 1.0)
                        ],
                        relativeTime: 0,
                        duration: 0.5
                    )
                ]
            case .hold:
                // Pulsing pattern for hold
                events = (0..<3).map { i in
                    CHHapticEvent(
                        eventType: .hapticTransient,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                        ],
                        relativeTime: Double(i) * 0.3
                    )
                }
            case .exhale:
                // Gradual decrease in intensity for exhale
                events = [
                    CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                            CHHapticEventParameter(parameterID: .attackTime, value: 0.1),
                            CHHapticEventParameter(parameterID: .decayTime, value: 0.4),
                            CHHapticEventParameter(parameterID: .releaseTime, value: 0.3)
                        ],
                        relativeTime: 0,
                        duration: 0.8
                    )
                ]
            case .rest:
                // Gentle pulse for rest
                events = [
                    CHHapticEvent(
                        eventType: .hapticTransient,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                        ],
                        relativeTime: 0
                    )
                ]
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}
