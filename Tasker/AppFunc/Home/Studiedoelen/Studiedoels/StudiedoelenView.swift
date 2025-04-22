//
//  StudiedoelenView.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 20/01/2025.
//

import SwiftUI

struct StudiedoelenView: View {
    @StateObject private var viewModel: StudiedoelenViewModel
    @State private var activeSheet: ActiveSheet?
    @State private var selectedStudiedoel: Studiedoel?
    @State private var showingDeleteAlert = false
    @State private var studiedoelToDelete: Studiedoel?
    
    init(userId: String) {
        _viewModel = StateObject(wrappedValue: StudiedoelenViewModel(userId: userId))
    }
    
    enum ActiveSheet: Identifiable {
        case new, edit(Studiedoel), aiChat
        
        var id: Int {
            switch self {
            case .new: return 0
            case .edit: return 1
            case .aiChat: return 2
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(viewModel.studiedoelen) { studiedoel in
                StudiedoelItemView(
                    studiedoel: studiedoel,
                    studiedoelen: $viewModel.studiedoelen,
                    userId: viewModel.userId,
                    onAICoachTap: {
                        selectedStudiedoel = studiedoel
                        activeSheet = .aiChat
                    }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        studiedoelToDelete = studiedoel
                        showingDeleteAlert = true
                    } label: {
                        Label(Bundle.localizedString(forKey: "Delete"), systemImage: "trash")
                    }
                    
                    Button {
                        activeSheet = .edit(studiedoel)
                    } label: {
                        Label(Bundle.localizedString(forKey: "Edit"), systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Bundle.localizedString(forKey: "Study Goals"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    activeSheet = .new
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            NavigationView {
                switch sheet {
                case .new:
                    NewStudiedoelView(userId: viewModel.userId)
                case .edit(let studiedoel):
                    EditStudiedoelView(
                        studiedoel: studiedoel,
                        studiedoelen: $viewModel.studiedoelen,
                        userId: viewModel.userId
                    )
                case .aiChat:
                    ChatViewAI(userId: viewModel.userId)
                }
            }
        }
        .alert(Bundle.localizedString(forKey: "Delete Study Goal?"), isPresented: $showingDeleteAlert) {
            Button(Bundle.localizedString(forKey: "Cancel"), role: .cancel) { }
            Button(Bundle.localizedString(forKey: "Delete"), role: .destructive) {
                if let studiedoel = studiedoelToDelete {
                    viewModel.deleteStudiedoel(studiedoel)
                }
            }
        } message: {
            Text(Bundle.localizedString(forKey: "Are you sure you want to delete this study goal?"))
        }
        .onAppear {
            viewModel.loadStudiedoelen()
        }
    }
}
