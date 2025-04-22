//
//  TaskerApp.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 17/01/2025.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import UserNotifications

@main
struct TaskerApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var settings = UserSettings()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showTutorial = FirstLaunchHandler.shared.isFirstLaunch
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Configure Firebase first, before any other operations
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("Firebase configured in TaskerApp init")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showTutorial {
                    TutorialView(isFirstLaunch: true, showTutorial: $showTutorial)
                } else {
                    MainView()
                        .environmentObject(authViewModel)
                }
            }
            .environmentObject(settings)
            .onAppear {
                setupInitialConfiguration()
            }
            .onChange(of: settings.selectedLanguage) { newLanguage in
                languageManager.setLanguage(newLanguage)
            }
        }
    }
    
    private func setupInitialConfiguration() {
        // Configure language
        languageManager.loadSavedLanguage()
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            settings.selectedLanguage = Language(rawValue: savedLanguage) ?? .english
        }
        
        // Configure auth state handling
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("User signed in with ID: \(user.uid)")
                UserDefaults.standard.set(user.uid, forKey: "currentUserId")
            } else {
                print("User signed out")
                UserDefaults.standard.removeObject(forKey: "userSignedIn")
                UserDefaults.standard.removeObject(forKey: "currentUserId")
            }
            UserDefaults.standard.synchronize()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Google Sign In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "676996401002-osavrvedvova4cuv3j206jlhd0torv7v.apps.googleusercontent.com"
        )
        
        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification notification: [AnyHashable : Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
    }
}

// MARK: - First Launch Handler
class FirstLaunchHandler: ObservableObject {
    static let shared = FirstLaunchHandler()
    private let defaults = UserDefaults.standard
    private let firstLaunchKey = "hasLaunchedBefore"
    
    @Published private(set) var isFirstLaunch: Bool
    
    private init() {
        self.isFirstLaunch = !defaults.bool(forKey: firstLaunchKey)
    }
    
    func setHasLaunched() {
        defaults.set(true, forKey: firstLaunchKey)
        DispatchQueue.main.async {
            self.isFirstLaunch = false
        }
    }
}
