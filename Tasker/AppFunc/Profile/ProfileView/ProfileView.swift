//
//  ProfileView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 07/01/2025.
//

import SwiftUI
import FirebaseAuth
import WebKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var toonTutorial = false
    @State private var toonInstellingen = false
    @State private var toonPrivacyPolicy = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // User Info Card with subtle gradient
                    GebruikerInfoKaart(email: viewModel.email,
                                     lidSinds: viewModel.creationDate)
                    
                    // Action Cards
                    VStack(spacing: 15) {
                        // Tutorial Card
                        ActieKaart(
                            titel: Bundle.localizedString(forKey: "App Tutorial"),
                            beschrijving: Bundle.localizedString(forKey: "View how the app works"),
                            icon: "book.fill",
                            kleur: .blue
                        ) {
                            toonTutorial = true
                        }
                        
                        // Settings Card
                        ActieKaart(
                            titel: Bundle.localizedString(forKey: "Settings"),
                            beschrijving: Bundle.localizedString(forKey: "Customize your preferences"),
                            icon: "gear",
                            kleur: .orange
                        ) {
                            toonInstellingen = true
                        }
                        
                        // Privacy Policy Card
                        ActieKaart(
                            titel: Bundle.localizedString(forKey: "Privacy Policy"),
                            beschrijving: Bundle.localizedString(forKey: "View our privacy policy"),
                            icon: "hand.raised.fill",
                            kleur: .green
                        ) {
                            toonPrivacyPolicy = true
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                    // Sign Out Button
                    UitlogKnop(action: viewModel.signOut)
                }
                .padding(.top)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        Color(uiColor: .systemBackground).opacity(0.95),
                        Color.orange.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(Bundle.localizedString(forKey: "Profile"))
            .sheet(isPresented: $toonTutorial) {
                TutorialView(isFirstLaunch: false, showTutorial: $toonTutorial)
            }
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $toonInstellingen) {
                InstellingenView()
            }
            .sheet(isPresented: $toonPrivacyPolicy) {
                PrivacyPolicyView()
            }
        }
        .onChange(of: viewModel.isSignedIn) { oldValue, newValue in
            if !newValue {
                dismiss()
            }
        }
    }
}

struct GebruikerInfoKaart: View {
    let email: String
    let lidSinds: Date?
    
    var body: some View {
        VStack(spacing: 15) {
            // Profile Circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(0.7), .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Text(email.prefix(1).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text(email.components(separatedBy: "@")[0])
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let date = lidSinds {
                    Text("\(Bundle.localizedString(forKey: "Member since")) \(date.formatted(.dateTime.month().year()))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

struct ActieKaart: View {
    let titel: String
    let beschrijving: String
    let icon: String
    let kleur: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Icon Circle
                Circle()
                    .fill(kleur.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(kleur)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(titel)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(beschrijving)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
        }
    }
}

struct UitlogKnop: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text(Bundle.localizedString(forKey: "Sign Out"))
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(
                LinearGradient(
                    colors: [.red.opacity(0.8), .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: "https://www.termsfeed.com/live/819b0516-47bc-4385-9276-5d7d424b31b3")!)
                .navigationTitle(Bundle.localizedString(forKey: "Privacy Policy"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(Bundle.localizedString(forKey: "Done")) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
