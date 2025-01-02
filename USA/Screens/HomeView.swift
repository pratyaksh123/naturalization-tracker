import SwiftUI

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Rectangle
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                // Filled Rectangle
                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.accentColor)
                    .animation(.linear, value: value)
                
                // Percentage Text
                Text("\(Int(value * 100))%")
                    .bold()
                    .foregroundColor(.white)  // Choose a color that contrasts well with the filled color
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .multilineTextAlignment(.center)
            }.cornerRadius(45.0)
        }
    }
}

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
    
    private var citizenshipProgress: Double {
        let currentDate = Date()
        let totalDuration = viewModel.isMarriedToCitizen ? 3.0 : 5.0 // total years required for citizenship
        let calendar = Calendar.current
        
        // Calculate the number of days from green card start date to today
        let elapsedDays = calendar.dateComponents([.day], from: viewModel.greenCardStartDate, to: currentDate).day ?? 0
        
        // Total days in the duration required for citizenship
        let totalDays = totalDuration * 365.25 // accounts for leap years by using 365.25 days per year
        
        // Progress is the elapsed days divided by total days required, capped at 1.0
        return min(Double(elapsedDays) / totalDays, 1.0)
    }
    
    private func setup() {
        viewModel.loadTrips()
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
                
                GeometryReader { proxy in
                    Image("statue_of_liberty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height * 1)
                        .padding(.top, -15)
                }
                
                if(citizenshipProgress > 0) {
                    ProgressBar(value: citizenshipProgress)
                        .frame(height: 20)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                }
                
                Text("Time Left for Citizenship:")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text(viewModel.timeLeftForCitizenship)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .padding(.top, 1)
                
                Text("Physical presence:")
                    .font(.headline)
                    .padding(.top, 10)
                
                Text(viewModel.physicalPresence)
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
