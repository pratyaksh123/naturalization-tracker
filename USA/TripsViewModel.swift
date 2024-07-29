//
//  TripViewModel.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 7/27/24.
//

import Foundation

class TripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var showModal = false
    @Published var showAlert = false
    @Published var tripToDelete: Trip?
    @Published var tripToEdit: Trip?
    
    var totalTripDuration: Int {
        trips.reduce(0) { $0 + $1.duration }
    }
    
    init() {
        self.loadTrips()
    }
    
    func loadTrips() {
        TripPersistence.shared.loadTrips { [weak self] trips in
            self?.trips = trips
        }
    }
    
    
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        saveTrips()
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            saveTrips()
        }
    }
    
    func deleteTrip() {
        if let trip = tripToDelete, let index = trips.firstIndex(of: trip) {
            trips.remove(at: index)
            saveTrips()
            tripToDelete = nil
        }
    }
    
    func saveTrips() {
        TripPersistence.shared.saveTrips(trips) { success in
            if success {
                print("Trips have been saved successfully.")
            } else {
                print("Failed to save trips.")
            }
            self.loadTrips() // Optionally reload data
        }
    }
}
