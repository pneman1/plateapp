//
//  SignUpView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/30/26.
//
import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = AuthViewModel()
    @State private var confirmedPassword: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 50) {
            Text("Sign up with Email")
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
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .keyboardType(.phonePad)
                    .frame(width: 300, height: 50)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                Text("Confirm Password")
                SecureField("Confirm Password", text: $confirmedPassword)
                    .padding()
                    .keyboardType(.phonePad)
                    .frame(width: 300, height: 50)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.white), lineWidth: 1))
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            
            Button(action: {
                login()
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
    
    func login() {
        if viewModel.password.isEmpty || viewModel.password.isEmpty {
            withAnimation(.default) {
                self.errorMessage = "Please fill in all fields."
            }
        } else if viewModel.password != confirmedPassword {
            self.errorMessage = "Passwords are not the same."
        } 
    }
}

#Preview{
    SignUpView()
}
