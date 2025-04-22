//
//  AuthView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 17/01/2025.
//

import SwiftUI

struct AuthView: View {
    @State private var showLoginView = true
    @Namespace private var animation // Add namespace for matched geometry effect
    
    var body: some View {
        NavigationView {
            ZStack {
                if showLoginView {
                    LoginView(showLoginView: $showLoginView)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading),
                                removal: .move(edge: .trailing)
                            )
                        )
                } else {
                    RegisterView(showLoginView: $showLoginView)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            )
                        )
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showLoginView)
            .navigationBarHidden(true)
        }
    }
}
