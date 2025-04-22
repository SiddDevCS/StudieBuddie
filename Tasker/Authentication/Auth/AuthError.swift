//
//  AuthError.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 26/01/2025.
//

import Foundation

enum AuthError: LocalizedError {
    case emptyFields
    case invalidEmail
    case invalidPassword
    case emailNotVerified
    case networkError
    case userDisabled
    case tooManyAttempts
    case signOutFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please fill in all fields"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Invalid password"
        case .emailNotVerified:
            return "Please verify your email first"
        case .networkError:
            return "Please check your internet connection"
        case .userDisabled:
            return "This account has been disabled"
        case .tooManyAttempts:
            return "Too many attempts. Please try again later"
        case .signOutFailed:
            return "Sign out failed"
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
}
