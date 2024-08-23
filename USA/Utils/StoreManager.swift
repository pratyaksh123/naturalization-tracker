import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var premiumAccessGranted = false
    @Published var products: [SKProduct] = []
    var currentUserID: String?
    @Published var restored = false
    var onRestoreCompleted: (() -> Void)?
    var onError: ((String) -> Void)?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("All restored transactions have been processed.")
        DispatchQueue.main.async {
            self.restored = true
            self.onRestoreCompleted?()
        }
        
    }
    
    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(["USCAutoImport"]))
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
                   // This case is triggered for both new purchases and restored purchases
                   if transaction.original?.transactionIdentifier != nil {
                       // This means the transaction is a restored purchase
                       processTransaction(transaction, isRestored: true)
                   } else {
                       // This is a new purchase
                       processTransaction(transaction, isRestored: false)
                   }
               case .failed:
                   if let error = transaction.error as? SKError {
                       print("Transaction Failed: \(error.localizedDescription)")
                       onError?(error.localizedDescription)
                   }
                   SKPaymentQueue.default().finishTransaction(transaction)
               default:
                   break
               }
           }
       }
    
    private func processTransaction(_ transaction: SKPaymentTransaction, isRestored: Bool) {
        if let userId = currentUserID {
            if isRestored {
                // Handle restored purchase
                FirestoreUtil.setPremiumUserStatus(userId: userId, isPremium: true) { error in
                    if let error = error {
                        print("Failed to set premium status for restored purchase: \(error.localizedDescription)")
                    } else {
                        print("Premium status successfully updated for user ID \(userId) from restored purchase.")
                    }
                }
            } else {
                // Handle new purchase
                premiumAccessGranted = true
                FirestoreUtil.setPremiumUserStatus(userId: userId, isPremium: true) { error in
                    if let error = error {
                        print("Failed to set premium status for new purchase: \(error.localizedDescription)")
                    } else {
                        print("Premium status successfully updated for user ID \(userId) from new purchase.")
                    }
                }
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
}
