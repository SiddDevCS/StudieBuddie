//
//  ZermeloModels.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation

// Create this as a new file
struct ZermeloResponse: Codable {
    let response: ResponseData
    
    struct ResponseData: Codable {
        let status: Int
        let data: [ZermeloAppointment]
    }
}

struct ZermeloAppointment: Codable {
    let id: Int
    let start: Int
    let end: Int
    let subjects: [String]
    let teachers: [String]
    let locations: [String]
    let changeDescription: String
    let cancelled: Bool
}
