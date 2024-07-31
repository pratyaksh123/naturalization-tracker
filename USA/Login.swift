//
//  Login.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/28/24.
//

import SwiftUI

struct Login: View {
    @State private var err : String = ""
    
    var body: some View {
        Text("Login")
        Button{
            Task {
                do {
                    try await Authentication().googleOauth()
                } catch let e {
                    print(e)
                    err = e.localizedDescription
                }
            }
        }label: {
            HStack {
                Image(systemName: "person.badge.key.fill")
                Text("Sign in with Google")
            }.padding(8)
        }.buttonStyle(.borderedProminent)
        
        Text(err).foregroundColor(.red).font(.caption)
    }
}
