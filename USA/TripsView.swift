import SwiftUI

struct TripsView: View {
    @StateObject private var viewModel = TripsViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.trips.sorted(by: { $0.startDate > $1.startDate })) { trip in
                        TripCardView(trip: trip)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.tripToDelete = trip
                                    viewModel.showAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.tripToEdit = trip
                                    viewModel.showModal = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(
                            title: Text("Delete Trip"),
                            message: Text("Are you sure you want to delete this trip?"),
                            primaryButton: .destructive(Text("Delete")) {
                                viewModel.deleteTrip()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, -8)
                
                Button(action: {
                    viewModel.tripToEdit = nil
                    viewModel.showModal.toggle()
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
                .sheet(isPresented: $viewModel.showModal) {
                    TripEntryModalView(viewModel: viewModel, showModal: $viewModel.showModal, tripToEdit: viewModel.tripToEdit)
                }
            }
            .navigationTitle("Trips")
            .navigationBarItems(trailing: Button(action: {
                showSettings.toggle()
            }, label: {
                Image(systemName: "gear")
            }))
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.medium, .medium])
            }
        }
    }
}

struct TripsView_Previews: PreviewProvider {
    static var previews: some View {
        TripsView()
    }
}
