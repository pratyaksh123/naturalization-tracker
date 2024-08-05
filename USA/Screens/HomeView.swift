import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: TripsViewModel
    @State private var showSettings = false
    @State private var isActive: Bool = false
    @State private var dataLoaded = false
    @State private var showAlert = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func setup() {
        viewModel.updateTimeLeft()
    }
    
    private var citizenshipDate: String {
        let adjustmentYears = viewModel.isMarriedToCitizen ? 3 : 5
        guard let gcStartDate = Calendar.current.date(byAdding: .year, value: adjustmentYears, to: viewModel.greenCardStartDate),
              let finalDate = Calendar.current.date(byAdding: .day, value: -90, to: gcStartDate) else {
            return "N/A"
        }
        return dateFormatter.string(from: finalDate)
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
                    .frame(height: UIScreen.main.bounds.height / 2.5)
                    .padding(.top, -10)
                
                Text("Time Left for Citizenship:")
                    .font(.headline)
                    .padding(.top, 2)
                
                Text(viewModel.timeLeftForCitizenship)
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .padding(.top, 1)

                let now = Date()
                let daysOutsideUS = viewModel.formatDurationDays(days: viewModel.totalTripDuration)
                let physicalPresence = viewModel.formatDuration(from: viewModel.greenCardStartDate, to: now)
                
                Text("Physical presence:")
                    .font(.headline)
                    .padding(.top, 3)
                
                Text(physicalPresence)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .padding(.top, 1)
                
                Text("Time outside:")
                    .font(.headline)
                    .padding(.top, 3)
                
                Text(daysOutsideUS)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .padding(.top, 1)

                
                NavigationLink(destination: TripsView(viewModel: viewModel, isActive: $isActive)) {
                    Text("Trips")
                        .font(.title2)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.bottom, 20)
                .navigationBarItems(leading: Button(action: {
                    showAlert = true
                }, label: {
                    Image(systemName: "info.circle")
                }), trailing: Button(action: {
                    showSettings.toggle()
                }, label: {
                    Image(systemName: "gear")
                }))
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Citizenship Early Filing Date"),
                        message: Text("You can apply for citizenship on\n \(citizenshipDate)"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .sheet(isPresented: $showSettings) {
                    if #available(iOS 16.0, *) {
                        SettingsView(isActive: $isActive)
                            .presentationDetents([.medium, .medium])
                    } else {
                        SettingsView(isActive: $isActive)
                    }
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
        HomeView().environmentObject(TripsViewModel())
    }
}
