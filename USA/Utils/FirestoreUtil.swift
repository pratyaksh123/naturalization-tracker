//
//  FreeTrialCheck.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 8/3/24.
//
import FirebaseFirestore

struct FirestoreUtil {
    static let db = Firestore.firestore()
    
    static func checkFreeTrial(userId: String, completion: @escaping (Bool?, Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                if let freeTrialActive = document.data()?["freeTrialActive"] as? Bool {
                    completion(freeTrialActive, nil)
                } else {
                    // The freeTrialActive field does not exist, assume trial available and set it to true
                    userRef.updateData(["freeTrialActive": false]) { error in
                        if let error = error {
                            completion(nil, error)
                        } else {
                            completion(false, nil)
                        }
                    }
                }
            } else {
                // Document does not exist, should ideally never be the case since userId should be valid
                print("No user document found for user ID: \(userId)")
                completion(nil, nil)
            }
        }
    }
    
    static func setPremiumUserStatus(userId: String, isPremium: Bool, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        // Update or set the isPremiumUser field to true
        userRef.setData(["isPremiumUser": isPremium], merge: true) { error in
            if let error = error {
                print("Error setting premium status: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Premium status set to \(isPremium) for user ID: \(userId)")
                completion(nil)
            }
        }
    }
    
    static func checkPremiumStatus(userId: String, completion: @escaping (Bool?, Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                completion(nil, error)
            } else if let document = document, document.exists {
                if let isPremiumUser = document.data()?["isPremiumUser"] as? Bool {
                    print("isPremiumUser status for user ID \(userId): \(isPremiumUser)")
                    completion(isPremiumUser, nil)
                } else {
                    // If the isPremiumUser field does not exist, assume the user is not premium
                    print("isPremiumUser field does not exist for user ID \(userId). Assuming non-premium status.")
                    completion(false, nil)
                }
            } else {
                // Document does not exist, should ideally never be the case since userId should be valid
                print("No user document found for user ID: \(userId)")
                completion(nil, nil)
            }
        }
    }
    
    static func ensureUserExists(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true, nil)
            } else if let error = error {
                completion(false, error)
            } else {
                // User does not exist, create the user with default values
                userRef.setData(["freeTrial": false], merge: true) { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
}

