//
//  ZermeloManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import Foundation

class ZermeloManager {
    static let shared = ZermeloManager()
    private let authManager = ZermeloAuthManager.shared
    
    private var baseURL: String {
        guard let school = authManager.school else {
            return ""
        }
        return "https://\(school).zportal.nl/api/v3"
    }
    
    func fetchSchedule(start: Int, end: Int) async throws -> [ZermeloAppointment] {
        guard let token = authManager.token, let school = authManager.school else {
            throw ZermeloError.authenticationFailed
        }
        
        let urlString = "https://\(school).zportal.nl/api/v3/appointments"
        var components = URLComponents(string: urlString)
        
        components?.queryItems = [
            URLQueryItem(name: "user", value: "~me"),
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "start", value: String(start)),
            URLQueryItem(name: "end", value: String(end)),
            URLQueryItem(name: "fields", value: "id,start,end,startTimeSlot,endTimeSlot,subjects,teachers,locations,groups,cancelled,changeDescription")
        ]
        
        guard let url = components?.url else {
            throw ZermeloError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let scheduleResponse = try JSONDecoder().decode(ZermeloResponse.self, from: data)
        return scheduleResponse.response.data
    }
}
