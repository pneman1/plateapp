//
//  ProfileView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    @Binding var showSignInView: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Profile")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .accessibilityIdentifier("profileTitle")

                Button("Log Out") {
                    Task {
                        do {
                            try viewModel.logOut()
                            showSignInView = true
                        } catch {
                            print("Log out failed")
                        }
                    }
                }
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.primary))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .accessibilityIdentifier("profileLogOutButton")

                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))
}
