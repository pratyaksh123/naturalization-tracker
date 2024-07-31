//
//  UserAuth.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/30/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

class UserAuth: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user: User? = nil
    
    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
        
        // Attach listener to Firebase Auth
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.isLoggedIn = user != nil
            self?.user = user
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.user = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
