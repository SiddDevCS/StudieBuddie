//
//  OnboardingView.swift
//  ToDoList
//
//  Created by Siddharth Sehgal on 19/01/2025.
//

import SwiftUI

struct TutorialPagina {
    let titel: String
    let ondertitel: String
    let icoonNaam: String
    let animatieNaam: String
    let achtergrondVorm: String
    let kleur: Color
    
    init(titel: String, ondertitel: String, icoonNaam: String) {
        self.titel = titel
        self.ondertitel = ondertitel
        self.icoonNaam = icoonNaam
        self.animatieNaam = icoonNaam
        self.achtergrondVorm = "circle.fill"
        self.kleur = .accentColor
    }
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var huidigePagina = 0
    let isFirstLaunch: Bool
    @Binding var showTutorial: Bool  // Add this binding
    
    // Add back the paginas property
    private let paginas: [TutorialPagina] = [
        TutorialPagina(
            titel: Bundle.localizedString(forKey: "Welcome to StudyBuddy"),
            ondertitel: Bundle.localizedString(forKey: "Your personal task management assistant to help you be more productive"),
            icoonNaam: "graduationcap"
        ),
        TutorialPagina(
            titel: Bundle.localizedString(forKey: "Manage Tasks"),
            ondertitel: Bundle.localizedString(forKey: "Create tasks, organize them into categories and track your progress"),
            icoonNaam: "list.bullet.clipboard"
        ),
        TutorialPagina(
            titel: Bundle.localizedString(forKey: "Smart Reminders"),
            ondertitel: Bundle.localizedString(forKey: "Set deadlines and receive notifications at the right time"),
            icoonNaam: "bell"
        ),
        TutorialPagina(
            titel: Bundle.localizedString(forKey: "Track Progress"),
            ondertitel: Bundle.localizedString(forKey: "View your statistics and celebrate your successes"),
            icoonNaam: "chart.bar"
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            if huidigePagina < paginas.count {
                TutorialPaginaView(
                    pagina: paginas[huidigePagina],
                    isLaatstePagina: huidigePagina == paginas.count - 1
                ) {
                    if huidigePagina < paginas.count - 1 {
                        withAnimation {
                            huidigePagina += 1
                        }
                    } else {
                        if isFirstLaunch {
                            FirstLaunchHandler.shared.setHasLaunched()
                        }
                        showTutorial = false  // This will trigger the transition
                    }
                }
            }
            
            VStack {
                Spacer()
                PaginaIndicator(aantalPaginas: paginas.count, huidigePagina: huidigePagina)
            }
        }
        .interactiveDismissDisabled(isFirstLaunch)
    }
}

struct TutorialPaginaView: View {
    let pagina: TutorialPagina
    let isLaatstePagina: Bool
    let volgendePagina: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Image(systemName: pagina.achtergrondVorm)
                    .font(.system(size: 150))
                    .foregroundColor(pagina.kleur.opacity(0.2))
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                
                Image(systemName: pagina.animatieNaam)
                    .font(.system(size: 70))
                    .foregroundColor(pagina.kleur)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)
            }
            .padding(.bottom, 30)
            
            Text(pagina.titel)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Text(pagina.ondertitel)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                if isLaatstePagina {
                    withAnimation {
                        volgendePagina()
                    }
                } else {
                    volgendePagina()
                }
            }) {
                Text(isLaatstePagina ? Bundle.localizedString(forKey: "Get Started!") : Bundle.localizedString(forKey: "Next"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct PaginaIndicator: View {
    let aantalPaginas: Int
    let huidigePagina: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<aantalPaginas, id: \.self) { index in
                Circle()
                    .fill(index == huidigePagina ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == huidigePagina ? 1.2 : 1)
                    .animation(.spring(), value: huidigePagina)
            }
        }
        .padding()
    }
}
