//
//  User.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 18/01/2025.
//

import Foundation

struct User: Codable {
    let id: String
    let naam: String
    let email: String
    let lidSinds: TimeInterval
}
