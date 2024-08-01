//
//  ImportTripView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/31/24.
//

import SwiftUI

struct ImportTripView: View {
    var body: some View {
        VStack {
            Text("Import Your Itinerary Using Email")
                .font(.title)
                .padding()

            Text("Send your travel itinerary to info@pratyaksh.com to automatically add your trips.")
                .multilineTextAlignment(.center)
                .padding()

            Button("Close") {
                // Close the modal
            }
        }
        .padding()
    }
}


#Preview {
    ImportTripView()
}
