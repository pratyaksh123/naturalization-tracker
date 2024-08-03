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
                    userRef.updateData(["freeTrialActive": true]) { error in
                        if let error = error {
                            completion(nil, error)
                        } else {
                            completion(true, nil)
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
}

