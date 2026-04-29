//
//  RootView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/25/26.
//
import SwiftUI

struct RootView: View {
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        Group {
                    if authVM.isInitialLoading {
                        // 1. Loading Screen
                        LoadingView()
                    } else if authVM.isAuthenticated {
                        // 2. User is logged in, but check if they've finished onboarding
                        if let user = authVM.user, !user.onboardingCompleted {
                            OnboardingView()
                                .environmentObject(authVM)
                                .transition(.move(edge: .trailing))
                        } else {
                            // 3. Main App Experience
                            MainTabView()
                                .environmentObject(authVM)
                                .transition(.opacity)
                        }
                    } else {
                        // 4. Not logged in
                        NavigationStack {
                            AuthView()
                        }
                        .environmentObject(authVM)
                    }
        }
        .animation(.easeInOut, value: authVM.isInitialLoading)
        .animation(.easeInOut, value: authVM.isAuthenticated)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "fork.knife.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color(.primary))
                        
                        ProgressView()
                            .tint(.white)
                    }
                }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
