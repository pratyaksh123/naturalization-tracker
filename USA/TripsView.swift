import SwiftUI

struct TripsView: View {
    @State private var trips: [Trip] = TripPersistence.shared.loadTrips() // Load trips from iCloud
    @State private var showModal = false
    @State private var showAlert = false
    @State private var tripToDelete: Trip?
    @State private var tripToEdit: Trip?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(trips.sorted(by: { $0.startDate > $1.startDate })) { trip in
                        TripCardView(trip: trip)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    tripToDelete = trip
                                    showAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    tripToEdit = trip
                                    showModal = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Delete Trip"),
                            message: Text("Are you sure you want to delete this trip?"),
                            primaryButton: .destructive(Text("Delete")) {
                                if let trip = tripToDelete {
                                    if let index = trips.firstIndex(where: { $0.id == trip.id }) {
                                        trips.remove(at: index)
                                        TripPersistence.shared.saveTrips(trips) // Save trips to iCloud
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, -8)
                
                Button(action: {
                    tripToEdit = nil // Reset editing trip
                    showModal.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Trip")
                    }
                    .font(.title2)
                    .padding()
                    .background(Color("primaryColor"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .sheet(isPresented: $showModal) {
                    TripEntryModalView(trips: $trips, showModal: $showModal, tripToEdit: tripToEdit)
                }
            }
            .navigationTitle("Trips")
            .onChange(of: trips) { newValue in
                TripPersistence.shared.saveTrips(newValue) // Save trips to iCloud on change
            }
        }
        .onAppear {
            // Log iCloud data store status
            let store = NSUbiquitousKeyValueStore.default
            store.synchronize()
            if let data = store.data(forKey: "tripsKey") {
                print("Data in iCloud at startup: \(data)")
            } else {
                print("No data in iCloud at startup")
            }
        }
    }
}

struct TripsView_Previews: PreviewProvider {
    static var previews: some View {
        TripsView()
    }
}
