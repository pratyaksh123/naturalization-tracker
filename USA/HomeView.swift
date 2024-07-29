import SwiftUI

struct HomeView: View {
    @State private var timeLeft: String = "Calculating..."
    @State private var gcDate: Date?
    @ObservedObject private var viewModel = TripsViewModel()

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private func fetchData() {
        gcDate = TripPersistence.shared.loadGCResidentDate()
        viewModel.loadTrips()
        updateTimeLeft()
    }
    
    private func formatDuration(from startDate: Date, to endDate: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: startDate, to: endDate)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        return "\(years) years, \(months) months, \(days) days"
    }

    private func updateTimeLeft() {
        guard let gcDate = gcDate else {
            timeLeft = "N/A"
            return
        }
        let now = Date()
        let naturalizationEligibilityDate = Calendar.current.date(byAdding: .year, value: 5, to: gcDate)?
            .addingTimeInterval(-90*24*3600)

        if let eligibilityDate = naturalizationEligibilityDate {
            timeLeft = formatDuration(from: now, to: eligibilityDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Image("statue_of_liberty")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                
                Text("Time Left for Citizenship:")
                    .font(.headline)
                    .padding(.vertical, 5)
                
                Text(timeLeft)
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .padding(.vertical, 5)

                if let gcDate = gcDate {
                    let now = Date()
                    let daysOutsideUS = viewModel.totalTripDuration
                    let physicalPresence = formatDuration(from: gcDate, to: now)
                    let continuousResidence = formatDuration(from: gcDate.addingTimeInterval(Double(daysOutsideUS) * 24 * 60 * 60), to: now)

                    Text("Physical presence in USA since GC: \(physicalPresence)")
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    Text("Continuous residence time: \(continuousResidence)")
                        .font(.headline)
                        .padding(.vertical, 5)

                    Text("Time outside of US: \(daysOutsideUS) days")
                        .font(.headline)
                        .padding(.vertical, 5)
                }

                Spacer()
                
                NavigationLink(destination: TripsView()) {
                    Text("Trips")
                        .font(.title2)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.bottom, 50)
            }
            .onAppear(perform: fetchData)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
