import Foundation
import FirebaseFirestore

class TripPersistence {
    static let shared = TripPersistence()
    private let store = NSUbiquitousKeyValueStore.default
    private let tripsKey = "tripsKey"
    private let gcResidentKey = "gcResidentSinceKey"
    private let marriedToCitizenKey = "marriedToCitizenKey"
    
    // Save GC Resident Date
    func saveGCResidentDate(_ date: Date) {
        let timestamp = date.timeIntervalSince1970
        store.set(timestamp, forKey: gcResidentKey)
        store.synchronize() // Even though deprecated, ensuring immediate sync in this example
    }
    
    // Load GC Resident Date
    func loadGCResidentDate() -> Date? {
        if let timestamp = store.double(forKey: gcResidentKey) as Double?, timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        } else {
            return nil // No date saved
        }
    }
    
    func saveTripsToFirestore(_ trips: [Trip], userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let data: [String: Any] = ["trips": try! JSONEncoder().encode(trips).base64EncodedString()]
        db.collection("users").document(userId).setData(data, merge: true) { error in
            if let error = error {
                print("Error saving trips to Firestore: \(error)")
                completion(false)
            } else {
                print("Trips successfully saved to Firestore")
                completion(true)
            }
        }
    }
    
    func saveMarriageStatus(isMarried: Bool) {
        store.set(isMarried, forKey: marriedToCitizenKey)
    }
    
    
    func loadMarriageStatus() -> Bool {
        return store.bool(forKey: marriedToCitizenKey)
    }
    
    func checkForTripsInFirestore(userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(), data.contains(where: { $0.key == "trips" }) {
                    completion(true)  // Trips data exists in Firestore
                } else {
                    completion(false) // No trips data found
                }
            } else {
                completion(false) // Document does not exist or error occurred
            }
        }
    }
    
    func loadTripsFromFirestore(userId: String, completion: @escaping ([Trip]) -> Void) {
        print("Trips loaded from firestore")
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            guard let document = document, document.exists, let data = document.data(),
                  let tripsDataString = data["trips"] as? String,
                  let tripsData = Data(base64Encoded: tripsDataString),
                  let trips = try? JSONDecoder().decode([Trip].self, from: tripsData) else {
                completion([])
                return
            }
            completion(trips)
        }
    }
    
    // Save trips asynchronously with a completion handler
    func saveTrips(_ trips: [Trip], completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(trips)
                self.store.set(data, forKey: self.tripsKey)
                self.store.synchronize() // Note: synchronize() is deprecated and not necessary for key-value store changes
                print("Trips saved to iCloud: \(trips)")
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Error encoding trips: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // Load trips asynchronously with a completion handler
    func loadTrips(completion: @escaping ([Trip]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let data = self.store.data(forKey: self.tripsKey) else {
                print("No data found in iCloud for key: \(self.tripsKey)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            do {
                let trips = try JSONDecoder().decode([Trip].self, from: data)
                print("Trips loaded from iCloud: \(trips)")
                DispatchQueue.main.async {
                    completion(trips)
                }
            } catch {
                print("Error decoding trips: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
