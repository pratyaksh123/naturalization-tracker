import SwiftUI
import RevenueCat

struct PayWall: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var package: Package?
    var onPurchaseComplete: () -> Void
    
    private func getOfferings() {
            Purchases.shared.getOfferings { (offerings, error) in
                if let error = error {
                    print("Error fetching offerings: \(error.localizedDescription)")
                    return
                }
                guard let offerings = offerings, let autoImportOffering = offerings.offering(identifier: "USCAutoImport") else {
                    print("No offerings available or specific offering not found.")
                    return
                }
                
                // Assuming `autoImportOffering` has a list of packages and we're interested in the first available package
                if let firstPackage = autoImportOffering.availablePackages.first {
                    DispatchQueue.main.async {
                        self.package = firstPackage // Update the package state
                        print("Package updated: \(firstPackage)")
                    }
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
                        print("No package available for purchase")
                        // Optionally, add user feedback here, like displaying an alert.
                        return
                    }
                    
                    Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                        if let error = error {
                            print("Purchase failed: \(error.localizedDescription)")
                            return
                        }
                        if userCancelled {
                            print("User cancelled the purchase")
                            return
                        }
                        if customerInfo?.entitlements["premium"]?.isActive == true {
                            print("Premium purchased")
                            self.onPurchaseComplete()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            print("Purchase completed but premium not active")
                            // Handle case where purchase did not grant access as expected
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.vertical)
                
                Button("Restore purchases") {
                    Purchases.shared.restorePurchases { customerInfo, error in
                        if let error = error {
                            print("Restore failed: \(error.localizedDescription)")
                            // Optionally, alert the user that the restore process failed.
                            return
                        }

                        if customerInfo?.entitlements["premium"]?.isActive == true {
                            print("Premium features restored")
                            self.onPurchaseComplete()
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            print("No premium features to restore")
                            // Handle case where no premium purchases are found or active.
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
    }
}

struct PayWall_Previews: PreviewProvider {
    static var previews: some View {
        PayWall(onPurchaseComplete: {
            print("Purchase completed")
        })
    }
}
