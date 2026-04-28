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
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Create an Account")
                    .foregroundStyle(.white)
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                    .padding(.top, 80)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                    TextField("example$@gmail.com", text: $viewModel.email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .onChange(of: viewModel.email) { _,_ in
                            viewModel.errorMessage = nil
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                    Text("Username")
                    TextField("Username", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .onChange(of: viewModel.username) { _,_ in
                            viewModel.errorMessage = nil
                        }
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.default)
                    Text("Password")
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .onChange(of: viewModel.password) { _,_ in
                            withAnimation {
                                viewModel.errorMessage = nil
                            }
                        }
                    Text("Confirm Password")
                    SecureField("Confirm Password", text: $confirmedPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .onChange(of: confirmedPassword) { _,_ in
                            withAnimation {
                                viewModel.errorMessage = nil
                            }
                        }
                    
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
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.primary))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color(.primary).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
            }
            .padding(.horizontal, 24)
        }
        
    }
}

#Preview{
    SignUpView()
        .environmentObject(AuthViewModel())
}
