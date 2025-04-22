//
//  ZermeloAuthManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation
import SwiftUI

class ZermeloAuthManager: ObservableObject {
    static let shared = ZermeloAuthManager()
    
    @Published var isAuthenticated = false
    @Published var school: String?
    @Published var token: String?
    
    private let defaults = UserDefaults.standard
    private let tokenKey = "zermelo_token"
    private let schoolKey = "zermelo_school"
    
    private init() {
        self.token = defaults.string(forKey: tokenKey)
        self.school = defaults.string(forKey: schoolKey)
        self.isAuthenticated = token != nil
    }
    
    func authenticate(code: String, school: String) async throws {
        print("Starting OAuth authentication...")
        self.school = school
        
        guard let url = URL(string: "https://\(school).zportal.nl/api/v3/oauth/token") else {
            throw ZermeloError.invalidURL
        }
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let formBody = parameters.map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        
        request.httpBody = formBody.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            }
            
            struct AuthResponse: Codable {
                let access_token: String
                let expires_in: Int?
                let user: String?
            }
            
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            
            await MainActor.run {
                self.token = authResponse.access_token
                self.isAuthenticated = true
                self.defaults.set(self.token, forKey: self.tokenKey)
                self.defaults.set(self.school, forKey: self.schoolKey)
            }
        } catch {
            print("Authentication error: \(error)")
            throw error
        }
    }
    
    func logout() {
        Task { @MainActor in
            token = nil
            school = nil
            isAuthenticated = false
            defaults.removeObject(forKey: tokenKey)
            defaults.removeObject(forKey: schoolKey)
        }
    }
}

enum ZermeloError: Error {
    case invalidURL
    case authenticationFailed
    case networkError(String)
    case invalidResponse
    case tokenExpired
}

struct ZermeloAuthResponse: Codable {
    let token: String
    let expires: Int?
    let user: String?
}
