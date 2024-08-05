import SwiftUI

struct TripsView: View {
    @State private var showSettings = false
    @State private var showOptionsModal = false
    @StateObject var viewModel: TripsViewModel
    @Binding var isActive: Bool
    
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
                .sheet(isPresented: $viewModel.showModal) {
                    TripEntryModalView(viewModel: viewModel, showModal: $viewModel.showModal, tripToEdit: viewModel.tripToEdit)
                }
            }
            .navigationTitle("Trips")
            .navigationBarItems(leading:  Button(action: {
                showOptionsModal.toggle()
            }) {
                Image(systemName: "plus")
            },
                                trailing: Button(action: {
                showSettings.toggle()
            }, label: {
                Image(systemName: "gear")
            }))
            .sheet(isPresented: $showSettings) {
                if #available(iOS 16.0, *) {
                    SettingsView(isActive: $isActive)
                        .presentationDetents([.medium, .medium])
                } else {
                    SettingsView(isActive: $isActive)
                }
            }
            .sheet(isPresented: $showOptionsModal) {
                if #available(iOS 16.0, *) {
                    AddTripModalView(showImportModal: $showOptionsModal, isActive: $isActive, viewModel: viewModel)
                        .presentationDetents([.medium, .medium])
                } else {
                    AddTripModalView(showImportModal: $showOptionsModal, isActive: $isActive, viewModel: viewModel)
                }
            }
            .onAppear{
                viewModel.loadTrips()
            }
        }
    }
}


struct TripsView_Previews: PreviewProvider {
    @State static var isActive = false
    static var previews: some View {
        TripsView(viewModel: TripsViewModel(), isActive: $isActive)
    }
}
