//
//  SettingsView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/27/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var greenCardBeginDate: Date = TripPersistence.shared.loadGCResidentDate() ?? Date()

    var body: some View {
        NavigationView {
            Form {
                DatePicker("GC Resident Since", selection: $greenCardBeginDate, displayedComponents: .date)
                    .padding(.vertical, 10)
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                // Handle the save operation here
                TripPersistence.shared.saveGCResidentDate(greenCardBeginDate)
                presentationMode.wrappedValue.dismiss()
            })

        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
