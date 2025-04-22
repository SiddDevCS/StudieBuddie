//
//  ZermeloAuthView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import SwiftUI
import CodeScanner

struct ZermeloAuthView: View {
    @State private var school = ""
    @State private var authCode = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var isShowingScanner = false
    @State private var selectedLanguage = "English"
    
    let languages = ["English", "Dutch", "French", "Spanish"]
    
    // Dictionary for translations
    let translations: [String: [String: String]] = [
        "English": [
            "title": "Link Zermelo",
            "integration": "European School Integration",
            "description": "This feature is specifically designed for European high school students using the Zermelo platform for their class schedules.",
            "learnMore": "Learn more about Zermelo",
            "scanQR": "Scan QR Code",
            "manualEntry": "Manual Entry",
            "schoolName": "School name (e.g., school)",
            "authCode": "Authorization code",
            "login": "Login",
            "findCode": "You can find your authorization code in the Zermelo Portal under 'Link app'",
            "error": "Error",
            "ok": "OK",
            "unknownError": "Unknown error",
            "invalidQR": "Invalid QR code format",
            "language": "Language",
            "selectLanguage": "Select Language"
        ],
        "Dutch": [
            "title": "Koppel Zermelo",
            "integration": "Europese School Integratie",
            "description": "Deze functie is specifiek ontworpen voor Europese middelbare scholieren die het Zermelo-platform gebruiken voor hun lesroosters.",
            "learnMore": "Meer informatie over Zermelo",
            "scanQR": "Scan QR-code",
            "manualEntry": "Handmatige Invoer",
            "schoolName": "Schoolnaam (bijv: school)",
            "authCode": "Autorisatiecode",
            "login": "Inloggen",
            "findCode": "Je kunt je autorisatiecode vinden in het Zermelo Portal onder 'Koppel app'",
            "error": "Fout",
            "ok": "OK",
            "unknownError": "Onbekende fout",
            "invalidQR": "Ongeldig QR-code formaat",
            "language": "Taal",
            "selectLanguage": "Selecteer Taal"
        ],
        "French": [
            "title": "Lier Zermelo",
            "integration": "Intégration École Européenne",
            "description": "Cette fonctionnalité est spécialement conçue pour les lycéens européens utilisant la plateforme Zermelo pour leurs emplois du temps.",
            "learnMore": "En savoir plus sur Zermelo",
            "scanQR": "Scanner le Code QR",
            "manualEntry": "Saisie Manuelle",
            "schoolName": "Nom de l'école (ex: école)",
            "authCode": "Code d'autorisation",
            "login": "Connexion",
            "findCode": "Vous pouvez trouver votre code d'autorisation dans le portail Zermelo sous 'Lier l'application'",
            "error": "Erreur",
            "ok": "OK",
            "unknownError": "Erreur inconnue",
            "invalidQR": "Format de code QR invalide",
            "language": "Langue",
            "selectLanguage": "Sélectionner la Langue"
        ],
        "Spanish": [
            "title": "Vincular Zermelo",
            "integration": "Integración Escuela Europea",
            "description": "Esta función está específicamente diseñada para estudiantes de secundaria europeos que utilizan la plataforma Zermelo para sus horarios de clase.",
            "learnMore": "Más información sobre Zermelo",
            "scanQR": "Escanear Código QR",
            "manualEntry": "Entrada Manual",
            "schoolName": "Nombre de la escuela (ej: escuela)",
            "authCode": "Código de autorización",
            "login": "Iniciar sesión",
            "findCode": "Puede encontrar su código de autorización en el Portal Zermelo bajo 'Vincular aplicación'",
            "error": "Error",
            "ok": "OK",
            "unknownError": "Error desconocido",
            "invalidQR": "Formato de código QR inválido",
            "language": "Idioma",
            "selectLanguage": "Seleccionar Idioma"
        ]
    ]
    
    private func t(_ key: String) -> String {
        return translations[selectedLanguage]?[key] ?? translations["English"]![key]!
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 100, height: 100)
                            )
                        
                        Text(t("integration"))
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(t("description"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // QR Scanner Button
                    Button(action: { isShowingScanner = true }) {
                        HStack(spacing: 15) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title2)
                            Text(t("scanQR"))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    // Manual Entry Section
                    VStack(spacing: 20) {
                        Text(t("manualEntry"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 15) {
                            TextField(t("schoolName"), text: $school)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.horizontal)
                            
                            TextField(t("authCode"), text: $authCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.horizontal)
                        }
                        
                        Button(action: authenticate) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text(t("login"))
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                (school.isEmpty || authCode.isEmpty || isLoading) ?
                                Color.gray : Color.orange
                            )
                            .cornerRadius(15)
                        }
                        .disabled(school.isEmpty || authCode.isEmpty || isLoading)
                        .padding(.horizontal)
                        
                        Text(t("findCode"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // Language Selector
                    VStack(spacing: 10) {
                        Text(t("language"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Picker(t("selectLanguage"), selection: $selectedLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language).tag(language)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }
                    
                    // Learn More Link
                    Link(destination: URL(string: "https://zermelo.nl")!) {
                        HStack {
                            Text(t("learnMore"))
                            Image(systemName: "arrow.up.right.square")
                        }
                        .font(.footnote)
                        .foregroundColor(.orange)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle(t("title"))
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr]) { result in
                    switch result {
                    case .success(let code):
                        handleScan(code: code.string)
                    case .failure(let error):
                        self.error = error
                        self.showError = true
                    }
                    isShowingScanner = false
                }
            }
            .alert(t("error"), isPresented: $showError) {
                Button(t("ok"), role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? t("unknownError"))
            }
        }
    }
    
    private func authenticate() {
        isLoading = true
        Task {
            do {
                try await ZermeloAuthManager.shared.authenticate(
                    code: authCode,
                    school: school
                )
            } catch let zermeloError as ZermeloError {
                self.error = zermeloError
                self.showError = true
            } catch {
                self.error = error
                self.showError = true
            }
            isLoading = false
        }
    }
    
    private func handleScan(code: String) {
        print("Scanned QR code: \(code)")
        
        do {
            struct ZermeloQRCode: Codable {
                let institution: String
                let code: String
            }
            
            let qrData = try JSONDecoder().decode(ZermeloQRCode.self, from: code.data(using: .utf8)!)
            self.school = qrData.institution
            self.authCode = qrData.code
            print("Set school: \(school), code: \(authCode)")
            authenticate()
        } catch {
            print("QR decode error: \(error)")
            self.error = NSError(domain: "", code: 0,
                               userInfo: [NSLocalizedDescriptionKey: t("invalidQR")])
            self.showError = true
        }
    }
}
