//
//  MainView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 07/01/2025.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var authStateListener: AuthStateDidChangeListenerHandle?
    @State private var showTutorial = FirstLaunchHandler.shared.isFirstLaunch
    @AppStorage("keepUserSignedIn") private var keepUserSignedIn = true  // Add this line and default to true
    
    var body: some View {
        Group {
            if showTutorial {
                TutorialView(isFirstLaunch: true, showTutorial: $showTutorial)
            } else if authViewModel.isSignedIn {
                accountView
            } else {
                AuthView()
            }
        }
        .onAppear {
            // Only sign out if keepUserSignedIn is false
            if !keepUserSignedIn {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Error signing out: \(error)")
                }
            }
            
            // Set up Firebase Auth state listener
            authStateListener = Auth.auth().addStateDidChangeListener { _, user in
                authViewModel.isSignedIn = user != nil
                print("Auth state changed - User is \(user != nil ? "logged in" : "logged out")")
            }
        }
        .onDisappear {
            if let listener = authStateListener {
                Auth.auth().removeStateDidChangeListener(listener)
            }
        }
    }
    
    @ViewBuilder
    var accountView: some View {
        TabView {
            MainToDoView(userId: Auth.auth().currentUser?.uid ?? "")
                .tabItem {
                    Label(Bundle.localizedString(forKey: "Home"),
                          systemImage: "house")
                }
            
            RoosterView()
                .tabItem {
                    Label(Bundle.localizedString(forKey: "Planner"),
                          systemImage: "calendar")
                }
            
            StatisticsView(userId: Auth.auth().currentUser?.uid ?? "")
                .tabItem {
                    Label(Bundle.localizedString(forKey: "Statistics"),
                          systemImage: "chart.bar.fill")
                }
            
            ToolsView(userId: Auth.auth().currentUser?.uid ?? "")
                .tabItem {
                    Label(Bundle.localizedString(forKey: "Tools"),
                          systemImage: "hammer.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label(Bundle.localizedString(forKey: "Profile"),
                          systemImage: "person.circle")
                }
        }
        .onAppear {
            // Set the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
        }
    }
}
