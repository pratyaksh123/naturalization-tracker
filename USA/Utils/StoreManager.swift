import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var premiumAccessGranted = false
    @Published var products: [SKProduct] = []
    var currentUserID: String?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(["USCAutoImportFeature"]))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            products = response.products
            print("Product is available: \(products.first?.localizedTitle ?? "No title")")
        }
    }
    
    func buyProduct(_ product: SKProduct, for userId: String) {
            currentUserID = userId  // Store the user ID to use after transaction updates
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                if let userId = currentUserID {
                    premiumAccessGranted = true
                    FirestoreUtil.setPremiumUserStatus(userId: userId, isPremium: true) { error in
                        if let error = error {
                            print("Failed to set premium status: \(error.localizedDescription)")
                        } else {
                            print("Premium status successfully updated for user ID \(userId)")
                        }
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            case .failed:
                if let error = transaction.error as? SKError {
                    print("Transaction Failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

}
