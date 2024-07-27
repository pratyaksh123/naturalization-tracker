import SwiftUI

struct HomeView: View {
    @State private var timeLeft: String = "N/A"
    
    var body: some View {
        NavigationView {
            VStack {
                Image("statue_of_liberty")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                
                Text("Time Left for Citizenship:")
                    .font(.headline)
                    .padding(.top, 20)
                
                Text(timeLeft)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                
                Spacer()
                
                NavigationLink(destination: TripsView()) {
                    HStack {
                        Text("Trips")
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
