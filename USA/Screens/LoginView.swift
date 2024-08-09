import SwiftUI

struct LoginView: View {
    @State private var err: String = ""
    @Binding var isLoading: Bool
    @State var viewModel: TripsViewModel
    
    var body: some View {
        VStack {
            Text("Sign in to auto-import itineraries!")
                .font(.headline)
                .padding()
            
            GeometryReader { proxy in
                VStack {
                    Image("statue_of_liberty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height * 0.8)
                    
                    Spacer() // Dynamically assigns remaining space
                    
                    Button {
                        Task {
                            do {
                                isLoading = true
                                try await Authentication().googleOauth()
                            } catch let e {
                                print(e)
                                err = e.localizedDescription
                            }
                            isLoading = false
                            if viewModel.isLoggedIn() {
                                NavigationUtil.popToRootView(animated: true)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.key.fill")
                            Text("Sign in with Google")
                        }
                        .frame(height: proxy.size.height * 0.07)                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, proxy.size.height * 0.09) // Provide some padding from the bottom
                }
            }
            
            if !err.isEmpty {
                Text(err)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoading = true
    static var previews: some View {
        LoginView(isLoading: $isLoading, viewModel: TripsViewModel())
    }
}
