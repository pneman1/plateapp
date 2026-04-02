//
//  SignUpView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/30/26.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var confirmedPassword: String = ""
    @State private var attempts: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Text("Sign up with Email")
                .font(.title)
                .bold()
            VStack(alignment: .leading, spacing: 5) {
                Text("Email")
                TextField("example$@gmail.com", text: $viewModel.email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                Text("Password")
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                Text("Confirm Password")
                SecureField("Confirm Password", text: $confirmedPassword)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            
            Button(action: {
                viewModel.signUp()
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
}

#Preview{
    SignUpView()
}
