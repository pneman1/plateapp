//
//  AuthView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI


struct AuthView: View {
    var body: some View {
        ZStack {
                    LinearGradient(
                        colors: [Color(white: 0.15), .black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color(.primary))
                            
                            Text("Plate")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .tracking(-1)
                        }
                        Spacer()
                        VStack(spacing: 12) {
                            Text("Welcome")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Your daily meal, shared with your friends.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 40)
                        }
                        
                        Spacer()
                        VStack(spacing: 20) {
                            NavigationLink {
                                SignInView()
                            } label: {
                                Text("Sign in with Email")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(.primary))
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .shadow(color: Color(.primary).opacity(0.3), radius: 15, x: 0, y: 8)
                            }
                            .padding(.horizontal, 30)
                            .accessibilityIdentifier("signInLink")
                        }
                        .padding(.bottom, 40)
                    }
                }
                .foregroundStyle(.white)
    }
}




#Preview {
    AuthView()
}
