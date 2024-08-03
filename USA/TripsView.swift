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
                SettingsView(isActive: $isActive)
                    .presentationDetents([.medium, .medium])
            }
            .sheet(isPresented: $showOptionsModal) {
                OptionsModalView(showImportModal: $showOptionsModal, isActive: $isActive, viewModel: viewModel)
                    .presentationDetents([.medium, .medium])
            }
        }
    }
}


struct OptionsModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showImportModal: Bool
    @Binding var isActive: Bool
    @StateObject var viewModel: TripsViewModel
    
    var body: some View {
        NavigationView {
            List {
                Button("Add Trip Manually") {
                    presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.showModal = true
                    }
                }
                .padding(.vertical, 10)
                Button("Auto-import Trip using Email") {
                    if viewModel.isLoggedIn() {
                        print("User is signed in with ID: \(viewModel.getUser()?.uid ?? "Unknown")")
                        // display info
                    } else {
                        // Redirect to login view or handle unauthenticated state
                        presentationMode.wrappedValue.dismiss()
                        isActive = true
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationTitle("Add Trip Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
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
