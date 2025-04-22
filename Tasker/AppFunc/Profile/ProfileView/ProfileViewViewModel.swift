//
//  ProfileViewViewModel.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 07/01/2025.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class ProfileViewViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var isSignedIn: Bool = false
    @Published var creationDate: Date?
    @Published var lastSignInDate: Date?
    @Published var userId: String = ""
    @Published var settings: UserSettings = .default
    @Published var completedTasksCount: Int = 0
    @Published var activeTasksCount: Int = 0
    @Published var totalTimeSpent: TimeInterval = 0
    
    // MARK: - Private Properties
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    init() {
        setupUserInfo()
        loadSettings()
        loadStatistics()
    }
    
    // MARK: - User Info Setup
    private func setupUserInfo() {
        if let user = Auth.auth().currentUser {
            self.email = user.email ?? "No email found"
            self.isSignedIn = true
            self.creationDate = user.metadata.creationDate
            self.lastSignInDate = user.metadata.lastSignInDate
            self.userId = user.uid
        }
    }
    
    // MARK: - Settings Management
    func loadSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId)
            .collection("settings")
            .document("preferences")
            .getDocument { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error loading settings: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data(),
                   let jsonData = try? JSONSerialization.data(withJSONObject: data),
                   let settings = try? JSONDecoder().decode(UserSettings.self, from: jsonData) {
                    DispatchQueue.main.async {
                        self?.settings = settings
                    }
                }
            }
    }
    
    func saveSettings() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let data = try? JSONEncoder().encode(settings),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            db.collection("users").document(userId)
                .collection("settings")
                .document("preferences")
                .setData(dict, merge: true) { error in
                    if let error = error {
                        print("Error saving settings: \(error.localizedDescription)")
                    }
                }
        }
    }
    
    // MARK: - Statistics Management
    private func loadStatistics() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Load completed tasks
        db.collection("users").document(userId)
            .collection("tasks")
            .whereField("isCompleted", isEqualTo: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading completed tasks: \(error.localizedDescription)")
                    return
                }
                
                if let count = snapshot?.documents.count {
                    DispatchQueue.main.async {
                        self?.completedTasksCount = count
                    }
                }
            }
        
        // Load active tasks
        db.collection("users").document(userId)
            .collection("tasks")
            .whereField("isCompleted", isEqualTo: false)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading active tasks: \(error.localizedDescription)")
                    return
                }
                
                if let count = snapshot?.documents.count {
                    DispatchQueue.main.async {
                        self?.activeTasksCount = count
                    }
                }
            }
        
        // Load total time spent
        db.collection("users").document(userId)
            .collection("statistics")
            .document("timeSpent")
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading time statistics: \(error.localizedDescription)")
                    return
                }
                
                if let timeSpent = snapshot?.data()?["totalTimeSpent"] as? TimeInterval {
                    DispatchQueue.main.async {
                        self?.totalTimeSpent = timeSpent
                    }
                }
            }
    }
    
    // MARK: - Authentication
    func signOut() {
        do {
            try AuthenticationManager.shared.signOut()
            isSignedIn = false
            
            // Reset local data
            email = ""
            creationDate = nil
            lastSignInDate = nil
            userId = ""
            settings = .default
            completedTasksCount = 0
            activeTasksCount = 0
            totalTimeSpent = 0
            
            // Clear user defaults but DO NOT clear first launch status
            let firstLaunchStatus = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.set(firstLaunchStatus, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
            
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    func formatTimeSpent() -> String {
        let hours = Int(totalTimeSpent / 3600)
        let minutes = Int((totalTimeSpent.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minutes"
        }
    }
    
    func getDaysActive() -> Int {
        guard let creationDate = creationDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
    }
    
    func getCompletionRate() -> Double {
        let total = Double(completedTasksCount + activeTasksCount)
        guard total > 0 else { return 0 }
        return Double(completedTasksCount) / total
    }
}
