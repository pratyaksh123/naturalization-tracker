import SwiftUI
import AuthenticationServices
import CryptoKit
import Firebase

struct LoginView: View {
    @State private var err: String = ""
    @Binding var isLoading: Bool
    @State var viewModel: TripsViewModel
    @State private var currentNonce: String?

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

                    SignInWithAppleButton(
                        .signIn,
                        onRequest: configureAppleSignInRequest,
                        onCompletion: handleAppleSignInResult
                    )
                    .frame(width: proxy.size.width * 0.52, height: proxy.size.height * 0.07)
                    
                    Button {
                        Task {
                            isLoading = true
                            try await Authentication().googleOauth()
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
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: proxy.size.width * 0.6, height: proxy.size.height * 0.08)
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

    private func configureAppleSignInRequest(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    private func handleAppleSignInResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce,  // Make sure currentNonce is declared and correctly handled in your Apple sign-in request
                      let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    err = "Error: Invalid state or missing information"
                    return
                }
                
                // Create a Firebase credential
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                // Sign in with Firebase
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print("Firebase sign in error: \(error.localizedDescription)")
                        err = "Apple Sign in failed: \(error.localizedDescription)"
                    } else {
                        // Update UI or state to show successful login
                        print("User is signed in with Firebase via Apple")
                        NavigationUtil.popToRootView(animated: true)
                    }
                }
            } else {
                err = "Unable to extract Apple ID credential"
            }
        case .failure(let error):
            print("Apple Sign in error: \(error.localizedDescription)")
            err = "Apple Sign in failed: \(error.localizedDescription)"
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoading = true
    static var previews: some View {
        LoginView(isLoading: $isLoading, viewModel: TripsViewModel())
    }
}
