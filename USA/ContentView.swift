import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject var viewModel: TripsViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoggedIn() {
                HomeView()
            } else {
                Login()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: TripsViewModel())
    }
}
