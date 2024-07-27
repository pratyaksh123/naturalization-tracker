import SwiftUI

struct TripEntryModalView: View {
    @Binding var trips: [Trip]
    @Binding var showModal: Bool
    @State private var title: String
    @State private var entryDate: Date
    @State private var exitDate: Date
    @State private var selectedEmoji: String
    @State private var isEditing: Bool
    @State private var editingTrip: Trip?

    let emojis = ["✈️", "🚗", "🚢", "🏖", "⛰", "🏠", "🎢"]

    init(trips: Binding<[Trip]>, showModal: Binding<Bool>, tripToEdit: Trip? = nil) {
        self._trips = trips
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
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    
                    DatePicker("Start Date", selection: $entryDate, displayedComponents: .date)
                        .padding(.bottom, 10)
                    DatePicker("End Date", selection: $exitDate, displayedComponents: .date)
                        .padding(.top, 10)
                    
                    Picker("Choose Emoji", selection: $selectedEmoji) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 10)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            if isEditing, let editingTrip = editingTrip {
                                if let index = trips.firstIndex(where: { $0.id == editingTrip.id }) {
                                    trips[index] = Trip(id: editingTrip.id, title: title, startDate: entryDate, endDate: exitDate, emoji: selectedEmoji)
                                }
                            } else {
                                let newTrip = Trip(title: title, startDate: entryDate, endDate: exitDate, emoji: selectedEmoji)
                                trips.append(newTrip)
                            }
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
                    .padding()
                }
                .padding(.bottom, 20) // Add padding at the bottom to ensure everything is visible
            }
            .navigationTitle(isEditing ? "Edit Trip" : "Add Trip")
            .navigationBarItems(trailing: Button("Cancel") {
                showModal = false
            })
        }
        .presentationDetents([.fraction(0.75), .large]) // Adjusted fraction
    }
}

struct TripEntryModalView_Previews: PreviewProvider {
    static var previews: some View {
        TripEntryModalView(trips: .constant([]), showModal: .constant(true))
    }
}
