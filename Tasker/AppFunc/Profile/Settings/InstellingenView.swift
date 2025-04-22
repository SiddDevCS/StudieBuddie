//
//  InstellingenView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/01/2025.
//

import SwiftUI

// NotificationPreferences structure (if not already defined elsewhere)
struct NotificationPreferences {
    var dueTasks: Bool
    var dueGoals: Bool
    var timetables: Bool
    var timers: Bool
    var randomReminders: RandomReminders
    
    struct RandomReminders {
        var enabled: Bool
        var meditation: Bool
        var appEngagement: Bool
        
        static let `default` = RandomReminders(
            enabled: true,
            meditation: true,
            appEngagement: true
        )
    }
    
    static let `default` = NotificationPreferences(
        dueTasks: true,
        dueGoals: true,
        timetables: true,
        timers: true,
        randomReminders: .default
    )
}

struct InstellingenView: View {
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) var dismiss
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Bundle.localizedString(forKey: "Language"))
                    .foregroundColor(.orange)) {
                    Picker(Bundle.localizedString(forKey: "Language"), selection: $settings.selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                    .tint(.orange)
                }
                
                Section(header: Text(Bundle.localizedString(forKey: "Notifications"))
                    .foregroundColor(.orange)) {
                    Toggle(Bundle.localizedString(forKey: "Due Tasks"),
                           isOn: $settings.notificationPreferences.dueTasks)
                        .tint(.orange)
                    Toggle(Bundle.localizedString(forKey: "Study Goals"),
                           isOn: $settings.notificationPreferences.dueGoals)
                        .tint(.orange)
                    Toggle(Bundle.localizedString(forKey: "Timetables"),
                           isOn: $settings.notificationPreferences.timetables)
                        .tint(.orange)
                    Toggle(Bundle.localizedString(forKey: "Timers"),
                           isOn: $settings.notificationPreferences.timers)
                        .tint(.orange)
                }
                
                Section(
                    header: Text(Bundle.localizedString(forKey: "Extra Reminders"))
                        .foregroundColor(.orange),
                    footer: Text(Bundle.localizedString(forKey: "Receive occasional reminders for meditation and app usage"))
                ) {
                    Toggle(Bundle.localizedString(forKey: "Random Reminders"),
                           isOn: $settings.notificationPreferences.randomReminders.enabled)
                        .tint(.orange)
                    Toggle(Bundle.localizedString(forKey: "Meditation Reminders"),
                           isOn: $settings.notificationPreferences.randomReminders.meditation)
                        .tint(.orange)
                    Toggle(Bundle.localizedString(forKey: "App Engagement"),
                           isOn: $settings.notificationPreferences.randomReminders.appEngagement)
                        .tint(.orange)
                }
                
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        Text(Bundle.localizedString(forKey: "Reset All Settings"))
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(Bundle.localizedString(forKey: "Settings"))
            .navigationBarItems(trailing: Button(Bundle.localizedString(forKey: "Done")) {
                dismiss()
            })
            .tint(.orange)
            .alert(Bundle.localizedString(forKey: "Reset Settings"), isPresented: $showingResetAlert) {
                Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
                Button(Bundle.localizedString(forKey: "Reset"), role: .destructive) {
                    settings.resetToDefaults()
                }
            } message: {
                Text(Bundle.localizedString(forKey: "Are you sure you want to reset all settings to default values?"))
            }
        }
    }
}

struct InstellingenView_Previews: PreviewProvider {
    static var previews: some View {
        InstellingenView()
            .environmentObject(UserSettings())
    }
}

struct InstellingToggle: View {
    let titel: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 25)
                Text(titel)
            }
        }
        .tint(.orange)
    }
}
