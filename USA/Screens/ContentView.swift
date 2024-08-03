import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject var viewModel: TripsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if viewModel.isLoggedIn() && isLoading {
                ProgressView()
                    .onAppear{
                        if viewModel.isLoggedIn(){
                            isLoading = false
                            NavigationUtil.popToRootView(animated: true)
                        }
                    }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: TripsViewModel())
    }
}
