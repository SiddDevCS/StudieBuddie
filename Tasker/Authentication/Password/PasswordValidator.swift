//
//  WachtwoordValidator.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import Foundation

struct PasswordValidator {
    static func validate(_ password: String) -> (isValid: Bool, message: String) {
        let minLength = 8
        let maxLength = 128
        
        guard password.count >= minLength else {
            return (false, "Password must contain at least \(minLength) characters")
        }
        
        guard password.count <= maxLength else {
            return (false, "Password cannot exceed \(maxLength) characters")
        }
        
        let hasUppercase = password.contains(where: { $0.isUppercase })
        let hasLowercase = password.contains(where: { $0.isLowercase })
        let hasNumber = password.contains(where: { $0.isNumber })
        let hasSpecialCharacter = password.contains(where: { "!@#$%^&*()_+-=[]{}|;:,.<>?".contains($0) })
        
        if !hasUppercase { return (false, "Password must contain at least one uppercase letter") }
        if !hasLowercase { return (false, "Password must contain at least one lowercase letter") }
        if !hasNumber { return (false, "Password must contain at least one number") }
        if !hasSpecialCharacter { return (false, "Password must contain at least one special character") }
        
        return (true, "")
    }
}
