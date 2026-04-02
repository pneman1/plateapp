//
//  AccountCreationView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/30/26.
//

import SwiftUI

struct AccountCreationView: View {
    @Binding var showFeedView: Bool
    @State private var showSignIn: Bool = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ZStack {
                if (showSignIn == true) {
                    SignInView()
                } else {
                    SignUpView()
                }
            }
            .foregroundStyle(.white)
        }
    }
}



#Preview {
    AccountCreationView(showFeedView: .constant(false))
}
