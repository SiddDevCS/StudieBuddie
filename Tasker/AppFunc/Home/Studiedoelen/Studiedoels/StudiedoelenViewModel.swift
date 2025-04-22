//
//  StudiedoelenViewModel.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 26/02/2025.
//

import Foundation
import FirebaseFirestore

class StudiedoelenViewModel: ObservableObject {
    @Published var studiedoelen: [Studiedoel] = []
    @Published var isLoading = true
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        loadStudiedoelen()
    }
    
    func loadStudiedoelen() {
        isLoading = true
        
        FirebaseManager.shared.loadStudiedoelen(userId: userId) { [weak self] loadedStudiedoelen in
            DispatchQueue.main.async {
                self?.studiedoelen = loadedStudiedoelen
                self?.isLoading = false
            }
        }
    }
    
    func deleteStudiedoel(_ studiedoel: Studiedoel) {
        guard let id = studiedoel.id else { return }
        
        FirebaseManager.shared.deleteStudiedoel(userId: userId, studiedoelId: id) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.studiedoelen.removeAll { $0.id == id }
                }
            }
        }
    }
}
