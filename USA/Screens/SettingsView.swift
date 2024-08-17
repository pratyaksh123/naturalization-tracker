//
//  SettingsView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/27/24.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isActive: Bool
    @EnvironmentObject var viewModel: TripsViewModel
    @State private var showingDeleteAlert = false
    
    private func deleteUserAccount() {
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                // Handle the error possibly by showing an alert
                print("Error deleting account: \(error.localizedDescription)")
            } else {
                // Handle the user account deletion success, possibly by navigating to a login screen
                print("Account successfully deleted")
                viewModel.signOut()
                isActive = false
                presentationMode.wrappedValue.dismiss()
                NavigationUtil.popToRootView()
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("GC Resident Since", selection: $viewModel.greenCardStartDate, displayedComponents: .date)
                    .onChange(of: viewModel.greenCardStartDate) { newDate in
                        viewModel.updateGreenCardStartDate(newDate: newDate)
                    }
                    .padding(.vertical, 5)
                
                Toggle("Married to U.S. Citizen", isOn: $viewModel.isMarriedToCitizen)
                    .onChange(of: viewModel.isMarriedToCitizen) { newValue in
                        viewModel.updateTimeLeft()  // Recalculate time left whenever this changes
                    }
                    .padding(.vertical, 3)
                
                if viewModel.isLoggedIn() {
                    Button("Delete Account") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteUserAccount()
                            },
                            secondaryButton: .cancel()
                        )
                    }
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
