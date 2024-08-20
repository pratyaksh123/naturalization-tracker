//
//  SettingsView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/27/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isActive: Bool
    @EnvironmentObject var viewModel: TripsViewModel
    @State private var showingDeleteAlert = false
    @State private var errorMessage: String = ""
    @State private var showErrorAlert = false
    @State private var isLoading = false
    
    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user is currently signed in."
            showErrorAlert = true
            return
        }
        
        let userId = user.uid
        isLoading = true  // Assume you've added an isLoading state to show a progress indicator
        
        // Step 1: Delete user trips from Firestore
        deleteFirestoreData(userId: userId) { success in
            if success {
                // Step 2: Delete user trips from iCloud
                TripPersistence.shared.deleteTrips { success in
                    if success {
                        // Step 3: Delete the Firebase Auth user
                        deleteFirebaseAuthUser(user: user)
                    } else {
                        self.errorMessage = "Failed to delete trips from iCloud."
                        self.showErrorAlert = true
                        self.isLoading = false  // Stop loading indicator
                    }
                }
            } else {
                self.errorMessage = "Failed to delete user data from Firestore."
                self.showErrorAlert = true
                self.isLoading = false  // Stop loading indicator
            }
        }
    }
    
    
    private func deleteFirestoreData(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user data from Firestore: \(error)")
                completion(false)
            } else {
                print("User data successfully deleted from Firestore.")
                completion(true)
            }
        }
    }
    
    private func deleteFirebaseAuthUser(user: User) {
        user.delete { error in
            self.isLoading = false  // Stop loading indicator
            if let error = error {
                self.errorMessage = "Error deleting account: \(error.localizedDescription)"
                self.showErrorAlert = true
            } else {
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
                if self.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding(20)
                        Spacer()
                    }
                } else {
                    
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
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                TripPersistence.shared.saveGCResidentDate(viewModel.greenCardStartDate)
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static private var isActive: Bool = false
    static var previews: some View {
        SettingsView(isActive: $isActive).environmentObject(TripsViewModel())
    }
}
