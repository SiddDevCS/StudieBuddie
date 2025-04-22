//
//  PomdoroSupportingViews.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
    }
}

struct ControlButton: View {
    let action: () -> Void
    let icon: String
    let color: Color
    
    var body: some View {
        Button {
            HapticManager.shared.play(.selection)
            action()
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
        }
    }
}

struct PlayPauseButton: View {
    @Binding var isRunning: Bool
    let color: Color
    
    var body: some View {
        Button {
            withAnimation {
                isRunning.toggle()
                HapticManager.shared.play(isRunning ? .start : .stop)
            }
        } label: {
            Circle()
                .fill(color)
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                )
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

struct TimerSettingsCard: View {
    @ObservedObject var viewModel: PomodoroViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(Bundle.localizedString(forKey: "Timer Settings"))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Toggle(Bundle.localizedString(forKey: "Custom Time"), isOn: $viewModel.isCustomTime)
                .padding(.horizontal)
            
            if viewModel.isCustomTime {
                CustomTimeSettings(viewModel: viewModel)
            } else {
                PresetTimeSettings(viewModel: viewModel)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10)
        )
        .padding(.horizontal)
    }
}

struct CustomTimeSettings: View {
    @ObservedObject var viewModel: PomodoroViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                TimeInputField(
                    title: Bundle.localizedString(forKey: "Work"),
                    value: $viewModel.customWorkMinutes
                )
                
                TimeInputField(
                    title: Bundle.localizedString(forKey: "Break"),
                    value: $viewModel.customBreakMinutes
                )
            }
            .padding()
            
            Text(Bundle.localizedString(forKey: "Work: 1-120 minutes\nBreak: 1-60 minutes"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct TimeInputField: View {
    let title: String
    @Binding var value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Min", value: $value, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
                .multilineTextAlignment(.center)
                .onChange(of: value) { _ in
                    HapticManager.shared.play(.selection)
                }
        }
    }
}

struct PresetTimeSettings: View {
    @ObservedObject var viewModel: PomodoroViewModel
    
    var body: some View {
        HStack(spacing: 30) {
            VStack {
                Text("Werk")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Werk Minuten", selection: $viewModel.workMinutes) {
                    ForEach([25, 30, 35, 40, 45, 50, 55, 60], id: \.self) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 100)
                .onChange(of: viewModel.workMinutes) { _ in
                    HapticManager.shared.play(.selection)
                }
            }
            
            VStack {
                Text("Pauze")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Pauze Minuten", selection: $viewModel.breakMinutes) {
                    ForEach([5, 10, 15, 20, 25, 30], id: \.self) { minute in
                        Text("\(minute)m").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 100)
                .onChange(of: viewModel.breakMinutes) { _ in
                    HapticManager.shared.play(.selection)
                }
            }
        }
    }
}
