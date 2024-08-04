import Foundation
import Firebase
import Combine

class TripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var showModal = false
    @Published var showAlert = false
    @Published var tripToDelete: Trip?
    @Published var tripToEdit: Trip?
    private var cancellables = Set<AnyCancellable>()
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    var totalTripDuration: Int {
        trips.reduce(0) { $0 + $1.duration }
    }
    
    init() {
        print("Initializing ViewModel...")
        subscribeToAuthChanges()
    }
    
    deinit {
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
            print("Removing auth state change listener.")
        }
    }
    
    func isLoggedIn() -> Bool {
        let loggedIn = Auth.auth().currentUser != nil
        print("Checked logged in status: \(loggedIn)")
        return loggedIn
    }
    
    func getUser() -> User? {
        let user = Auth.auth().currentUser
        print("Current user: \(String(describing: user))")
        return user
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User successfully signed out.")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    private func subscribeToAuthChanges() {
        print("Subscribing to auth changes.")
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            print("Auth state changed: \(String(describing: user))")
            self?.handleAuthenticationChange(user: user)
        }
    }
    
    private func handleAuthenticationChange(user: User?) {
        print("Handling authentication change...")
        if let userId = user?.uid {
            print("User is logged in with ID: \(userId)")
            checkAndSyncTrips(userId: userId)
        } else {
            print("User is logged out.")
            loadTrips()
        }
    }
    
    private func checkAndSyncTrips(userId: String) {
        print("Checking and syncing trips for user ID: \(userId)")
        TripPersistence.shared.loadTripsFromFirestore(userId: userId) { [weak self] firestoreTrips in
            guard let self = self else { return }
            print("Loaded trips from Firestore: \(firestoreTrips.count) trips")
            
            // Load trips from iCloud before comparing
            self.loadiCloudTrips { iCloudTrips in
                print("Loaded trips from iCloud: \(iCloudTrips.count) trips")
                
                if firestoreTrips.count != iCloudTrips.count {
                    if firestoreTrips.count > iCloudTrips.count {
                        print("Firestore has more trips. Updating local iCloud trips...")
                        self.trips = firestoreTrips  // Sync local model to Firestore trips
                        self.saveTripsLocally()  // Save the updated trips to iCloud
                    } else {
                        print("iCloud has more trips. Updating Firestore...")
                        self.trips = iCloudTrips  // Sync local model to iCloud trips
                        self.saveTripsToFirestore(userId: userId)  // Save the updated trips to Firestore
                    }
                } else {
                    print("Trips count is the same. Checking for content equality...")
                    if !self.areTripsEqual(localTrips: iCloudTrips, firestoreTrips: firestoreTrips) {
                        print("Local iCloud trips and Firestore trips differ in content. Updating both to match.")
                        self.trips = iCloudTrips  // Sync local model to iCloud trips
                        self.saveTripsLocally()  // Update iCloud trips for consistency
                        self.saveTripsToFirestore(userId: userId)  // Update Firestore trips for consistency
                    } else {
                        print("All trips are synchronized and equal.")
                    }
                }
            }
        }
    }
    
    private func areTripsEqual(localTrips: [Trip], firestoreTrips: [Trip]) -> Bool {
        let localTripIds = Set(localTrips.map { $0.id })
        let firestoreTripIds = Set(firestoreTrips.map { $0.id })
        let isEqual = localTripIds == firestoreTripIds
        print("Comparing local trips with Firestore trips: \(isEqual)")
        return isEqual
    }
    
    func loadTrips() {
        print("Loading trips...")
        if let userId = Auth.auth().currentUser?.uid {
            print("User is logged in. Loading trips from Firestore...")
            TripPersistence.shared.loadTripsFromFirestore(userId: userId) { [weak self] trips in
                print("Trips loaded from Firestore: \(trips.count)")
                self?.trips = trips
            }
        } else {
            print("No user logged in. Loading trips locally...")
            TripPersistence.shared.loadTrips { [weak self] trips in
                print("Trips loaded locally: \(trips.count)")
                self?.trips = trips
            }
        }
    }
    
    func loadiCloudTrips(completion: @escaping ([Trip]) -> Void) {
        TripPersistence.shared.loadTrips { trips in
            print("Trips loaded from iCloud: \(trips.count)")
            completion(trips)
        }
    }
    
    func addTrip(_ trip: Trip) {
        print("Adding new trip: \(trip)")
        trips.append(trip)
        saveTrips()
    }
    
    func updateTrip(_ trip: Trip) {
        print("Updating trip: \(trip)")
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            saveTrips()
        }
    }
    
    func deleteTrip() {
        if let trip = tripToDelete, let index = trips.firstIndex(of: trip) {
            print("Deleting trip: \(trip)")
            trips.remove(at: index)
            tripToDelete = nil
            saveTrips()
        }
    }
    
    func saveTrips() {
        print("Saving trips...")
        if let userId = Auth.auth().currentUser?.uid {
            print("User is logged in. Saving trips to Firestore and icloud...")
            saveTripsToFirestore(userId: userId)
            saveTripsLocally()
        } else {
            print("No user logged in. Saving trips locally...")
            saveTripsLocally()
        }
    }
    
    private func saveTripsToFirestore(userId: String) {
        print("Saving trips to Firestore for user ID: \(userId)")
        TripPersistence.shared.saveTripsToFirestore(trips, userId: userId) { success in
            if success {
                print("Trips have been saved successfully to Firestore.")
            } else {
                print("Failed to save trips to Firestore.")
            }
        }
    }
    
    private func saveTripsLocally() {
        print("Saving trips locally...")
        TripPersistence.shared.saveTrips(trips) { success in
            if success {
                print("Trips have been saved successfully locally.")
            } else {
                print("Failed to save trips locally.")
            }
        }
    }
}
