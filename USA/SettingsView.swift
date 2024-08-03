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
    @Binding var isActive: Bool
    @EnvironmentObject var viewModel: TripsViewModel

    var body: some View {
        NavigationView {
            Form {
                DatePicker("GC Resident Since", selection: $greenCardBeginDate, displayedComponents: .date)
                    .padding(.vertical, 10)
                HStack{
                    Spacer()
                    if viewModel.isLoggedIn() {
                        Button("Sign Out") {
                            presentationMode.wrappedValue.dismiss()
                            viewModel.signOut()
                            NavigationUtil.popToRootView()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    } else {
                        Button("Sign In") {
                            isActive = true
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                
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
    @State static private var isActive: Bool = false
    static var previews: some View {
        SettingsView(isActive: $isActive).environmentObject((TripsViewModel()))
    }
}
