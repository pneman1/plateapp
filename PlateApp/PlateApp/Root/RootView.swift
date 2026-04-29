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
                
            } else if authVM.isAuthenticated{
                MainTabView()
                    .environmentObject(authVM)
            } else {
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
