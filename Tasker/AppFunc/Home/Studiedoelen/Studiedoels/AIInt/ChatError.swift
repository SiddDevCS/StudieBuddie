//
//  ChatError.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 24/03/2025.
//

import Foundation

enum ChatError: LocalizedError {
    case weeklyLimitExceeded
    case invalidInput
    case networkError
    case unknown
    case unauthorized
    case invalidResponse
    case serverError
    case invalidURL
    case inappropriateContent
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .weeklyLimitExceeded:
            return "Weekly limit of 4 AI uses has been reached. Please try again next week."
        case .invalidInput:
            return "Please enter a valid message."
        case .networkError:
            return "Network error occurred. Please check your connection and try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        case .unauthorized:
            return "Unauthorized access. Please sign in again."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .serverError:
            return "Server error occurred. Please try again later."
        case .invalidURL:
            return "Invalid service URL. Please contact support."
        case .inappropriateContent:
            return "Please ensure your message is appropriate and try again."
        case .rateLimited:
            return "The AI service is currently busy. Please wait a moment and try again."
        }
    }
}
