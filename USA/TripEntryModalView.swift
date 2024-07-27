import SwiftUI

struct TripEntryModalView: View {
    @State var viewModel: TripsViewModel // Use ObservedObject if ViewModel is passed from parent view
    @Binding var showModal: Bool
    @State private var title: String
    @State private var entryDate: Date
    @State private var exitDate: Date
    @State private var selectedEmoji: String
    @State private var isEditing: Bool
    @State private var editingTrip: Trip?

    let emojis = ["✈️", "🚗", "🚢", "🏖", "⛰", "🏠", "🎢"]

    init(viewModel: TripsViewModel, showModal: Binding<Bool>, tripToEdit: Trip? = nil) {
        self._viewModel = State(initialValue: viewModel)
        self._showModal = showModal
        if let trip = tripToEdit {
            self._title = State(initialValue: trip.title)
            self._entryDate = State(initialValue: trip.startDate)
            self._exitDate = State(initialValue: trip.endDate)
            self._selectedEmoji = State(initialValue: trip.emoji)
            self._isEditing = State(initialValue: true)
            self._editingTrip = State(initialValue: trip)
        } else {
            self._title = State(initialValue: "")
            self._entryDate = State(initialValue: Date())
            self._exitDate = State(initialValue: Date())
            self._selectedEmoji = State(initialValue: emojis.first!)
            self._isEditing = State(initialValue: false)
            self._editingTrip = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Title", text: $title)
                    DatePicker("Start Date", selection: $entryDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $exitDate, displayedComponents: .date)
                    Picker("Choose Emoji", selection: $selectedEmoji) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }.pickerStyle(SegmentedPickerStyle())

                    HStack {
                        Spacer()
                        Button(action: {
                            if isEditing, let editingTrip = editingTrip, let index = viewModel.trips.firstIndex(where: { $0.id == editingTrip.id }) {
                                // Update the trip directly in the array
                                viewModel.trips[index] = Trip(id: editingTrip.id, title: title, startDate: entryDate, endDate: exitDate, emoji: selectedEmoji)
                                viewModel.objectWillChange.send()
                            } else {
                                // Add a new trip
                                let newTrip = Trip(title: title, startDate: entryDate, endDate: exitDate, emoji: selectedEmoji)
                                viewModel.trips.append(newTrip)
                            }
                            viewModel.saveTrips() // Save the changes after updating
                            showModal = false
                        }) {
                            Text(isEditing ? "Save Trip" : "Add Trip")
                                .font(.title2)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Trip" : "Add Trip")
            .navigationBarItems(trailing: Button("Cancel") {
                showModal = false
            })
        }
    }
}

struct TripEntryModalView_Previews: PreviewProvider {
    static var previews: some View {
        TripEntryModalView(viewModel: TripsViewModel(), showModal: .constant(true))
    }
}
