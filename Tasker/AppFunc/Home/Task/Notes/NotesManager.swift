//
//  NotesManager.swift
//  Tasker
//
//  Created by Siddharth Sehgal on 25/01/2025.
//

import UIKit

class NotesManager {
    static let shared = NotesManager()
    
    func createNote(title: String, content: String, from viewController: UIViewController) {
        let fullContent = """
        \(title)
        
        \(content)
        """
        
        let encodedContent = fullContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let notesUrl = URL(string: "notes://addnote?text=\(encodedContent)") {
            UIApplication.shared.open(notesUrl) { success in
                if !success {
                    UIPasteboard.general.string = fullContent
                    self.showAlert(
                        title: "Notitie Gemaakt",
                        message: "De notitie is gekopieerd naar je klembord.",
                        on: viewController
                    )
                }
            }
        } else {
            UIPasteboard.general.string = fullContent
            showAlert(
                title: "Notitie Gemaakt",
                message: "De notitie is gekopieerd naar je klembord.",
                on: viewController
            )
        }
    }
    
    private func showAlert(title: String, message: String, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}
