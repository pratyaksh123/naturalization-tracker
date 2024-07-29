import Foundation

class TripPersistence {
    static let shared = TripPersistence()
    private let store = NSUbiquitousKeyValueStore.default
    private let tripsKey = "tripsKey"
    private let gcResidentKey = "gcResidentSinceKey" // New key for GC resident date
    
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
