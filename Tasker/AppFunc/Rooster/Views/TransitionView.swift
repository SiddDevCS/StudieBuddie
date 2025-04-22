//
//  TransitionView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 27/02/2025.
//

import SwiftUI

struct TransitionView<Content: View>: View {
    let content: Content
    let viewMode: WeekScheduleView.ViewMode
    
    init(viewMode: WeekScheduleView.ViewMode, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.viewMode = viewMode
    }
    
    var body: some View {
        content
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
            .id(viewMode)
    }
}
