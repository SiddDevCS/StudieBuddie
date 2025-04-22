//
//  RoosterView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import SwiftUI

struct RoosterView: View {
    @StateObject private var authManager = ZermeloAuthManager.shared
    
    var body: some View {
        if authManager.isAuthenticated {
            WeekScheduleView()
        } else {
            ZermeloAuthView()
        }
    }
}
