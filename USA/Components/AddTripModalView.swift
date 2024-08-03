//
//  AddTripModalView.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 8/3/24.
//

import SwiftUI

struct AddTripModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showImportModal: Bool
    @Binding var isActive: Bool
    @StateObject var viewModel: TripsViewModel
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Button("Add Trip Manually") {
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.showModal = true
                    }
                }
                .padding(.vertical, 10)
                Button("Auto-import Trip using Email") {
                    if viewModel.isLoggedIn() {
                        print("User is signed in with ID: \(viewModel.getUser()?.uid ?? "Unknown")")
                        let userId = viewModel.getUser()?.uid ?? ""
                        FirestoreUtil.checkFreeTrial(userId: userId) { freeTrialActive, error in
                            DispatchQueue.main.async {
                                if let freeTrialActive = freeTrialActive {
                                    if freeTrialActive {
                                        self.alertTitle = "Free Trial Active"
                                        self.alertMessage = "You can auto-import one itinerary document as part of your free trial. Please send your itinerary to info@info.com from your registered email address."
                                    } else {
                                        self.alertTitle = "Purchase Premium"
                                        self.alertMessage = "Your free trial has ended. Please consider purchasing our premium version for continued access to auto-import features."
                                        // Handle prompting for premium purchase
                                    }
                                    self.showingAlert = true
                                } else if let error = error {
                                    print("Error checking free trial: \(error.localizedDescription)")
                                    // Handle error state
                                    self.alertTitle = "Error"
                                    self.alertMessage = "Failed to check free trial status: \(error.localizedDescription)"
                                    self.showingAlert = true
                                }
                            }
                        }
                    } else {
                        // Redirect to login view or handle unauthenticated state
                        presentationMode.wrappedValue.dismiss()
                        isActive = true
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationTitle("Add Trip Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct AddTripModalView_Previews: PreviewProvider {
    @State static var isActive = false
    @State static var showImportModal = false
    static var previews: some View {
        AddTripModalView(showImportModal: $showImportModal, isActive: $isActive, viewModel: TripsViewModel())
    }
}
