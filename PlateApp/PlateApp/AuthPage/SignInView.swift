//
//  SignInView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/30/26.
//


import SwiftUI


struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Text("Sign in with Email")
                .font(.title)
                .bold()
            VStack(alignment: .leading, spacing: 5) {
                Text("Email")
                TextField("example$@gmail.com", text: $viewModel.email)
                    .onChange(of: viewModel.email) { _,_ in
                        viewModel.errorMessage = nil
                    }
                    .padding()
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.gray), lineWidth: 1))
                Text("Password")
                SecureField("Password", text: $viewModel.password)
                    .onChange(of: viewModel.password) { _,_ in
                        viewModel.errorMessage = nil
                    }
                    .padding()
                    .frame(width: 300, height: 50)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.gray), lineWidth: 1))
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            
            VStack {
                Button(action: {
                    viewModel.signIn()
                }) {
                    Text("Login")
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
        .environmentObject(AuthViewModel())
}

