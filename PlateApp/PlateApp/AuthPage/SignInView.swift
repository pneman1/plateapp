//
//  SignInView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/30/26.
//


import SwiftUI


struct SignInView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Text("Sign in with Email")
                .font(.title)
                .bold()
            VStack(alignment: .leading, spacing: 5) {
                Text("Email")
                SecureField("example$@gmail.com", text: $viewModel.email)
                    .padding()
                    .keyboardType(.phonePad)
                    .frame(width: 300, height: 50)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                Text("Password")
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .keyboardType(.phonePad)
                    .frame(width: 300, height: 50)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
            }
            
            VStack {
                Button(action: {
                    viewModel.signIn()
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
                
                Text("Forgot password?")
                    .foregroundStyle(Color(.primary))
                    .bold()
            }
            
            VStack(spacing: 10) {
                Text("Don't have an account?")
                NavigationLink
                {
                    SignUpView()
                }   label: {
                    Text("Sign Up")
                        .foregroundStyle(Color(.primary))
                        .bold()
                }
            }
            
        }
    }
}



#Preview {
    SignInView()
}

