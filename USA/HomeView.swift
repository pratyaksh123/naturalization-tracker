import SwiftUI

struct HomeView: View {
    @State private var timeLeft: String = "Calculating..."
    @State private var gcDate: Date?
    @EnvironmentObject var viewModel: TripsViewModel
    @State private var showSettings = false
    @State private var isActive: Bool = false
    @State private var dataLoaded = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func setup() {
        gcDate = TripPersistence.shared.loadGCResidentDate()
        updateTimeLeft()
    }
    
    private func formatDuration(from startDate: Date, to endDate: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: startDate, to: endDate)
        var parts: [String] = []
        if let years = components.year, years > 0 {
            parts.append("\(years) years")
        }
        if let months = components.month, months > 0 {
            parts.append("\(months) months")
        }
        if let days = components.day, days > 0 {
            parts.append("\(days) days")
        }
        return parts.joined(separator: " ")
    }
    
    private func formatDurationDays(days: Int) -> String {
        let years = days / 365
        let months = (days % 365) / 30
        let remainingDays = days % 30
        
        var parts: [String] = []
        if years > 0 {
            parts.append("\(years) year" + (years > 1 ? "s" : ""))
        }
        if months > 0 {
            parts.append("\(months) month" + (months > 1 ? "s" : ""))
        }
        if remainingDays > 0 {
            parts.append("\(remainingDays) day" + (remainingDays != 1 ? "s" : ""))
        } else if parts.isEmpty {
            // Ensure "0 days" is shown if there are no years or months
            parts.append("0 days")
        }
        
        return parts.joined(separator: ", ")
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
                NavigationLink(destination: ContentView(viewModel: viewModel), isActive: $isActive) {
                    EmptyView()
                }
                Image("statue_of_liberty")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                    .padding(.top, 10)
                
                
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
                    let daysOutsideUS = formatDurationDays(days: viewModel.totalTripDuration)
                    let physicalPresence = formatDuration(from: gcDate, to: now)
                    
                    Text("Physical presence:")
                        .font(.headline)
                        .padding(.vertical, 5)
                    
                    Text(physicalPresence)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.accentColor)
                        .padding(.vertical, 5)
                    
                    Text("Time outside:")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    Text(daysOutsideUS)
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.accentColor)
                        .padding(.vertical, 5)
                }
                
                Spacer()
                
                NavigationLink(destination: TripsView(viewModel: viewModel, isActive: $isActive)) {
                    Text("Trips")
                        .font(.title2)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.bottom, 20)
                .navigationBarItems(trailing: Button(action: {
                    showSettings.toggle()
                }, label: {
                    Image(systemName: "gear")
                }))
                .sheet(isPresented: $showSettings) {
                    SettingsView(isActive: $isActive)
                        .presentationDetents([.medium, .medium])
                }
            }
            .onAppear {
                if !dataLoaded {
                    setup()
                    dataLoaded = true  // Set the flag to prevent future invocations
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
