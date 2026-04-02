//
//  AuthView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI


struct AuthView: View {
    @Binding var showFeedView: Bool
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 50) {
                Spacer()
                Text("Plate")
                    .font(.title)
                    .bold()
                Spacer()
                VStack(spacing: 10) {
                    Text("Welcome")
                        .font(.subheadline)
                        .bold()
                    Text("Your daily meal, shared with your friends")
                        .font(.caption)
                }
                Spacer()
                NavigationLink {
                    AccountCreationView(showFeedView: $showFeedView)
                } label: {
                    VStack(spacing: 50) {
                        Text("Sign in with your Email")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.primary))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .accessibilityIdentifier("signInLink")
                Spacer()
                Spacer()
            }
        }
        .foregroundStyle(.white)
    }
}




#Preview {
    AuthView(showFeedView: .constant(true))
}
