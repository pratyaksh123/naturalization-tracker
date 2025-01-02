import SwiftUI
import RevenueCat

struct PayWall: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var package: Package?
    var onPurchaseComplete: () -> Void
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    private func getOfferings() {
        Purchases.shared.getOfferings { (offerings, error) in
            if let error = error {
                self.alertTitle = "Error"
                self.alertMessage = "Failed to fetch offerings: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            guard let offerings = offerings, let autoImportOffering = offerings.offering(identifier: "USCAutoImport") else {
                self.alertTitle = "Error"
                self.alertMessage = "No available offerings or specific offering not found."
                self.showAlert = true
                return
            }
            if let firstPackage = autoImportOffering.availablePackages.first {
                DispatchQueue.main.async {
                    self.package = firstPackage // Update the package state
                }
            } else {
                self.alertTitle = "Error"
                self.alertMessage = "No packages available for this offering."
                self.showAlert = true
            }
        }
    }
    
    var body: some View {
        VStack {
            Image("paywall_header")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.clear, Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
                )
            
            VStack(alignment: .center, spacing: 16) {
                Text("Auto Import Your Trips using AI")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Unlock AI-powered auto-import for past and current trips.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Text("Lifetime access for $ 4.99 one time")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Button("Continue") {
                    guard let package = self.package else {
                        self.alertTitle = "Purchase Unavailable"
                        self.alertMessage = "No package available for purchase."
                        self.showAlert = true
                        return
                    }
                    
                    Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                        if let error = error {
                            self.alertTitle = "Purchase Failed"
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                            return
                        }
                        if userCancelled {
                            self.alertTitle = "Purchase Cancelled"
                            self.alertMessage = "You have cancelled the purchase."
                            self.showAlert = true
                            return
                        }
                        if customerInfo?.entitlements["premium"]?.isActive == true {
                            self.onPurchaseComplete()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.alertTitle = "Purchase Incomplete"
                            self.alertMessage = "Contact our team at info@usc-tracker.tech"
                            self.showAlert = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.vertical)
                
                Button("Restore purchases") {
                    Purchases.shared.restorePurchases { customerInfo, error in
                        if let error = error {
                            self.alertTitle = "Restore Failed"
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                            return
                        }
                        if customerInfo?.entitlements["premium"]?.isActive == true {
                            self.onPurchaseComplete()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.alertTitle = "No Purchases to Restore"
                            self.alertMessage = "No premium purchases were found."
                            self.showAlert = true
                        }
                    }
                }
                .foregroundColor(.green)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(30)
            .padding(.horizontal)
        }
        .background(Color(.systemBackground))
        .onAppear{
            getOfferings()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    // Dismiss the paywall view when there is an error
                    presentationMode.wrappedValue.dismiss()
                })
            )
        }
    }
}

struct PayWall_Previews: PreviewProvider {
    static var previews: some View {
        PayWall(onPurchaseComplete: {
            print("Purchase completed")
        })
    }
}
