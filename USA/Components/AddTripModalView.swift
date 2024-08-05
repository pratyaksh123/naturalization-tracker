import SwiftUI

enum AlertContext {
    case freeTrialActive
    case purchasePrompt
    case alreadyPremium
    case error(String)
}

struct AddTripModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showImportModal: Bool
    @Binding var isActive: Bool
    @StateObject var viewModel: TripsViewModel
    @StateObject private var storeManager = StoreManager()
    @State private var alertContext: AlertContext?
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
                        handlePremiumCheck()
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
                switch alertContext {
                case .freeTrialActive:
                    return Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                case .purchasePrompt:
                    return Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Buy"), action: {
                            if let product = storeManager.products.first {
                                storeManager.buyProduct(product, for: viewModel.getUser()!.uid)
                            }
                        }),
                        secondaryButton: .cancel(Text("No Thanks"))
                    )
                case .alreadyPremium:
                    return Alert(
                        title: Text("Auto Import"),
                        message: Text("Thanks for purchasing the premium version! You can auto-import your trip by sending your itinerary to info@usc-tracker.com from your registered email address!"),
                        dismissButton: .default(Text("OK"))
                    )
                case .error(let message):
                    return Alert(
                        title: Text("Error"),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                default:
                    return Alert(title: Text("Unknown Error"), dismissButton: .default(Text("OK")))
                }
            }
        }
    }

    private func handlePremiumCheck() {
        let userId = viewModel.getUser()?.uid ?? ""
        FirestoreUtil.checkPremiumStatus(userId: userId) { isPremium, error in
            DispatchQueue.main.async {
                if let isPremium = isPremium {
                    if isPremium {
                        alertContext = .alreadyPremium
                        self.showingAlert = true
                    } else {
                        checkFreeTrial(userId: userId)
                    }
                } else if let error = error {
                    print("Error checking premium status: \(error.localizedDescription)")
                    alertContext = .error(error.localizedDescription)
                    self.showingAlert = true
                }
            }
        }
    }

    private func checkFreeTrial(userId: String) {
        FirestoreUtil.checkFreeTrial(userId: userId) { freeTrialActive, error in
            if let freeTrialActive = freeTrialActive {
                if freeTrialActive {
                    self.alertTitle = "Free Trial Active"
                    self.alertMessage = "You can auto-import one itinerary document as part of your free trial. Please send your itinerary to info@usc-tracker.com from your registered email address."
                    alertContext = .freeTrialActive
                } else {
                    self.alertTitle = "Purchase Premium"
                    self.alertMessage = "Your free trial has ended. Please consider purchasing our premium version for a one time fee of $4.99 for continued access to auto-import features."
                    alertContext = .purchasePrompt
                }
                self.showingAlert = true
            } else if let error = error {
                print("Error checking free trial: \(error.localizedDescription)")
                alertContext = .error(error.localizedDescription)
                self.showingAlert = true
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
