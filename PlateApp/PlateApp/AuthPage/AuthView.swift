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
            
            NavigationLink {
                SignInView(showFeedView: $showFeedView)
            } label: {
                VStack {
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
        }
    }
}

struct SignInView: View {
    @StateObject var viewModel = AuthViewModel()
    @Binding var showFeedView: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ZStack {
                VStack(alignment: .center, spacing: 50) {
                    Text("Sign in with Email")
                        .font(.title)
                        .bold()
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                        TextField("example$@gmail.com", text: $viewModel.email)
                            .padding()
                            .keyboardType(.phonePad)
                            .frame(width: 300, height: 50)
                            .background(.white)
                            .foregroundStyle(.black)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                        Text("Password")
                        TextField("Password", text: $viewModel.password)
                            .padding()
                            .keyboardType(.phonePad)
                            .frame(width: 300, height: 50)
                            .background(.white)
                            .foregroundStyle(.black)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                    }
                    
                    Button(action: {
                        viewModel.signIn()
                        showFeedView = false
                    }) {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.primary))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                }
            }
            .foregroundStyle(.white)
        }
    }
}


#Preview {
    AuthView(showFeedView: .constant(true))
}
