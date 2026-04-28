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
        ScrollView {
            VStack(alignment: .center, spacing: 50) {
                
                VStack {
                    Text("Welcome Back")
                        .foregroundStyle(.white)
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                    
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 80)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    TextField("example$@gmail.com", text: $viewModel.email)
                        .onChange(of: viewModel.email) { _,_ in
                            viewModel.errorMessage = nil
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .accessibilityIdentifier( "email_tf")
                    Text("Password")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    SecureField("Password", text: $viewModel.password)
                        .onChange(of: viewModel.password) { _,_ in
                            viewModel.errorMessage = nil
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                        .accessibilityIdentifier("password_tf")
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 24)
                
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
                            .shadow(color: Color(.primary).opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .accessibilityIdentifier("logInButton")
                }
                
                VStack(spacing: 10) {
                    Text("Don't have an account?")
                    NavigationLink
                    {
                        SignUpView()
                    }   label: {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.primary))
                    }
                }
                
            }
        }

    }
}



#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}

