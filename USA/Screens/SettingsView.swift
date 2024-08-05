//
//  SettingsView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/27/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isActive: Bool
    @EnvironmentObject var viewModel: TripsViewModel

    var body: some View {
        NavigationView {
            Form {
                DatePicker("GC Resident Since", selection: $viewModel.greenCardStartDate, displayedComponents: .date)
                    .onChange(of: viewModel.greenCardStartDate) { newDate in
                        viewModel.updateGreenCardStartDate(newDate: newDate)
                    }
                    .padding(.vertical, 10)

                Toggle("Married to U.S. Citizen", isOn: $viewModel.isMarriedToCitizen)
                    .onChange(of: viewModel.isMarriedToCitizen) { newValue in
                        viewModel.updateTimeLeft()  // Recalculate time left whenever this changes
                    }

                HStack {
                    Spacer()
                    if viewModel.isLoggedIn() {
                        Button("Sign Out") {
                            presentationMode.wrappedValue.dismiss()
                            viewModel.signOut()
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
                TripPersistence.shared.saveGCResidentDate(viewModel.greenCardStartDate)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static private var isActive: Bool = false
    static var previews: some View {
        SettingsView(isActive: $isActive).environmentObject(TripsViewModel())
    }
}
