//
//  AuthManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    private let zermeloAuth = ZermeloAuthManager.shared
    
    var currentUserId: String? {
        // For now, use the school as the userId
        return zermeloAuth.school
    }
    
    private init() {}
}
