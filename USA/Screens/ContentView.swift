import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject var viewModel: TripsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                LoginView(isLoading: $isLoading, viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: TripsViewModel())
    }
}
