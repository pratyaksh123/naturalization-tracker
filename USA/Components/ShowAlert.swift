//
//  ShowAlert.swift
//  USA
//
//  Created by Pratyaksh Tyagi on 8/3/24.
//

import SwiftUI

struct ShowAlert: View {
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showingAlert = false
    
    private func showAlertWithMessage(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    
    var body: some View {
        NavigationView {
            // Your existing code...
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ShowAlert()
}
