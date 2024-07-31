//
//  ContentView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/28/24.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State private var userLoggedIn = (Auth.auth().currentUser != nil)

    var body: some View {
        VStack {
            if userLoggedIn {
                HomeView()
            } else {
                Login()
            }
        }.onAppear{
            //Firebase state change listeneer
            Auth.auth().addStateDidChangeListener{ auth, user in
                if (user != nil) {
                    userLoggedIn = true
                } else {
                    userLoggedIn = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
