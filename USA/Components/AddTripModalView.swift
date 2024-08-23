import SwiftUI
import Sentry

enum AlertContext: Identifiable {
    case freeTrialActive
    case purchasePrompt
    case alreadyPremium
    case restored
    case error(String)
    
    var id: String {
        switch self {
        case .freeTrialActive: return "freeTrialActive"
        case .purchasePrompt: return "purchasePrompt"
        case .alreadyPremium: return "alreadyPremium"
        case .restored: return "restored"
        case .error(let message): return "error-\(message)"
        }
    }
}


struct AddTripModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showImportModal: Bool
    @Binding var isActive: Bool
    @StateObject var viewModel: TripsViewModel
    @State private var alertContext: AlertContext? = nil
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @StateObject private var storeManager = StoreManager()
    
    private func setupCallbacks() {
        storeManager.onRestoreCompleted = {
            alertContext = .restored
        }
        storeManager.onError = { errorMessage in
            alertContext = .error(errorMessage)
        }
    }
    
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
                        presentationMode.wrappedValue.dismiss()
                        isActive = true
                    }
                }
                .padding(.vertical, 10)
                
                Button("Restore Subscriptions") {
                    storeManager.restorePurchases()
                }
                .padding(.vertical, 10)
                
//                Button("Exhaust Free Trial") {
//                    if let userId = viewModel.getUser()?.uid {
//                        FirestoreUtil.exhaustFreeTrial(userId: userId) { success, error in
//                            if success {
//                                alertTitle = "Free Trial Exhausted"
//                                alertMessage = "The free trial has been manually exhausted for testing purposes."
//                                alertContext = .freeTrialActive // Update this to a more appropriate alert context if needed
//                            } else {
//                                alertTitle = "Error"
//                                alertMessage = "Failed to exhaust the free trial: \(error?.localizedDescription ?? "Unknown error")"
//                                alertContext = .error(alertMessage)
//                            }
//                        }
//                    }
//                }
//                .padding(.vertical, 10)
            }
            .navigationTitle("Add Trip Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(item: $alertContext) { context in
                switch context {
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
                    SentrySDK.capture(error: message)
                    return Alert(
                        title: Text("Error"),
                        message: Text(message),
                        dismissButton: .default(Text("OK"))
                    )
                case .restored:
                    return Alert(
                        title: Text("Restore Purchases"),
                        message: Text("Your previous purchases have been restored successfully!"),
                        dismissButton: .default(Text("OK"), action: {
                            storeManager.restored = false
                        })
                    )
                }
            }
        }.onAppear{
            setupCallbacks()
        }
    }
    
    private func handlePremiumCheck() {
        guard let userId = viewModel.getUser()?.uid, !userId.isEmpty else {
            alertContext = .error("No user ID available")
            return
        }
        
        FirestoreUtil.ensureUserExists(userId: userId) { exists, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertContext = .error(error.localizedDescription)
                    return
                }
                
                FirestoreUtil.checkPremiumStatus(userId: userId) { isPremium, error in
                    if let isPremium = isPremium {
                        if isPremium {
                            self.alertContext = .alreadyPremium
                        } else {
                            self.checkFreeTrial(userId: userId)
                        }
                    } else if let error = error {
                        self.alertContext = .error(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func checkFreeTrial(userId: String) {
        FirestoreUtil.checkFreeTrial(userId: userId) { freeTrialActive, error in
            if let freeTrialActive = freeTrialActive {
                if freeTrialActive {
                    alertTitle = "Free Trial Active"
                    alertMessage = "You can auto-import one itinerary document as part of your free trial. Please send your itinerary to info@usc-tracker.com from your registered email address."
                    alertContext = .freeTrialActive
                } else {
                    alertTitle = "Purchase Premium"
                    alertMessage = "Your free trial has ended. Please consider purchasing our premium version for a one time fee of $4.99 for continued access to auto-import feature."
                    alertContext = .purchasePrompt
                }
            } else if let error = error {
                alertContext = .error(error.localizedDescription)
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
