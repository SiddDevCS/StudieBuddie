//
//  WeekScheduleView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 16/02/2025.
//

import SwiftUI

struct WeekScheduleView: View {
    @StateObject private var viewModel = RoosterViewModel()
    @State private var selectedDate = Date()
    @State private var viewMode: ViewMode = .week
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingNewEntrySheet = false
    @State private var showingCalendar = false
    @Namespace private var animation
    
    enum ViewMode {
        case day
        case week
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Date Header with Calendar Button
                    HStack {
                        Text(periodLabel)
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Button(action: { showingCalendar.toggle() }) {
                            Image(systemName: "calendar")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    
                    // View mode selector
                    Picker("Weergave", selection: $viewMode) {
                        Text("Dag").tag(ViewMode.day)
                        Text("Week").tag(ViewMode.week)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Calendar Picker (conditionally shown)
                    if showingCalendar {
                        CalendarPickerView(
                            selectedDate: $selectedDate,
                            viewMode: $viewMode,
                            onDateSelected: { date in
                                withAnimation {
                                    showingCalendar = false
                                    Task {
                                        await loadSchedule()
                                    }
                                }
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Content
                    ScrollView {
                        RefreshControl(coordinateSpace: .named("refresh")) {
                            await loadSchedule()
                        }
                        
                        LazyVStack(spacing: 16) {
                            if viewMode == .week {
                                WeekViewContent(
                                    daysInWeek: daysInCurrentWeek,
                                    viewModel: viewModel,
                                    userId: AuthManager.shared.currentUserId ?? ""
                                )
                            } else {
                                DayViewContent(
                                    entries: entriesForDay(selectedDate),
                                    userId: AuthManager.shared.currentUserId ?? ""
                                )
                            }
                        }
                        .padding()
                    }
                    .coordinateSpace(name: "refresh")
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingNewEntrySheet = true }) {
                            Image(systemName: "plus")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: logout) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: goToToday) {
                            Image(systemName: "calendar.badge.clock")
                        }
                        Button(action: refresh) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewEntrySheet) {
                NewRoosterEntryView(
                    roosterEntries: $viewModel.entries,
                    userId: AuthManager.shared.currentUserId ?? "",
                    selectedDate: selectedDate
                )
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isLoading {
                    LoadingOverlayView()
                }
                
                if viewModel.entries.isEmpty && !isLoading {
                    EmptyStateView(viewMode: viewMode)
                }
            }
        }
        .task {
            await loadSchedule()
        }
    }
    
    private var periodLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        
        switch viewMode {
        case .day:
            formatter.dateFormat = "EEEE d MMMM yyyy"
        case .week:
            formatter.dateFormat = "d MMMM yyyy"
        }
        return formatter.string(from: selectedDate).capitalized
    }
    
    private var daysInCurrentWeek: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0...6).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
    }
    
    private func entriesForDay(_ date: Date) -> [RoosterEntry] {
        let calendar = Calendar.current
        return viewModel.entries.filter { entry in
            calendar.isDate(entry.startTime, inSameDayAs: date)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    private func previousPeriod() {
        let calendar = Calendar.current
        withAnimation {
            switch viewMode {
            case .day:
                selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
            }
        }
        Task {
            await loadSchedule()
        }
    }
    
    private func nextPeriod() {
        let calendar = Calendar.current
        withAnimation {
            switch viewMode {
            case .day:
                selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            }
        }
        Task {
            await loadSchedule()
        }
    }
    
    private func goToToday() {
        withAnimation {
            selectedDate = Date()
        }
        Task {
            await loadSchedule()
        }
    }
    
    private func refresh() {
        Task {
            await loadSchedule()
        }
    }
    
    private func loadSchedule() async {
        isLoading = true
        do {
            await viewModel.loadSchedule(for: selectedDate)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func logout() {
        ZermeloAuthManager.shared.logout()
    }
}

struct RefreshControl: View {
    let coordinateSpace: CoordinateSpace
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: coordinateSpace).midY > 50 {
                Spacer()
                    .onAppear {
                        if !isRefreshing {
                            isRefreshing = true
                            Task {
                                await onRefresh()
                                isRefreshing = false
                            }
                        }
                    }
            }
        }
        .frame(height: 0)
    }
}

#Preview {
    WeekScheduleView()
}
