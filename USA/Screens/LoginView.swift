//
//  Login.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/28/24.
//

import SwiftUI

struct LoginView: View {
    @State private var err: String = ""

    var body: some View {
        VStack {
            Text("Sign in to auto-import itineraries!")
                .font(.headline)
                .padding()
            
            Image("statue_of_liberty")
                .resizable()
                .scaledToFit()
                .frame(height: 600)
                .padding(.top, 10)
            
            Button {
                Task {
                    do {
                        try await Authentication().googleOauth()
                    } catch let e {
                        print(e)
                        err = e.localizedDescription
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "person.badge.key.fill")
                    Text("Sign in with Google")
                }
                .padding(8)
            }
            .buttonStyle(.borderedProminent)
            
            if !err.isEmpty {
                Text(err)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
