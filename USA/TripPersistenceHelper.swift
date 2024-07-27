import Foundation

class TripPersistence {
    static let shared = TripPersistence()
    private let store = NSUbiquitousKeyValueStore.default
    private let tripsKey = "tripsKey"
    
    func saveTrips(_ trips: [Trip]) {
        do {
            let data = try JSONEncoder().encode(trips)
            store.set(data, forKey: tripsKey)
            store.synchronize()
            print("Trips saved to iCloud: \(trips)")
        } catch {
            print("Error encoding trips: \(error)")
        }
    }
    
    func loadTrips() -> [Trip] {
        guard let data = store.data(forKey: tripsKey) else {
            print("No data found in iCloud for key: \(tripsKey)")
            return []
        }
        do {
            let trips = try JSONDecoder().decode([Trip].self, from: data)
            print("Trips loaded from iCloud: \(trips)")
            return trips
        } catch {
            print("Error decoding trips: \(error)")
            return []
        }
    }
}
