//
//  BiometrieManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 28/02/2025.
//

import LocalAuthentication

class BiometricManager {
    static let shared = BiometricManager()
    
    func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticate() async throws {
        let context = LAContext()
        let reason = "Sign in with biometric data"
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
